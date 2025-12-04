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
JOIN sub_tenancies ten ON ten."PMS_Reference__c" = opp."_PMS_Reference__c"
JOIN stg_unit unt ON unt.id = ten."Unit__c"
where ten."PMS_Reference__c" = '111509016003'

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
  con.id as Contact_id, 
  ocr.Contact_FirstName, 
  ocr.Contact_LastName, 
  ocr.Role, 
  ocr.active__c as Active_OCR,
  ten."PMS_Reference__c" || '_' || ocr.Contactid AS Derived_Primary_Key
FROM stg_ocr ocr
JOIN sub_opps opp ON opp.id = ocr.opportunityid
JOIN stg_opportunities stg_opp ON stg_opp.id = opp.id
JOIN sub_tenancies ten ON ten."PMS_Reference__c" = opp."_PMS_Reference__c" -- here is where we are getting the kick outs because the Opps have been excluded 
JOIN stg_unit unt ON unt.id = ten."Unit__c"
Join stg_contacts con on con.accountid =  ten.accountid
where  ocr.Contactid = con.id
and ten.accountid is not null
and ten."Unit__c" is not null
and ten."PMS_Reference__c" = '122612001007'




select * from stg_QubeActiveTenancies
where Parent_reference = '418605003002'

Select * 
from sub_tenancies 
where "PMS_Reference__c" = '418605003002'
and accountid is not null
and "Unit__c" is not null

select * from sub_opps
where "_PMS_Reference__c" = '418605003002' 

select * from stg_opportunities
where PMS_Reference__c = '418605003002'


Select "Unit__c" 
from sub_tenancies 
where "PMS_Reference__c" = '111509016003'
and accountid is not null
and "Unit__c" is not null

select * from stg_opportunities
where COALESCE(Primary_Offer_Live_Unit__c, Primary_Offer_Unit__c) in (
Select "Unit__c" 
from sub_tenancies 
where "PMS_Reference__c" = '111509016003'
and accountid is not null
and "Unit__c" is not null
)

select * from sub_tenancies 
where "Unit__c" in (
Select COALESCE(Primary_Offer_Live_Unit__c, Primary_Offer_Unit__c) as Unit 
from stg_opportunities
where COALESCE(Primary_Offer_Live_Unit__c, Primary_Offer_Unit__c) = 'a1G4J0000025vf0UAA'
)
and accountid is not null
and "Unit__c" is not null;


Select * from sub_opps
where id = '0068d0000038pMnAAI'

select * from stg_opportunities
where id = '0068d0000038pMnAAI'

select * from stg_opportunities
where COALESCE(Primary_Offer_Live_Unit__c, Primary_Offer_Unit__c) in  ('a1G8d000002QRLdEAO', 'a1G4J0000025w5VUAQ', 'a1G4J0000025w5VUAQ', 'a1G4J0000025w5VUAQ', 'a1G4J0000025w5VUAQ', 'a1GNz0000000uTdMAI', 'a1GNz0000000uTdMAI', 'a1G4J0000025y3MUAQ', 'a1G4J0000025y5UUAQ', 'a1G4J0000025y5UUAQ', 'a1G4J0000025wsXUAQ', 'a1G4J0000025wsXUAQ', 'a1G4J0000025xtYUAQ', 'a1G4J0000025yUOUAY', 'a1G4J0000025yUOUAY', 'a1G8d0000004XkbEAE', 'a1G8d0000004cABEAY', 'a1G8d0000004qcZEAQ', 'a1G8d0000004qdXEAQ', 'a1G8d0000004qekEAA', 'a1G8d0000004qgHEAQ', 'a1G8d000002Q2ZgEAK', 'a1G4J0000025z4SUAQ', 'a1G4J0000025z20UAA', 'a1G4J0000025zC6UAI', 'a1G4J0000025z4UUAQ', 'a1G4J000002633PUAQ', 'a1G4J00000260g4UAA', 'a1G4J0000025znlUAA', 'a1G4J0000025znlUAA')
and StageName in ('Audit', 'Closed Won')
and tenancy_type__c = 'New'
order by COALESCE(Primary_Offer_Live_Unit__c, Primary_Offer_Unit__c), createddate desc 

