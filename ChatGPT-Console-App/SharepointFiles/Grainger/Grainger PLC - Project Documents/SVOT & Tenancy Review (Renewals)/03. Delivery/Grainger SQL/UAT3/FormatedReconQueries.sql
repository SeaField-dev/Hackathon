--============================================================================================================================================================--
--Tenancies
--============================================================================================================================================================--

--Step 1 - 49768
-----
-- total records in qube extract 
Select * from stg_QubeActiveTenancies


--Step 2 - 29073
-----
-- con tran = sharer
Select * from stg_QubeActiveTenancies
WHERE con_tran IN ('Sharer', 'Individual Tenant');

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
WHERE con_tran IN ('Sharer', 'Individual Tenant')
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
        WHERE con_tran IN ('Sharer', 'Individual Tenant')
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
WHERE con_tran IN ('Sharer', 'Individual Tenant')
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
WHERE con_tran IN ('Sharer', 'Individual Tenant')
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
WHERE con_tran IN ('Sharer', 'Individual Tenant')
and qt.tenant_info is not null
--and qt.unit_tenure != 'Grnd Rent'
and qt.parent_reference not in (
select DiscardedPMSReference 
from sub_DiscardedPMS
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

-- Step 1 - 59181
-----
-- All opportunities in Salesforce UAT

Select * from stg_opportunities

-- Step 2 - 51311
-----
-- All opps that match Migarted tenancies

Select * 
from stg_opportunities op
join sub_recon_Ten ten on
ten.salesforce_unit_id = COALESCE(op.Primary_Offer_Live_Unit__c, op.Primary_Offer_Unit__c)


-- Step 3.1 - 19576
-----
-- Most recnt new Opps 
Select * from sub_MostRecentFiltered;

-- Step 3.2 - 4846
-----
-- Most recnet new and renewal Opps Linked to a migrated tenancy by PMS Referecne

Select * from sub_PmsOpps

-- Step 3.3 - 23669
-----
-- Most recnet new and renewal Opps Linked to a migrated tenancy by Unit

Select * from sub_UnitOpps

--Step 4 - 34166
-----
29320 + 4846 = 34166

Select * from sub_opps

--============================================================================================================================================================--
-- Contracts 
-- 50 Rejected in Salesforce - (2 due to validation exception, bad data on UAT Contract [Agreement Type]) (48 due to status set in previous migration and unable to revert)
--============================================================================================================================================================--

-- Step 1 - 51940
-----
--Total number on contracts in Salesforce

Select * from stg_Contracts

-- Step 2 - 32079
-----
--Residential Contracts in salesforce

Select * from stg_Contracts
Where RecordTypeId = '012Pv0000021hzSIAQ' -- Residential Contracts


-- Step 3 - 31885
-----
--Residential Contracts in salesforce
--Associated with an opp in salesforce

Select * from stg_Contracts ctr
Join stg_opportunities op ON
op.id = ctr.opportunity__c
Where RecordTypeId = '012Pv0000021hzSIAQ' 

-- Step 4 - 17246
-----
--Residential Contracts in salesforce
--Associated with an opp in salesforce
--Associated with Tenancy Included in Migration

Select * from stg_Contracts ctr
Join stg_opportunities op ON
op.id = ctr.opportunity__c
Join sub_opps op2 ON
op2.id = ctr.opportunity__c
Join sub_Tenancies ten on 
ten."PMS_Reference__c" = op2."_PMS_Reference__c"
where ctr.RecordTypeId = '012Pv0000021hzSIAQ' 
and  ten.accountid is not null
and ten."Unit__c" is not null

-- Step 5 - 3162
-----
-- Accounts not matching between Tenancy and Contract (not currently excluded in migration)

Select * from stg_Contracts ctr
Join stg_opportunities op ON
op.id = ctr.opportunity__c
Join sub_opps op2 ON
op2.id = ctr.opportunity__c
Join sub_Tenancies ten on 
ten."PMS_Reference__c" = op2."_PMS_Reference__c"
where ctr.RecordTypeId = '012Pv0000021hzSIAQ' 
and  ten.accountid is not null
and ten."Unit__c" is not null
and ten.accountid != ctr.accountid 


--============================================================================================================================================================--
--EOT
-- 2 Rejected in Salesforce - (2 due to validation exception, data mismatch between EOT and Tenancy [Actual_Vacate_Date__c])
--============================================================================================================================================================--

-- Step 1 - 1586
-----
-- All EOTs in Salesforce UAT

Select * from stg_eot;


-- Step 2 - 87
-----
-- EOTs Linked to Migrated Contracts Linked to Migrated Tenancies

Select * from stg_eot eot
join sub_contracts ctr 
on eot.tenancy__c = ctr.id
Join sub_Tenancies ten on ten."PMS_Reference__c" = ctr."PMS_Reference__c"
where ctr."PMS_Reference__c" is not null
and ctr.opportunity__c IS NOT NULL


-- Step 2 - 634
-----
-- EOTs Linked to Migrated Contracts Linked to Migrated Tenancies
-- Only EOTS in Active', 'Pending Cancel/Close' status

Select * from stg_eot eot
join sub_contracts ctr 
on eot.tenancy__c = ctr.id
Join sub_Tenancies ten on ten."PMS_Reference__c" = ctr."PMS_Reference__c"
where ctr."PMS_Reference__c" is not null
and ctr.opportunity__c IS NOT NULL
and eot.status__C IN ('Active', 'Pending Cancel/Close')


--============================================================================================================================================================--
--Licences Linked To Tenancies - 1128
--============================================================================================================================================================--
Select * from tgt_6_Contract_Upsert