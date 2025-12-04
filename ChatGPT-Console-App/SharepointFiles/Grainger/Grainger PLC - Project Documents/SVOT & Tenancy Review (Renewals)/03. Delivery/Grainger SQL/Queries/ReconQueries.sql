--Tenancies

--Check Kick outs

Select * from stg_QubeActiveTenancies;

Select * from stg_QubeActiveTenancies
where parent_reference is null



--Step 1 - 44768
-----
-- total records in qube extract 
Select * from stg_QubeActiveTenancies


--Step 2 - 29073
-----
-- con tran = sharer
Select * from stg_QubeActiveTenancies
WHERE con_tran = 'Sharer'

--step 3 - 19819
-----
-- con tran = sharer
-- select distinct parent and unit ids
Select distinct parent_reference,  salesforce_unit_id 
from stg_QubeActiveTenancies
WHERE con_tran IN ('Sharer', 'Individual Tenant');

--step 4 - 19782
-----
-- con tran = sharer
-- select distinct parent and unit ids
-- tenant_info is not null

Select distinct parent_reference,  salesforce_unit_id 
from stg_QubeActiveTenancies
WHERE con_tran = 'Sharer'
and tenant_info is not null

--step 5 - 109
-----
-- get discarded tenancies by duplicate unit

-- Drop TABLE IF EXISTS sub_DiscardedPMS;

select * into sub_DiscardedPMS
from (
select salesforce_unit_id, min(parent_reference) as  DiscardedPMSReference
from stg_QubeActiveTenancies
where salesforce_unit_id in  (
    select DistinctTenancies.salesforce_unit_id from (
 
        Select distinct parent_reference,  salesforce_unit_id from stg_QubeActiveTenancies
        WHERE con_tran = 'Sharer'
		--and unit_tenure != 'Grnd Rent'
        and tenant_info is not null) DistinctTenancies
    group by DistinctTenancies.salesforce_unit_id
    having count(*) > 1
) group by  salesforce_unit_id
)

--step 6 - 19673
-----
-- con tran = sharer
-- select distinct parent and unit ids
-- tenant_info is not null
-- unit_tenure != 'Grnd Rent'
-- removed tenancies with duplicate units

Select distinct parent_reference,  salesforce_unit_id 
from stg_QubeActiveTenancies
WHERE con_tran = 'Sharer'
and tenant_info is not null
--and unit_tenure != 'Grnd Rent'
and parent_reference not in (
select DiscardedPMSReference 
from sub_DiscardedPMS
)

--step 7 - 19666
-----
-- con tran = sharer
-- select distinct parent and unit ids
-- tenant_info is not null
-- unit_tenure != 'Grnd Rent'
-- removed tenancies with duplicate units
-- unit exists in salesforce

Select distinct parent_reference,  salesforce_unit_id 
from stg_QubeActiveTenancies
WHERE con_tran = 'Sharer'
and tenant_info is not null
--and unit_tenure != 'Grnd Rent'
and parent_reference not in (
select DiscardedPMSReference 
from sub_DiscardedPMS
)
and salesforce_unit_id in (
select id 
from stg_unit
)




--step 8 -- 19622
-----
-- con tran = sharer
-- select distinct parent and unit ids
-- tenant_info is not null
-- unit_tenure != 'Grnd Rent'
-- Contact exists in salesforce
-- Unit exists in salesforce
-- Contact Exists in salesforce

Select distinct parent_reference,  salesforce_unit_id
from stg_QubeActiveTenancies qt
inner join stg_unit unt
on unt.id = qt.salesforce_unit_id
inner join stg_contacts cts 
on cts.id = qt.tenant_info
WHERE qt.con_tran = 'Sharer'
and qt.tenant_info is not null
--and qt.unit_tenure != 'Grnd Rent'
and qt.parent_reference not in (
select DiscardedPMSReference 
from sub_DiscardedPMS
)









--Drop Table sub_ReconTenancies

select * into sub_ReconTenancies
from (
	Select distinct parent_reference,  salesforce_unit_id
from stg_QubeActiveTenancies qt
inner join stg_unit unt
on unt.id = qt.salesforce_unit_id
inner join stg_contacts cts 
on cts.id = qt.tenant_info
WHERE qt.con_tran = 'Sharer'
and qt.tenant_info is not null
--and qt.unit_tenure != 'Grnd Rent'
and qt.parent_reference not in (
select DiscardedPMSReference 
from sub_DiscardedPMS
)
)

select * from sub_ReconTenancies

select * from sub_RankedTenancies
where parent_reference in (
select srt.parent_reference
from sub_ReconTenancies srt
left join tgt_1_Tenancies tnc
on tnc.unit__c = srt.salesforce_unit_id
where tnc.unit__c is null
)