select * from stg_opportunities
where COALESCE(Primary_Offer_Live_Unit__c, Primary_Offer_Unit__c) in  ('a1G8d000002QRLdEAO', 'a1G4J0000025w5VUAQ', 'a1G4J0000025w5VUAQ', 'a1G4J0000025w5VUAQ', 'a1G4J0000025w5VUAQ', 'a1GNz0000000uTdMAI', 'a1GNz0000000uTdMAI', 'a1G4J0000025y3MUAQ', 'a1G4J0000025y5UUAQ', 'a1G4J0000025y5UUAQ', 'a1G4J0000025wsXUAQ', 'a1G4J0000025wsXUAQ', 'a1G4J0000025xtYUAQ', 'a1G4J0000025yUOUAY', 'a1G4J0000025yUOUAY', 'a1G8d0000004XkbEAE', 'a1G8d0000004cABEAY', 'a1G8d0000004qcZEAQ', 'a1G8d0000004qdXEAQ', 'a1G8d0000004qekEAA', 'a1G8d0000004qgHEAQ', 'a1G8d000002Q2ZgEAK', 'a1G4J0000025z4SUAQ', 'a1G4J0000025z20UAA', 'a1G4J0000025zC6UAI', 'a1G4J0000025z4UUAQ', 'a1G4J000002633PUAQ', 'a1G4J00000260g4UAA', 'a1G4J0000025znlUAA', 'a1G4J0000025znlUAA')
and StageName not in ('Audit', 'Closed Won')
and tenancy_type__c = 'New'
order by COALESCE(Primary_Offer_Live_Unit__c, Primary_Offer_Unit__c), createddate desc 

select * from stg_ocr
where opportunityid = '006Nz00000K3FQWIA3'

Select * from sub_MostRecentNewOpps
where unit_id = 'a1G4J0000025w5VUAQ'

select * from sub_Opps
where "_PMS_Reference__c" = '122612001007'

------------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS sub_UnitOppstest;

-- Step 1: Identify the latest "New" opportunity per unit (based on Move-In Date)
Select * from sub_MostRecentNewOpps;

-- Step 2: Filter to only the most recent "New" opp per unit (ROW_NUMBER = 1)
Select * from sub_MostRecentFiltered;

-- Step 3: For those units, get the latest "New" opp + any subsequent "Renewal" opps

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



SELECT 
	uo.Opportunity_Id AS ID, -- Related Opportunity ID
	ctr."PMS_Reference__c" AS "_PMS_Reference__c", -- Tenancy__r:Contract:PMS_Reference__c
	uo.StageName
FROM sub_UnitOpps uo
LEFT JOIN sub_Tenancies ctr ----- Add left Join
    ON uo.Unit_Id = ctr."Unit__c" -- Join on matching Unit__c
    AND ctr.RecordTypeId = 'XXX' -- Only link to \"Residential Tenancy\" contracts
ORDER BY ctr."PMS_Reference__c", uo."opportunity_id";


------------------------------------------------------------------------------------------------------------------------------------------------



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
	AND COALESCE(opp.Primary_Offer_Live_Unit__c, opp.Primary_Offer_Unit__c) = 'a1G4J0000025y3MUAQ'

	Select * from stg_Opportunities
	where COALESCE(Primary_Offer_Live_Unit__c, Primary_Offer_Unit__c) = 'a1G4J0000025y3MUAQ'


-- Opp Stage = Closed lost



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
JOIN sub_tenancies ten ON ten."PMS_Reference__c" = opp."_PMS_Reference__c"
JOIN stg_unit unt ON unt.id = ten."Unit__c"
where ten."Unit__c" = 'a1G4J0000025y3MUAQ'


Select * from stg_opportunities
where COALESCE(Primary_Offer_Live_Unit__c, Primary_Offer_Unit__c) in ('a1G4J0000025w5VUAQ', 'a1G4J0000025w5VUAQ', 'a1G4J0000025w5VUAQ', 'a1G4J0000025w5VUAQ', 'a1GNz0000000uTdMAI', 'a1GNz0000000uTdMAI', 'a1G4J0000025yUOUAY', 'a1G4J0000025yUOUAY', 'a1G8d0000004cABEAY', 'a1G8d000002Q2ZgEAK', 'a1G4J0000025znlUAA', 'a1G4J0000025znlUAA')
and tenancy_type__c = 'New'
and stagename = 'Closed Won'
order by Primary_Offer_Live_Unit__c desc

-----------------------------------------------------------------------------------
-- unit a1G4J0000025y3MUAQ has no new opportunity 
-- unit a1G8d0000004cABEAY is assocaited with opp 0068d000009ggrjAAA which has no OCRS
-- unit a1G4J0000025zC6UAI excluded becuse contact doesnt exist in salesforce


Select * from stg_Opportunities
where COALESCE(Primary_Offer_Live_Unit__c, Primary_Offer_Unit__c) = 'a1G4J0000025zC6UAI'

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
JOIN sub_tenancies ten ON ten."PMS_Reference__c" = opp."_PMS_Reference__c"
JOIN stg_unit unt ON unt.id = ten."Unit__c"
where ten."Unit__c" = 'a1G4J0000025zC6UAI'

