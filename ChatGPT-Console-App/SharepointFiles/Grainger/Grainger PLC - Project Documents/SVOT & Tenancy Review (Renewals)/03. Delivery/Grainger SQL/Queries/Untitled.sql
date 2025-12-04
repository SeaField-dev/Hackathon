
--Setting tenancy term
--End date populated
-- Chekc the flow bypass


------------------------------------------------------------------------------------------------------------------------------------------------
-- Record Types
------------------------------------------------------------------------------------------------------------------------------------------------
--SIT
-- Residential Tenancy - 012Pv000002B0WbIAK -- Set across the tabes
-- Residential Contract - 012Pv0000027CJSIA2 -- Set on Sub_Contract creation 
------------------------------------------------------------------------------------------------------------------------------------------------
--UAT
-- Residential Tenancy - 012Pv0000027hGnIAI -- Set across the tabes
-- Residential Contract - 012Pv0000021hzSIAQ -- Set on Sub_Contract creation 
------------------------------------------------------------------------------------------------------------------------------------------------

-- Update to use PMS ref number
-- Add sanity Check Queries More Are we getting ball park of 10000 tenancy
-- Count targer contrcact table less than count for stg qube contracts 
-- Ask Nikki about Unit tenure for mapping logic Part 1, "ParkingSpac"

------------------------------------------------------------------------------------------------------------------------------------------------
--Part 1  - AC1  - Create Residential Tenancies in Salesforce from Qube Extract
------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose:
-- Create ONE new Salesforce Contract record (Residential Tenancy) for each unique active Qube Tenancy ID,
-- as per AC1 instructions.

-- Logic:
-- Only include where Con Tran = 'Sharer' (include sharers)
-- Exclude Unit Tenure = 'Grnd Rent'
-- Exclude records where Contact ID is null
-- Populate contract fields based on Qube extract and specified business logic

-- For each unique Qube Tenancy ID (parent_reference), select a single tenant record based on the following priority:
--         1. Prefer the tenant where tenant_type = 'Lead Tenant'.
--         2. If no 'Lead Tenant', select the tenant where tenant_type = 'Tenant' with the most recent tenancy_commenced date.
--         3. If no 'Tenant', select the tenant where tenant_type = 'Successor Reg' with the most recent tenancy_commenced date.
--         4. If no 'Successor Reg', select the tenant where tenant_type = 'Successor Assd Per' with the most recent tenancy_commenced date.
--         5. If none of the above tenant types exist, select the tenant with the most recent tenancy_commenced date regardless of type.
--         This ensures that only one row per parent_reference is selected for downstream processing.

-- Notes:
-- Will not overwrite existing Salesforce Opportunities.
-- Tenancies must be linked to an account (person or company) via Contact ID in extract.
-- Lead tenant logic: use Lead Tenant when multiple contacts exist for a tenancy.
-- Agreement Type mapping based on Unit Type and Unit Tenure from Qube.
------------------------------------------------------------------------------------------------------------------------------------------------
-- Step 1: Clear the intermediate and target tables
DROP TABLE sub_RankedTenancies;
Drop TABLE sub_Tenancies;

-- Step 1: Rank tenants within each tenancy (parent_reference) according to tenant type and tenancy start date
SELECT *
INTO sub_RankedTenancies
FROM (
    SELECT 
        qt.*,
        c.accountid,
        tenancy_count.record_count,
		unt.id AS unitid,
        -- Assign a row number per parent_reference based on priority rules
        ROW_NUMBER() OVER (
            PARTITION BY qt.parent_reference -- Group by tenancy
            ORDER BY 
                -- Prioritize based on tenant_type hierarchy
                CASE 
                    WHEN qt.tenant_type = 'Lead Tenant' THEN 1 -- Highest priority
                    WHEN qt.tenant_type = 'Tenant' THEN 2
                    WHEN qt.tenant_type = 'Successor Reg' THEN 3
                    WHEN qt.tenant_type = 'Successor Assd Per' THEN 4
                    ELSE 5 -- Lowest priority for all other tenant types
                END,
                qt.tenancy_commenced DESC -- For ties in tenant_type, select the most recent tenancy_commenced
        ) AS rn
    FROM stg_QubeActiveTenancies qt
    -- Join to Contacts table using tenant_info to bring in Account ID
    JOIN stg_Contacts c ON qt.tenant_info = c.id  -------------- changed to left join !!!!!!!!!!!!!!!!!!
    -- Join on units table
	JOIN stg_Unit unt ON unt.id = qt.salesforce_unit_id
	-- Subquery to count how many tenants exist per tenancy
    JOIN (
        SELECT 
            parent_reference,
            COUNT(*) AS record_count
        FROM stg_QubeActiveTenancies
        GROUP BY parent_reference
    ) tenancy_count
        ON qt.parent_reference = tenancy_count.parent_reference -- Join tenant count to each tenancy record
    -- Apply AC filters -- Chnaged for UAT Extract
    WHERE qt.con_tran IN ('Sharer', 'Individual Tenant') -- Only include "Sharer" and Individual Tenant (as per ACS business rules)
    --AND qt.unit_tenure != 'Grnd Rent' -- No longer exclude tenancies marked as "Ground Rent"
    AND qt.tenant_info IS NOT NULL -- Exclude records without a valid tenant_info
);
-- select * from sub_RankedTenancies