select * from tgt_1_Tenancies

Select parent_reference,  salesforce_unit_id, cts.id, tenant_type
from stg_QubeActiveTenancies qt
inner join stg_unit unt
on unt.id = qt.salesforce_unit_id
inner join stg_contacts cts 
on cts.id = qt.tenant_info
WHERE qt.con_tran = 'Sharer'
and qt.tenant_info is not null
--and qt.unit_tenure != 'Grnd Rent'

and parent_reference in (
	select parent_reference from sub_RankedTenancies
	where parent_reference in (
	select srt.parent_reference
	from sub_ReconTenancies srt
	left join tgt_1_Tenancies tnc
	on tnc.unit__c = srt.salesforce_unit_id
	where tnc.unit__c is null
)
)

and qt.parent_reference not in (
select DiscardedPMSReference 
from sub_DiscardedPMS
)
order by parent_reference desc

select * from stg_QubeActiveTenancies
select * from sub_RankedTenancies

select id 
from stg_contacts
where id = '0034J00000a4YyyQAE'


select * from sub_tenancies
where pms_reference__c = '418565056003'

select srt.salesforce_unit_id,srt.parent_reference
from sub_ReconTenancies srt
left join tgt_1_Tenancies tnc
on tnc.unit__c = srt.salesforce_unit_id
where tnc.unit__c is null

select tnc.unit__c, tnc.pms_reference__c
from tgt_1_Tenancies tnc 
left join sub_ReconTenancies srt
on tnc.unit__c = srt.salesforce_unit_id
where srt.salesforce_unit_id is null







Select * FROM sub_Tenancies
where "Unit__c" is null

Select * FROM sub_Tenancies
where accountid is null; 


Select * FROM sub_Tenancies
where unit_rn = 1


select distinct parent_reference

--Contracts

Select * from stg_contracts

Select * from sub_contracts;

Select * from sub_contracts
where opportunity__c IS NULL

Select * from sub_contracts
and "PMS_Reference__c" is null;

--Opportunities 

select * from stg_opportunities

Select * from sub_PmsOpps;
Select * from sub_UnitOpps;
Select * from sub_Opps;


--EOTs

Select * from stg_EOT

Select * from sub_eot
where "PMS_Reference__c" IS  null;

Select * from sub_eot
where "PMS_Reference__c" IS not null;

-----
select *
from tgt_1_Tenancies
where  PMS_Reference__c = '222552002001'

Select *
from tgt_3_Opportunities
where _pms_reference__c = '222552002001'
-----



SELECT DISTINCT licence.id, primary_contract."PMS_Reference__c", licence.AccountId, primary_contract.AccountId
    FROM sub_Tenancies primary_contract
    JOIN sub_contracts licence ON primary_contract.AccountId = licence.AccountId
    WHERE primary_contract.RecordTypeId = '012Pv0000027hGnIAI' -- Residential Tenancy
        AND COALESCE(primary_contract."Agreement_Type__c", 'XXX') NOT IN (
            'Licence', 'Decant Agreement Normal', 'Decant Agreement Wales'
        )
        AND COALESCE(licence.agreement_type__c, 'XXX') IN (
            'Licence', 'Decant Agreement Normal', 'Decant Agreement Wales'
        )
		Order by primary_contract.AccountId desc;


------
UPDATE sub_Tenancies --860
SET "PMS_Reference__c" = acc."PMS_Reference__c"

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

-- AST - 222601023004
-- Licence - 222601065001

Select * from sub_Tenancies

SELECT DISTINCT licence."PMS_Reference__c", primary_contract."PMS_Reference__c" AS "Tenancy__r:Contract:PMS_Reference__c", primary_contract.AccountId
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
		and primary_contract."PMS_Reference__c" = '222601023004'

Select * from sub_Tenancies
where "PMS_Reference__c" in ('222601023004', '222601065001', '222601066001')

------------------------------------------------------------------------------------------------------------------------------------------------
--Opp Debugging


select *
from stg_opportunities
where id = '0068d00000CtQnLAAV'

select *
from sub_MostRecentNewOpps
where unit_id = 'a1G4J0000025xU1UAI'

select *
from sub_MostRecentFiltered
where unit_id = 'a1G4J0000025xU1UAI'


