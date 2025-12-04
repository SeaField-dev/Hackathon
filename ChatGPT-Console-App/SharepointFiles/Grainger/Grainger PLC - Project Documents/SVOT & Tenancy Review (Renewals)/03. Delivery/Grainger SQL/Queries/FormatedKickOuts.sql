--============================================================================================================================================================--
--Tenancies
--============================================================================================================================================================--

--Step 1 - 27800
-----
-- total records in qube extract 
Select * from stg_QubeActiveTenancies


--Step 2 - 27800
-----
-- con tran = sharer, Individual Tenant
Select * from stg_QubeActiveTenancies
WHERE con_tran IN ('Sharer', 'Individual Tenant');
------------------------------------------------------- 
-- con tran != sharer, Individual Tenant - 0

Select * from stg_QubeActiveTenancies
WHERE con_tran not IN ('Sharer', 'Individual Tenant');

--step 3 18572
-----
-- Distinct Tenancies from Tenants
Select distinct parent_reference,  salesforce_unit_id 
from stg_QubeActiveTenancies
WHERE con_tran IN ('Sharer', 'Individual Tenant')

------------------------------------------------------- 

--step 4 
-----
-- distinct tenancies
-- tenant_info is not null - 18572

Select distinct parent_reference,  salesforce_unit_id 
from stg_QubeActiveTenancies
WHERE con_tran IN ('Sharer', 'Individual Tenant')
and tenant_info is not null
-------------------------------------------------------
-- tenant_info is null - 0

Select distinct parent_reference,  salesforce_unit_id 
from stg_QubeActiveTenancies
WHERE con_tran IN ('Sharer', 'Individual Tenant')
and tenant_info is null

--step 5 - 3
-----

-- get discarded tenancies by duplicate unit

-- Drop TABLE IF EXISTS sub_DiscardedPMS;

select * into sub_DiscardedPMS
from (
select salesforce_unit_id, MIN(parent_reference) as  DiscardedPMSReference
from stg_QubeActiveTenancies
where salesforce_unit_id in  (
    select DistinctTenancies.salesforce_unit_id from (
 
        Select distinct parent_reference,  salesforce_unit_id from stg_QubeActiveTenancies
        WHERE con_tran IN ('Sharer', 'Individual Tenant')
		--and unit_tenure != 'Grnd Rent'
        and tenant_info is not null) DistinctTenancies
    group by DistinctTenancies.salesforce_unit_id
    having count(*) > 1
) group by  salesforce_unit_id
)

Select * from sub_DiscardedPMS

--step 7 
-----

-- unit exists in salesforce - 18568

Select distinct parent_reference,  salesforce_unit_id 
from stg_QubeActiveTenancies
WHERE con_tran IN ('Sharer', 'Individual Tenant')
and tenant_info is not null
and parent_reference not in (
select DiscardedPMSReference 
from sub_DiscardedPMS
)
and salesforce_unit_id in (
select id 
from stg_unit
)
-------------------------------------------------------
-- unit doesnt exist in salesforce - 1

Select distinct parent_reference,  salesforce_unit_id 
from stg_QubeActiveTenancies
WHERE con_tran IN ('Sharer', 'Individual Tenant')
and tenant_info is not null
and parent_reference not in (
select DiscardedPMSReference 
from sub_DiscardedPMS
)
and salesforce_unit_id not in (
select id 
from stg_unit
)


--step 8 
-----
-- Contact exists in salesforce -18568

Select distinct parent_reference,  salesforce_unit_id 
from stg_QubeActiveTenancies
WHERE con_tran IN ('Sharer', 'Individual Tenant')
and tenant_info is not null
and parent_reference not in (
select DiscardedPMSReference 
from sub_DiscardedPMS
)
and salesforce_unit_id in (
select id 
from stg_unit
)
and tenant_info in (
select id 
from stg_contacts
)
-------------------------------------------------------
-- Contact doesnt exist in salesforce - 0

Select *
from stg_QubeActiveTenancies
where parent_reference in (
Select distinct parent_reference
from stg_QubeActiveTenancies
WHERE con_tran IN ('Sharer', 'Individual Tenant')
and tenant_info is not null
and parent_reference not in (
select DiscardedPMSReference 
from sub_DiscardedPMS
)
)
and salesforce_unit_id in (
select id 
from stg_unit
)
and tenant_info not in (
select id 
from stg_contacts
)


------
-- For use in later recon
------
--Drop TABLE IF EXISTS sub_recon_Ten;

Select  * into sub_recon_Ten
From (
Select distinct parent_reference,  salesforce_unit_id
from stg_QubeActiveTenancies qt
inner join stg_unit unt
on unt.id = qt.salesforce_unit_id
inner join stg_contacts cts 
on cts.id = qt.tenant_info
WHERE con_tran IN ('Sharer', 'Individual Tenant')
and qt.tenant_info is not null
--and qt.unit_tenure != 'Grnd Rent'
and qt.parent_reference not in (
select DiscardedPMSReference 
from sub_DiscardedPMS
)
)

Select * from sub_recon_Ten;

--============================================================================================================================================================--
--Opps
--============================================================================================================================================================--

-- Step 1 - 69105
-----
-- All opportunities in Salesforce UAT

Select * from stg_opportunities

-- Step 2 - 14213
-----
-- All opps that dont match Migarted tenancies - 12616