-- Step 2: Select top-ranked tenant per tenancy (rn = 1), then ensure unique Unit__c
SELECT *
INTO sub_Tenancies
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY "Unit__c"
            ORDER BY "StartDate" DESC
        ) AS unit_rn
    FROM (
        SELECT 
            rt.parent_reference AS "PMS_Reference__c",
            CASE 
                WHEN rt.record_count = 1 THEN rt.accountid
                WHEN rt.record_count > 1 AND rt.tenant_type = 'Lead Tenant' THEN rt.accountid
                ELSE rt.accountid
            END AS accountid,
            'Check Contract' AS Break_Clause__c,
            '012Pv0000027hGnIAI' AS RecordTypeId,
            rt.unitid AS "Unit__c",
            ud.startdate AS "StartDate", -- start date from unit extract 
            ud.enddate AS "Tenancy_End_Date__c", -- End date from unit extract 
            'Draft' as Status,
            CASE 
                WHEN rt.Unit_Type IN ('Garage', 'ParkingSpac', 'Shed') THEN 'Licence'
                WHEN rt.Unit_Tenure = 'AST' THEN 'AST'
                WHEN rt.Unit_Tenure = 'Aff Rent' THEN 'AST (Affordable)'
                WHEN rt.Unit_Tenure = 'Live Work' THEN 'Live Work'
                WHEN rt.Unit_Tenure = 'Comp-Let' THEN 'Non-Housing (Company)'
                WHEN rt.Unit_Tenure = 'Occ Con' THEN 'Occupation Contract'
                WHEN rt.Unit_Tenure = 'Licence' THEN 'Decant Agreement Normal'
                ELSE NULL
             END AS "Agreement_Type__c",
            rt.Unit_Tenure AS "Description"
        FROM sub_RankedTenancies rt
		Join stg_Unit_dates ud on 
		ud.unit__c = rt.unitid
        WHERE rt.rn = 1
    ) filtered_ranked
) final_ranked
WHERE unit_rn = 1;
------------------------------------------------------------------------------------------------------------------------------------------------
--Part 2 - First Pass - Link Opportunities & Contracts to a Tenancy where the PMS ID Matches
------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose:
-- For each unit, identify the most recent "New" tenancy opportunity, then cascade the link to subsequent "Renewal" opportunities.

-- Notes:
-- Match by PMS Reference ID
-- Link opportunities to residential tenancy (via PMS Reference) created earlier (AC1)
-- Renewal opps are linked if their Move In Date is after the initial "New" opportunity for that unit.
-- Do not overwrite existing PMS References on Opportunities per ACS rule.
------------------------------------------------------------------------------------------------------------------------------------------------
-- Exclude com opps


DROP TABLE IF EXISTS sub_MostRecentNewOpps;
DROP TABLE IF EXISTS sub_MostRecentFiltered;
DROP TABLE IF EXISTS sub_PmsOpps;
DROP TABLE IF EXISTS sub_Opps;