SELECT 
        opp.Id AS Opportunity_Id, -- Opportunity ID
        COALESCE(opp.Primary_Offer_Live_Unit__c, opp.Primary_Offer_Unit__c) AS Unit_Id, -- Unit ID from Opportunity
        opp.StageName, -- Stage of the opp (e.g., Audit, Closed Won)
        opp.Move_In_Date__c, -- Move-In Date of the opp
        opp.Tenancy_Type__c, -- Tenancy type (New or Renewal)
        opp.pms_reference__c -- PMS Reference
    FROM stg_Opportunities opp
    JOIN sub_MostRecentFiltered mrnt
      ON COALESCE(opp.Primary_Offer_Live_Unit__c, opp.Primary_Offer_Unit__c) = mrnt.Unit_Id -- Match based on Unit ID
    WHERE mrnt.pms_reference__c IS NULL -- Only process units where the latest "New" opp has NULL PMS Reference
      AND (
        (opp.Tenancy_Type__c = 'New' AND opp.Move_In_Date__c = mrnt.Move_In_Date) -- Latest "New" opp itself
        OR (opp.Tenancy_Type__c = 'Renewal' AND opp.Move_In_Date__c > mrnt.Move_In_Date) -- Any "Renewals" after that
      )
	  AND id = '0068d00000CtQnLAAV'
    ORDER BY 
        COALESCE(opp.Primary_Offer_Live_Unit__c, opp.Primary_Offer_Unit__c) ASC, -- Order by Unit ID
        opp.Move_In_Date__c DESC -- Then by latest Move-In Date

-------------------------------------

select * from stg_Opportunities

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
        opp.createddate, -- Move-In date
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
        opp.createddate DESC -- Then by latest Move-In Date    
);

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
)


Select ctr.accountid, ten.accountid from sub_Contracts ctr
Join sub_Tenancies ten on ten."PMS_Reference__c" = ctr."PMS_Reference__c"
where ctr."PMS_Reference__c" is not null
and ten.accountid = ctr.accountid

Where 

Select * from tgt_4_EOT
limit 10



Select 
	ctr.id, op."_PMS_Reference__c" AS "PMS_Reference__c", --Tenancy__r:Contract:PMS_Reference__c
	ctr.ownerid,
	ctr.AccountId, ctr.RecordTypeId, ctr.Unit__c, ctr.Status, ctr.Tenancy_Status__C, ctr.StartDate, ctr.EndDate, ctr.Agreement_Type__c, ctr.Document_Type__c, 
	ctr.Memorandum_of_Agreement_Date__c, ctr.Actual_Move_Out_Date__c, ctr.Uplift_Percentage__c, ctr.Security_Deposit_Amount__c, 
	ctr.Break_Clause__c, ctr.Special_Clauses__c, ctr.Special_Clause_Free_Text__c, ctr.Vehicle_Make__c, ctr.Vehicle_Model__c, ctr.Vehicle_Registration__c,ctr.opportunity__c
from stg_Contracts ctr
LEFT Join sub_Opps op ON
op.id = ctr.opportunity__c
Where RecordTypeId != '012Pv0000027hGnIAI'
and op."_PMS_Reference__c" is not null

Select distinct id, "_PMS_Reference__c" from sub_opps
Select id from sub_opps

select distinct pms_reference__c from stg_opportunities

Select distinct "_PMS_Reference__c" from sub_opps
Select distinct id from sub_opps

select * from sub_tenancies



Select 
	ctr.id, op.pms_reference__c AS "PMS_Reference__c", --Tenancy__r:Contract:PMS_Reference__c
	ctr.ownerid,
	ctr.AccountId, ctr.RecordTypeId, ctr.Unit__c, ctr.Status, ctr.Tenancy_Status__C, ctr.StartDate, ctr.EndDate, ctr.Agreement_Type__c, ctr.Document_Type__c, 
	ctr.Memorandum_of_Agreement_Date__c, ctr.Actual_Move_Out_Date__c, ctr.Uplift_Percentage__c, ctr.Security_Deposit_Amount__c, 
	ctr.Break_Clause__c, ctr.Special_Clauses__c, ctr.Special_Clause_Free_Text__c, ctr.Vehicle_Make__c, ctr.Vehicle_Model__c, ctr.Vehicle_Registration__c,ctr.opportunity__c
from stg_Contracts ctr
LEFT Join sub_opps op ON
op.id = ctr.opportunity__c
Where RecordTypeId != '012Pv0000027hGnIAI'
and op.pms_reference__c is not null


Select * 
from tgt_3_Opportunities
where id = '0064J00000DFOeeQAH'


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
	and qt.parent_reference = '103086014001'

	Select  *
	from stg_QubeActiveTenancies
	where parent_reference = '103086014001'



SELECT *
INTO sub_Tenancies2
FROM (


ALTER TABLE sub_Tenancies
ADD COLUMN Opportunity__c VARCHAR(18);

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