-- Unit a1G4J0000025zC6UAI is assocaited with the oppid 0064J00000DFTSCQA5
SELECT 
  opp.id AS Opportunity_id, 
  ocr.id AS ocr_id, 
  ocr.Contactid as Contact_id, 
  ocr.Contact_FirstName, 
  ocr.Contact_LastName, 
  ocr.Role, 
  ocr.active__c as Active_OCR
FROM stg_ocr ocr
JOIN sub_opps opp ON opp.id = ocr.opportunityid
where opp.id ='0064J00000DFTSCQA5'

SELECT 
  ocr.id AS ocr_id, 
  ocr.Contactid as Contact_id, 
  ocr.Contact_FirstName, 
  ocr.Contact_LastName, 
  ocr.Role, 
  ocr.active__c as Active_OCR
FROM stg_ocr ocr
where ocr.opportunityid ='0064J00000DFTSCQA5'

-- Check if the units opp id exists in sub opps
Select * from sub_opps where id = '0064J00000DFTSCQA5'

-- Check if opp id exists in staging opps
Select * from stg_opportunities where id = '0064J00000DFTSCQA5'

--Check that unit is associated with a tenancy
Select * from stg_QubeActiveTenancies where salesforce_unit_id = 'a1G4J0000025zC6UAI' -- PMS_ref: 317356110002

--Check that unit is associated with a migrated tenancy
Select * from sub_tenancies where "Unit__c" = 'a1G4J0000025zC6UAI' -- PMS_ref:


--Opp doesnt make it past the calculation stage
select * from sub_opps where "_PMS_Reference__c" = '222520096002'



------------------------------------------------------------------------------------------------------------------------------------------------

-- Step 1: Rank tenants within each tenancy (parent_reference) according to tenant type and tenancy start date

    SELECT 
        qt.*,
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
	and qt.salesforce_unit_id = 'a1G4J0000025zC6UAI'

-- Check if contact exists in salesforce--
select * from stg_contacts
where id = '0034J00000a4OCBQA2'

-- Step 2: Select top-ranked tenant per tenancy (rn = 1), then ensure unique Unit__c
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
            'XXX' AS RecordTypeId,
            rt.unitid AS "Unit__c",
            rt.start_date AS "StartDate", -- start date from unit extract 
            rt.end_date AS "Tenancy_End_Date__c", -- End date from unit extract 
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
        WHERE rt.rn = 1
    ) 

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
JOIN sub_tenancies ten ON ten."PMS_Reference__c" = opp."_PMS_Reference__c"
JOIN stg_unit unt ON unt.id = ten."Unit__c";


Select * from sub_opps
where id = '006Nz00000E1RsYIAV'


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
	  and opp.Id = '006Nz00000KDkY8IAL'
    ORDER BY 
        COALESCE(opp.Primary_Offer_Live_Unit__c, opp.Primary_Offer_Unit__c) ASC, -- Order by Unit ID
        opp.createddate DESC -- Then by latest Move-In Date


Select * from stg_ocr
where opportunityid = '006Nz00000U1HtaIAF'



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
JOIN sub_tenancies ten ON ten."PMS_Reference__c" = opp."_PMS_Reference__c"
JOIN stg_unit unt ON unt.id = ten."Unit__c"
where  opp.id = '006Nz00000KDkY8IAL'



SELECT 
  ten."PMS_Reference__c", 
  ten."StartDate" as Tenancy_Start_Date, 
  ten."Tenancy_End_Date__c" as Tenancy_End_Date, 
  opp.id AS Opportunity_id, 
  opp.tenancy_type__c as Tenancy_Type,
  opp.agreement_type__c AS Agreement_Type,
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
JOIN 
	(
		SELECT
		    id,
		    unit_id,
		    tenancy_type__c,
		    createddate,
			agreement_type__c,
			"_PMS_Reference__c"
		FROM (
		    SELECT
		        sg_opp.id,
		        COALESCE(sg_opp.Primary_Offer_Live_Unit__c,
		                 sg_opp.Primary_Offer_Unit__c) AS unit_id,
		        sg_opp.tenancy_type__c,
		        sg_opp.createddate,
				sg_opp.agreement_type__c,
				sb_opp."_PMS_Reference__c",
		        ROW_NUMBER()
		          OVER (
		            PARTITION BY COALESCE(
		                             sg_opp.Primary_Offer_Live_Unit__c,
		                             sg_opp.Primary_Offer_Unit__c
		                           )
		            ORDER BY sg_opp.createddate DESC
		          ) AS rn
		    FROM stg_opportunities sg_opp
		    JOIN sub_opps sb_opp
		      ON sb_opp.id = sg_opp.id
		) t
		WHERE rn = 1
		ORDER BY unit_id
)opp
ON opp.id = ocr.opportunityid
JOIN sub_tenancies ten ON ten."PMS_Reference__c" = opp."_PMS_Reference__c"
JOIN stg_unit unt ON unt.id = ten."Unit__c";