-- Step 1: Identify the latest "New" opportunity per unit based on Move-In Date
SELECT *
INTO sub_MostRecentNewOpps
FROM (
    SELECT
    	COALESCE(opp.Primary_Offer_Live_Unit__c, opp.Primary_Offer_Unit__c) AS Unit_Id, -- Unit ID from Opportunity (Primary_Offer_Live_Unit__c or Primary Offer Unit)
        opp.createddate AS createddate, -- Move-In Date of the Opportunity
        opp.pms_reference__c, -- PMS Reference (may be NULL)
        ROW_NUMBER() OVER (PARTITION BY COALESCE(opp.Primary_Offer_Live_Unit__c, opp.Primary_Offer_Unit__c) ORDER BY opp.createddate DESC) AS rn -- Get latest opp per unit
    FROM stg_Opportunities opp
    WHERE opp.Tenancy_Type__c = 'New' -- Filter for 'New' tenancy type only
    AND opp.StageName IN ('Audit', 'Closed Won') -- Include opportunities in 'Audit' or 'Closed Won' stages only
    AND COALESCE(opp.Primary_Offer_Live_Unit__c, opp.Primary_Offer_Unit__c) IN ( -- Only units present in Qube data extract
        SELECT qt."Unit__c"
        FROM sub_Tenancies qt
        JOIN stg_Contacts c ON qt.accountid = c.accountid -- Join to Contacts to ensure Contact linkage is present
	)
);

-- Step 2: Filter to only the most recent "New" opp per unit (ROW_NUMBER = 1)
SELECT *
INTO sub_MostRecentFiltered
FROM (
    SELECT 
        Unit_Id, 
        createddate, -- Capture latest Move-In Date for "New" opp
        pms_reference__c -- Carry over PMS Reference
    FROM sub_MostRecentNewOpps
    WHERE rn = 1 -- Only the latest opp per unit
);


-- Step 3: Select Opportunities that either:
-- - Match the most recent "New" tenancy opp for the unit OR
-- - Are "Renewal" opps after that "New" opp's Move-In date

SELECT *
INTO sub_PmsOpps
FROM (
    SELECT 
        opp.Id AS Opportunity_Id, -- Opportunity ID
        COALESCE(opp.Primary_Offer_Live_Unit__c, opp.Primary_Offer_Unit__c) AS Unit_Id, -- Unit ID from Opportunity (Primary_Offer_Live_Unit__c or Primary Offer Unit)
        opp.StageName, -- Stage name (e.g., Audit, Closed Won, etc.)
        opp.createddate, -- Created Date 
        opp.Tenancy_Type__c, -- Tenancy type (New or Renewal)
        opp.pms_reference__c -- PMS Reference for tracing
    FROM stg_Opportunities opp
    JOIN sub_MostRecentFiltered mrnt
      ON COALESCE(opp.Primary_Offer_Live_Unit__c, opp.Primary_Offer_Unit__c) = mrnt.Unit_Id -- Match based on PMS reference ID
    WHERE mrnt.pms_reference__c IS NOT NULL -- Only process units where the latest "New" opp has NULL PMS Reference
      AND (
        (opp.Tenancy_Type__c = 'New' AND opp.createddate = mrnt.createddate) -- Latest "New" opp itself
        OR (opp.Tenancy_Type__c = 'Renewal' AND opp.createddate > mrnt.createddate) -- Any "Renewals" after that
      )
    ORDER BY 
        COALESCE(opp.Primary_Offer_Live_Unit__c, opp.Primary_Offer_Unit__c)ASC, -- Order by Unit ID
        opp.createddate DESC -- Then by latest Created Date    
);

-- Step 4: Link Opportunities to Residential Tenancy records (Contracts)


-- FIRST OUTPUT:
-- Link Opportunity to Contract via matching Unit ID and RecordType (Residential Tenancy)

/*
--Add opportunity column to allow for New opportunities to be parented onto Tenancy
ALTER TABLE sub_Tenancies
ADD COLUMN Opportunity__c VARCHAR(18);
*/

/*
UPDATE sub_Tenancies
SET Opportunity__c = po.Opportunity__c
FROM (
    SELECT 
        po.pms_reference__c, 
        po.Opportunity_Id AS Opportunity__c
    FROM sub_PmsOpps po
    JOIN sub_Tenancies ctr 
        ON po.Unit_Id = ctr."Unit__c"
        AND ctr.RecordTypeId = '012Pv0000027hGnIAI'
        AND po.Tenancy_Type__c = 'New' -- only update with new opportunities 
) AS po
WHERE sub_Tenancies."PMS_Reference__c" = po."pms_reference__c";
*/