Select * from stg_opportunities
where COALESCE(Primary_Offer_Live_Unit__c, Primary_Offer_Unit__c)  not in (
select salesforce_unit_id
from sub_recon_Ten
)



-- Step 3 
-----

-- Most recent by pms and unit -30812
Select * from stg_opportunities
where COALESCE(Primary_Offer_Live_Unit__c, Primary_Offer_Unit__c) in (
select salesforce_unit_id
from sub_recon_Ten
)
and id in (
Select id
from sub_opps)

Select * from sub_PMSOpps
Select * from sub_unitOpps

--------------------------------
-- Not most recent by pms and unit -24075
Select * from stg_opportunities
where COALESCE(Primary_Offer_Live_Unit__c, Primary_Offer_Unit__c) in (
select salesforce_unit_id
from sub_recon_Ten
)
and id not in (
Select id
from sub_opps)

--============================================================================================================================================================--
-- Contracts 
-- 50 Rejected in Salesforce - (2 due to validation exception, bad data on UAT Contract [Agreement Type]) (48 due to status set in previous migration and unable to revert)
--============================================================================================================================================================--

-- Step 1 - 43006
-----
--Total number on contracts in Salesforce

Select * from stg_Contracts

-- Step 2 - 42724
-----
--Residential Contracts in salesforce

Select * from stg_Contracts
Where RecordTypeId = '012Nz0000050AZCIA2' -- Residential Contracts
and opportunity__c is not null

Select * from stg_Contracts
Where RecordTypeId = '012Nz0000050AZCIA2' -- Residential Contracts
and opportunity__c is null


-- Step 3 
-----
--Associated with an opp in salesforce - 42698
Select * from stg_Contracts
where opportunity__c in (
select id from stg_opportunities
)
and RecordTypeId = '012Nz0000050AZCIA2';


Select * from stg_Contracts where opportunity__c is null

-----------------------------------
-- Not associated with an opp in salesforce -- 26
Select * from stg_Contracts
where opportunity__c not in (
select id from stg_opportunities
)
and RecordTypeId = '012Nz0000050AZCIA2';

-- Step 4 
-----
--Associated with Tenancy Included in Migration - 19451
Select * from stg_Contracts
where id in (
Select id from sub_Contracts
where "PMS_Reference__c" is not null
and opportunity__c IS NOT NULL
)
and RecordTypeId = '012Nz0000050AZCIA2';

-----------------------------------
--Not associated with Tenancy Included in Migration - 6622

Select * from stg_Contracts
where id not in (
Select id from sub_Contracts
where "PMS_Reference__c" is not null
and opportunity__c IS NOT NULL
)
and opportunity__c in (
select id from stg_opportunities
)
and unit__c not in (
Select "Unit__c"
from sub_Tenancies
where accountid is not null
and "Unit__c" is not null
)
and RecordTypeId = '012Nz0000050AZCIA2';

-- Step 5 -  3856
-----
-- Accounts not matching between Tenancy and Contract (not currently excluded in migration)
Select * from stg_Contracts ctr
Join stg_opportunities op ON
op.id = ctr.opportunity__c
Join sub_opps op2 ON
op2.id = ctr.opportunity__c
Join sub_Tenancies ten on 
ten."PMS_Reference__c" = op2."_PMS_Reference__c"
where ctr.RecordTypeId = '012Nz0000050AZCIA2' 
and  ten.accountid is not null
and ten."Unit__c" is not null
and ten.accountid != ctr.accountid 




--============================================================================================================================================================--
--EOT
-- 2 Rejected in Salesforce - (2 due to validation exception, data mismatch between EOT and Tenancy [Actual_Vacate_Date__c])
--============================================================================================================================================================--

-- Step 1 - 5608
-----
-- All EOTs in Salesforce UAT

Select * from stg_eot;


-- Step 2 - 4689
-----
-- EOTs Linked to Migrated Contracts Linked to Migrated Tenancies

Select * from stg_eot
where tenancy__c not in (
select id from sub_contracts
where "PMS_Reference__c" is not null
and opportunity__c IS NOT NULL
)


-- Step 2 - 204
-----
-- EOTs Linked to Migrated Contracts Linked to Migrated Tenancies
-- Only EOTS in Active', 'Pending Cancel/Close' status

Select * from stg_eot
where tenancy__c in (
select id from sub_contracts
where "PMS_Reference__c" is not null
and opportunity__c IS NOT NULL
)
and status__C not IN ('Active', 'Pending Cancel/Close')



------------------------------------------------------------------------------------------------------------------------------------------------
-- Tenancy contact Roles
------------------------------------------------------------------------------------------------------------------------------------------------


	-- Step 1 Qube tenancy not migrated into PROD - 5
	Select * from stg_qubeactivetenancies
	where parent_reference not in (
	select "PMS_Reference__c"
	from sub_tenancies
	where accountid is not null
	and "Unit__c" is not null
	And "Unit__c" != '#N?A' 
	--and "Unit__c" != '#N/A'
	)


	-- step 2 - contact doesnt exist in PROD - 0
	
	Select * from stg_qubeactivetenancies
	where parent_reference in (
	select "PMS_Reference__c"
	from sub_tenancies
	where accountid is not null
	and "Unit__c" is not null
	)
	and tenant_info not in (
	Select id 
	from stg_Contacts
	)