-- UPDATE sub_Tenancies
-- SET Opportunity__c = po.Opportunity__c
-- FROM (
--     SELECT 
--         po.pms_reference__c, 
--         po.Opportunity_Id AS Opportunity__c,
--         ROW_NUMBER() OVER (
--             PARTITION BY po.Unit_Id 
--             ORDER BY po.Move_In_Date__c DESC
--         ) AS rn
--     FROM sub_PmsOpps po
--     WHERE po.Tenancy_Type__c = 'Renewal'
-- ) AS po
-- WHERE sub_Tenancies."PMS_Reference__c" = po."pms_reference__c"
--   AND po.rn = 1 -- Only update with most recent Renewal opp
--   AND sub_Tenancies.RecordTypeId = '012Pv000002B0WbIAK';

-- SECOND OUTPUT:


SELECT *
INTO sub_Opps
FROM (
SELECT 
	po.Opportunity_Id AS ID, -- Related Opportunity ID
	ctr."PMS_Reference__c" AS "PMS_Reference__c", --"Tenancy__r:Contract:PMS_Reference__c"
	po.StageName
FROM sub_PmsOpps po
JOIN sub_Tenancies ctr 
    ON po.Unit_Id = ctr."Unit__c" -- Join on matching Unit__c
    AND ctr.RecordTypeId = '012Pv0000027hGnIAI' -- Only link to "Residential Tenancy" contracts
ORDER BY ctr."PMS_Reference__c", po."opportunity_id"
);


select * from sub_opps

select * from sub_PmsOpps
select * from sub_UnitOpps

select * from stg_opportunities 

------------------------------------------------------------------------------------------------------------------------------------------------
-- Part 2 - Second Pass - Identify Opportunities for the Most Recent Tenancy per Unit
------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose:
-- Link Opportunities without PMS Reference (null) to Residential Tenancies based on Unit.

-- Logic:
-- Only link where the tenancy exists in Salesforce by Unit__c
-- Update Tenancy__c on Opportunities and Contracts as needed
------------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS sub_UnitOpps;

-- Step 1: Identify the latest "New" opportunity per unit (based on Move-In Date)
Select * from sub_MostRecentNewOpps;

-- Step 2: Filter to only the most recent "New" opp per unit (ROW_NUMBER = 1)
Select * from sub_MostRecentFiltered;

-- Step 3: For those units, get the latest "New" opp + any subsequent "Renewal" opps
SELECT *
INTO sub_UnitOpps
FROM (
    SELECT 
        opp.Id AS Opportunity_Id, -- Opportunity ID
        COALESCE(opp.Primary_Offer_Live_Unit__c, opp.Primary_Offer_Unit__c) AS Unit_Id, -- Unit ID from Opportunity
        opp.StageName, -- Stage of the opp (e.g., Audit, Closed Won)
        opp.createddate, -- Move-In Date of the opp
        opp.Tenancy_Type__c, -- Tenancy type (New or Renewal)
        opp.pms_reference__c -- PMS Reference
    FROM stg_Opportunities opp
    JOIN sub_MostRecentFiltered mrnt
      ON COALESCE(opp.Primary_Offer_Live_Unit__c, opp.Primary_Offer_Unit__c) = mrnt.Unit_Id -- Match based on Unit ID
    WHERE mrnt.pms_reference__c IS NULL -- Only process units where the latest "New" opp has NULL PMS Reference
      AND (
        (opp.Tenancy_Type__c = 'New' AND opp.createddate = mrnt.createddate) -- Latest "New" opp itself
        OR (opp.Tenancy_Type__c = 'Renewal' AND opp.createddate > mrnt.createddate) -- Any "Renewals" after that
      )
    ORDER BY 
        COALESCE(opp.Primary_Offer_Live_Unit__c, opp.Primary_Offer_Unit__c) ASC, -- Order by Unit ID
        opp.createddate DESC -- Then by latest Move-In Date
);

/*
--Add opportunity column to allow for New opportunities to be parented onto Tenancy
UPDATE sub_Tenancies
SET Opportunity__c = uo.Opportunity__c
FROM (
    SELECT 
        ctr."PMS_Reference__c", 
        uo.Opportunity_Id AS Opportunity__c
    FROM sub_UnitOpps uo
    JOIN sub_Tenancies ctr 
        ON uo.Unit_Id = ctr."Unit__c"
        AND ctr.RecordTypeId = '012Pv0000027hGnIAI'
        AND uo.Tenancy_Type__c = 'New'
) AS uo
WHERE sub_Tenancies."PMS_Reference__c" = uo."PMS_Reference__c";
*/

-- Step 4b: Alternative output where Contract ID is returned as "Tenancy__c" for Opportunity updates
INSERT INTO sub_Opps (
    ID,
    "PMS_Reference__c",
	StageName
)
SELECT 
	uo.Opportunity_Id AS ID, -- Related Opportunity ID
	ctr."PMS_Reference__c" AS "PMS_Reference__c", -- Tenancy__r:Contract:PMS_Reference__c
	uo.StageName
FROM sub_UnitOpps uo
LEFT JOIN sub_Tenancies ctr ----- Add left Join
    ON uo.Unit_Id = ctr."Unit__c" -- Join on matching Unit__c
    AND ctr.RecordTypeId = '012Pv0000027hGnIAI' -- Only link to \"Residential Tenancy\" contracts
ORDER BY ctr."PMS_Reference__c", uo."opportunity_id";

------------------------------------------------------------------------------------------------------------------------------------------------
--Part 2 - Third Pass (Link Opp Contracts 2)
------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose:
-- Link Opportunity Contracts to Tenancy through PMS reference on the tenancy and the Opp
------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS sub_Contracts;

-- Step 1: Identify the latest "New" Opportunity per Unit based on PMS Reference linkage
Select * from sub_MostRecentNewOpps;
Select * from sub_MostRecentFiltered;
Select * from sub_Opps;

-- Step 2: Contracts associated with opportunities  


SELECT *
INTO sub_Contracts
FROM (
Select 
	ctr.id, op."PMS_Reference__c" AS "PMS_Reference__c", --Tenancy__r:Contract:PMS_Reference__c
	ctr.ownerid,
	ctr.AccountId, ctr.RecordTypeId, ctr.Unit__c, ctr.Status, ctr.Tenancy_Status__C, ctr.StartDate, ctr.EndDate, ctr.Agreement_Type__c, ctr.Document_Type__c, 
	ctr.Memorandum_of_Agreement_Date__c, ctr.Actual_Move_Out_Date__c, ctr.Uplift_Percentage__c, ctr.Security_Deposit_Amount__c, 
	ctr.Break_Clause__c, ctr.Special_Clauses__c, ctr.Special_Clause_Free_Text__c, ctr.Vehicle_Make__c, ctr.Vehicle_Model__c, ctr.Vehicle_Registration__c,ctr.opportunity__c
from stg_Contracts ctr
LEFT Join sub_Opps op ON
op.id = ctr.opportunity__c
Where RecordTypeId = '012Pv0000021hzSIAQ' -- Residential Contracts

);



------------------------------------------------------------------------------------------------------------------------------------------------
-- Part 3 - AC5 (Activate Draft Contracts for Closed Won Opportunities)
------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose:
-- Where an opportunity is Closed Won and linked to a tenancy, activate its related Contract based on agreement statuses.

-- Logic:
-- Agreement selection logic:
-- If only one signed agreement exists → use it
-- If multiple signed agreements → use latest created
-- If no signed agreements & one draft → use draft
-- Else use latest created agreement regardless of status

-- Action:
-- Update Contract status from Draft to Activated where applicable
------------------------------------------------------------------------------------------------------------------------------------------------
UPDATE sub_Contracts con
SET Status = 'Activated',
Tenancy_Status__C = 'Activated'
FROM (
SELECT DISTINCT a.Contractid
FROM stg_Agreements a
JOIN sub_opps opp ON a.OpportunityId = opp.Id
JOIN sub_Contracts con ON con.Id = a.ContractId
WHERE opp.StageName = 'Closed Won'
  AND con.Tenancy_Status__C = 'Draft'
  AND (
        -- Case 1: Exactly one 'Signed' agreement
        (a.Status = 'Signed' AND a.OpportunityId IN (
            SELECT OpportunityId
            FROM stg_Agreements
            WHERE Status = 'Signed'
            GROUP BY OpportunityId
            HAVING COUNT(*) = 1
        ))

        -- Case 2: Multiple 'Signed' agreements; pick the one with latest CreatedDate
        OR (a.Status = 'Signed' AND a.CreatedDate = (
            SELECT MAX(sa.CreatedDate)
            FROM stg_Agreements sa
            WHERE sa.Status = 'Signed'
              AND sa.OpportunityId = a.OpportunityId
        ))

        -- Case 3: No 'Signed' agreements, and exactly one 'Draft' agreement
        OR (a.Status = 'Draft' AND a.OpportunityId IN (
            SELECT OpportunityId
            FROM stg_Agreements
            GROUP BY OpportunityId
            HAVING
              COUNT(CASE WHEN Status = 'Signed' THEN 1 END) = 0
              AND COUNT(CASE WHEN Status = 'Draft' THEN 1 END) = 1
        ))

        -- Case 4: Default fallback – use latest agreement (typically Draft)
        OR (a.CreatedDate = (
            SELECT MAX(sa.CreatedDate)
            FROM stg_Agreements sa
            WHERE sa.OpportunityId = a.OpportunityId
        ))
      )
) AS FinalContracts
WHERE con.Id = FinalContracts.ContractId;
------------------------------------------------------------------------------------------------------------------------------------------------
-- Part 4 - AC6 (End Activated Contracts except the Latest)
------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose:
-- Ensure only the latest Activated contract for each tenancy remains Activated.

-- Logic:
-- Identify all tenancies with more than one Activated child contract
-- End all but the most recent (by StartDate)
------------------------------------------------------------------------------------------------------------------------------------------------
UPDATE sub_contracts
SET status = 'Draft',
Tenancy_Status__C = 'Ended'
WHERE id IN (
    SELECT ctr.id
    FROM sub_contracts ctr
    WHERE ctr.status = 'Activated'
      AND ctr."PMS_Reference__c" IN (
          -- Only process PMS References that:
          -- 1. Belong to Residential Tenancies (exist in sub_tenancies)
          -- 2. Have more than one Activated contract
          SELECT "PMS_Reference__c"
          FROM sub_contracts
          WHERE status = 'Activated'
            AND "PMS_Reference__c" IN (SELECT "PMS_Reference__c" FROM sub_tenancies)
          GROUP BY "PMS_Reference__c"
          HAVING COUNT(*) > 1
      )
      AND ctr.id NOT IN (
          -- Keep the latest Activated contract (by StartDate) per PMS_Reference__c
          SELECT id
          FROM (
              SELECT 
                  id,
                  ROW_NUMBER() OVER (
                      PARTITION BY "PMS_Reference__c" 
                      ORDER BY StartDate DESC
                  ) AS rnk
              FROM sub_contracts
              WHERE status = 'Activated'
          ) ranked
          WHERE rnk = 1
      )
);


------------------------------------------------------------------------------------------------------------------------------------------------
-- Part 5 - AC7 (Update Tenancy Information from Contracts)
------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose:
-- Populate tenancy-level fields using data from both the earliest and latest contract records.

-- Logic:
-- Last contract: Owner, Agreement Type, Document Type, Memorandum of Agreement Date, Move Out Date, Uplift %, End Date
-- First contract: Security Deposit Amount
-- Break Clause & Special Clauses: fallback logic between first and last
-- Vehicle info: fallback to earliest if latest is null
------------------------------------------------------------------------------------------------------------------------------------------------

-- Step: Update Tenancy records based on earliest/latest child contracts


ALTER TABLE sub_Tenancies
ADD COLUMN OwnerId VARCHAR(18),
ADD COLUMN Document_Type__c VARCHAR(225),
ADD COLUMN Memorandum_of_Agreement_Date__c DATE,
--ADD COLUMN Tenancy_End_Date__c DATE,
ADD COLUMN Actual_Move_Out_Date__c DATE,
ADD COLUMN Uplift_Percentage__c numeric(5,2),
ADD COLUMN Security_Deposit_Amount__c numeric(10,2),
ADD COLUMN Special_Clauses__c VARCHAR(5000),
ADD COLUMN Special_Clause_Free_Text__c VARCHAR(5000),
ADD COLUMN Vehicle_Make__c VARCHAR(50),
ADD COLUMN Vehicle_Model__c VARCHAR(50),
ADD COLUMN Vehicle_Registration__c VARCHAR(50)

UPDATE sub_tenancies
SET
    OwnerId = latest.OwnerId,
    "Agreement_Type__c" = latest.Agreement_Type__c,
    Document_Type__c = latest.Document_Type__c,
    Memorandum_of_Agreement_Date__c = latest.Memorandum_of_Agreement_Date__c,
    --"StartDate" = earliest.StartDate,
    -- Tenancy_End_Date__c = latest.EndDate,
    Actual_Move_Out_Date__c = latest.Actual_Move_Out_Date__c,
    Uplift_Percentage__c = latest.Uplift_Percentage__c,
    Security_Deposit_Amount__c = earliest.Security_Deposit_Amount__c,
    Break_Clause__c = CASE
        WHEN latest.Break_Clause__c IS NOT NULL AND latest.Break_Clause__c <> 'Check Contract'
            THEN latest.Break_Clause__c
        ELSE earliest.Break_Clause__c
    END,
    Special_Clauses__c = COALESCE(latest.Special_Clauses__c, earliest.Special_Clauses__c),
    Special_Clause_Free_Text__c = COALESCE(latest.Special_Clause_Free_Text__c, earliest.Special_Clause_Free_Text__c),
    Vehicle_Make__c = COALESCE(latest.Vehicle_Make__c, earliest.Vehicle_Make__c),
    Vehicle_Model__c = COALESCE(latest.Vehicle_Model__c, earliest.Vehicle_Model__c),
    Vehicle_Registration__c = COALESCE(latest.Vehicle_Registration__c, earliest.Vehicle_Registration__c)
FROM (
    SELECT 
        "PMS_Reference__c",
        StartDate,
        Security_Deposit_Amount__c,
        Break_Clause__c,
        Special_Clauses__c,
        Special_Clause_Free_Text__c,
        Vehicle_Make__c,
        Vehicle_Model__c,
        Vehicle_Registration__c
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY "PMS_Reference__c" ORDER BY StartDate ASC) AS rn
        FROM sub_contracts
        WHERE Status IN ('Activated', 'Draft')
    ) ranked_earliest
    WHERE rn = 1
) AS earliest
JOIN (
    SELECT 
        "PMS_Reference__c",
        OwnerId,
        Agreement_Type__c,
        Document_Type__c,
        Memorandum_of_Agreement_Date__c,
        EndDate,
        Actual_Move_Out_Date__c,
        Uplift_Percentage__c,
        Break_Clause__c,
        Special_Clauses__c,
        Special_Clause_Free_Text__c,
        Vehicle_Make__c,
        Vehicle_Model__c,
        Vehicle_Registration__c
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY "PMS_Reference__c" ORDER BY StartDate DESC) AS rn
        FROM sub_contracts
        WHERE Status IN ('Activated', 'Draft')
    ) ranked_latest
    WHERE rn = 1
) AS latest
    ON latest."PMS_Reference__c" = earliest."PMS_Reference__c"
WHERE sub_tenancies."PMS_Reference__c" = latest."PMS_Reference__c"
  AND sub_tenancies.RecordTypeId = '012Pv0000027hGnIAI';

------------------------------------------------------------------------------------------------------------------------------------------------
-- Part 6 - AC8 (Link Active EOTs to Residential Tenancy)
------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose:
-- Ensure all active or pending End of Tenancy records link to the parent Tenancy, not just the contract.

-- Logic:
-- Where status is 'Active' or 'Pending Cancel/Close' and tenancy link is available.
------------------------------------------------------------------------------------------------------------------------------------------------
-- DROP TABLE IF EXISTS sub_eot;

-- Select active or pending End of Tenancy (EOT) records that need to be relinked to their parent tenancy
SELECT *
INTO sub_eot
FROM (
select EOT.id, ctr."PMS_Reference__c"
from stg_eot eot
join sub_contracts ctr 
on eot.tenancy__c = ctr.id
WHERE eot.status__C IN ('Active', 'Pending Cancel/Close') -- Only consider EOT records in these statuses
order by ctr."PMS_Reference__c" desc
)

------------------------------------------------------------------------------------------------------------------------------------------------
--Part 7 - CJR-147 (Link Licence & Decant Tenancies to Live Unit Tenancy)
------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose:
-- Link all Licence or Decant type tenancies to their corresponding live tenancy on the same Account.

-- Logic:
-- Licence/Decant agreements will link to this "primary tenancy"
-- Limitation: only accounts with a single non-licence tenancy will be processed.
------------------------------------------------------------------------------------------------------------------------------------------------

-- Step 1: Identify accounts that have:
-- - Exactly one non-Licence/Decant tenancy (the “primary tenancy”)
-- - And at least one Licence or Decant tenancy (the “secondary tenancy”)

-- DROP TABLE IF EXISTS tgt_6_Contract_Upsert;

Select * into tgt_6_Contract_Upsert
FROM (
    SELECT DISTINCT licence."PMS_Reference__c", primary_contract."PMS_Reference__c" AS "Tenancy__r:Contract:PMS_Reference__c"
    FROM sub_Tenancies licence
    JOIN sub_Tenancies primary_contract ON primary_contract.AccountId = licence.AccountId
        WHERE COALESCE(primary_contract."Agreement_Type__c", 'XXX') NOT IN (
            'Licence', 'Decant Agreement Normal', 'Decant Agreement Wales'
        )
        AND COALESCE(licence."Agreement_Type__c", 'XXX') IN (
            'Licence', 'Decant Agreement Normal', 'Decant Agreement Wales'
        )		
        AND primary_contract.AccountId NOT IN (
            SELECT accountid
            FROM sub_Tenancies
                WHERE COALESCE("Agreement_Type__c", 'XXX') NOT IN (
                    'Licence', 'Decant Agreement Normal', 'Decant Agreement Wales'
                )
            GROUP BY accountid
            HAVING COUNT(*) > 1
        )
) 

------------------------------------------------------------------------------------------------------------------------------------------------
--Part 8 - CJR- - Link contact Roles to Tenancies
------------------------------------------------------------------------------------------------------------------------------------------------
Select * from stg_qubeactivetenancies

--Drop TABLE IF EXISTS tgt_Contact_Roles;

SELECT *
INTO tgt_Contact_Roles
FROM (
WITH ranked_tenancies AS (
    SELECT 
        con.id AS Contact__c, 
        qat.parent_reference AS "Tenancy__r:Contract:PMS_Reference__c", 
        qat.Tenant_type AS Role,
        qat.tenancy_commenced AS Start_Date__c,
        qat.tenancy_terminates AS End_Date__c,
        qat.parent_reference || '_' || qat.tenant_info AS External_Id__c
    FROM 
        stg_qubeactivetenancies qat
    JOIN 
        sub_tenancies ten 
    ON 
        ten."PMS_Reference__c" = qat.parent_reference
	Join stg_Contacts con on 
	con.id = qat.tenant_info
)

SELECT 
    Contact__c,
    "Tenancy__r:Contract:PMS_Reference__c",
    CASE 
	    WHEN Role = 'Lead Tenant' THEN '1 Lead Tenant'
	    WHEN Role = 'Tenant' THEN '2 Tenant'
	    WHEN Role = 'Additional occupier' THEN '4 Permitted Occupier'
	    WHEN Role = 'Guarantor' THEN '3 Guarantor'
	    WHEN Role = 'Successor Reg' THEN '6 Successor (Regulated)'
	    WHEN Role = 'Successor Assd Per' THEN '7 Successor (Assured Periodic)'
	    WHEN Role = 'POA' THEN '8 Power of Attorney'
	    WHEN Role = 'Previous' THEN '5 Relevant Person'
	    WHEN Role = 'Alternative contact' THEN '5 Relevant Person'
	    ELSE '5 Relevant Person'
	END AS Role__c,
    Start_Date__c,
    End_Date__c,
    External_Id__c
FROM 
    ranked_tenancies
ORDER BY 
    "Tenancy__r:Contract:PMS_Reference__c"
);

------------------------------------------------------------------------------------------------------------------------------------------------
--Part 9 - OCR report
------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 
  ten."PMS_Reference__c", 
  ten."StartDate" as Tenancy_Start_Date, 
  ten."Tenancy_End_Date__c" as Tenancy_End_Date, 
  opp.id AS Opportunity_id, 
  stg_opp.tenancy_type__c as Tenancy_Type,
  stg_opp.agreement_type__c AS Agreement_Type,
  ten."Unit__c" as Unit_id, 
  unt.Name AS Unit_Name, 
  ocr.id AS ocr_id, 
  ocr.Contactid as Contact_id, 
  ocr.Contact_FirstName, 
  ocr.Contact_LastName, 
  ocr.Role, 
  ocr.active__c as Active_OCR,
  ten."PMS_Reference__c" || '_' || ocr.Contactid AS Derived_Primary_Key
FROM stg_ocr ocr
JOIN sub_opps opp ON opp.id = ocr.opportunityid
JOIN stg_opportunities stg_opp ON stg_opp.id = opp.id
JOIN sub_tenancies ten ON ten."PMS_Reference__c" = opp."PMS_Reference__c"
JOIN stg_unit unt ON unt.id = ten."Unit__c";



select * from sub_opps
select * from stg_opportunities
select * from sub_tenancies
Select * from stg_ocr
Select * from stg_unit



