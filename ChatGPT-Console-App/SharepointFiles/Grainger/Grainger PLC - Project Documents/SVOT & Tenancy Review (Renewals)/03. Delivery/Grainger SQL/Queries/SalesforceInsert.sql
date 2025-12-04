
------------------------------------------------------------------------------------------------------------------------------------------------
--Step 1 - Insert Tenancies into Contract Object 
------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE tgt_1_Tenancies;

--Insert sub tenancies into Target Tenancies
INSERT INTO tgt_1_Tenancies
SELECT * FROM sub_Tenancies
where accountid is not null
and "Unit__c" is not null; 

select * from tgt_1_Tenancies;


------------------------------------------------------------------------------------------------------------------------------------------------
--Step 1.5 - Upsert Tenancy Status on inserted Tenancies
------------------------------------------------------------------------------------------------------------------------------------------------
-- Drop Table if exists tgt_1_Tenancies_Activate;

SELECT *
INTO tgt_1_Tenancies_Activate
FROM (
Select "PMS_Reference__c", 'Current' as Tenancy_Status__c,
'Activated' as status
From sub_Tenancies
where accountid is not null
and "Unit__c" is not null
);

Select * from tgt_1_Tenancies_Activate;
------------------------------------------------------------------------------------------------------------------------------------------------
--Step 2 - Upsert Contracts into Contract object using PMS_reference 
------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE tgt_2_Contracts;

--SELECT * FROM sub_Contracts
--where opportunity__c IS NOT NULL
--and "PMS_Reference__c" is not null;

Select * from tgt_2_Contracts



--Insert sub contracts into Target Contracts

--INSERT INTO tgt_2_Contracts
--SELECT * FROM sub_Contracts
--where opportunity__c IS NOT NULL
--and "PMS_Reference__c" is not null;

-- Discard mismatched accountids
INSERT INTO tgt_2_Contracts
Select ctr.*
from sub_Contracts ctr
Join sub_Tenancies ten on ten."PMS_Reference__c" = ctr."PMS_Reference__c"
where ctr."PMS_Reference__c" is not null
and ctr.opportunity__c IS NOT NULL
--and ten.accountid = ctr.accountid -- Check how many accounts do not line up


Alter Table tgt_2_Contracts
ADD COLUMN PMS_Reference__C VARCHAR(50);
UPDATE tgt_2_Contracts
SET PMS_Reference__C = "Tenancy__r:Contract:PMS_Reference__c";

Select * from tgt_2_Contracts;





------------------------------------------------------------------------------------------------------------------------------------------------
--Step 3 - Update Opportunities on  Opportunity Object
------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE tgt_3_Opportunities;

Insert INTO tgt_3_Opportunities
select id, "_PMS_Reference__c" from sub_opps;

Alter Table tgt_3_Opportunities
ADD COLUMN _PMS_Reference__C VARCHAR(50);
UPDATE tgt_3_Opportunities
SET _PMS_Reference__C = "Tenancy__r:Contract:PMS_Reference__C";


Select * from tgt_3_Opportunities;

------------------------------------------------------------------------------------------------------------------------------------------------
--Step 4 - UPSERT EOT on  EOT Object using PMS Reference
------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE tgt_4_EOT;

INSERT INTO tgt_4_EOT
SELECT * FROM sub_EOT
where "PMS_Reference__c" IS NOT null;

Select * from tgt_4_EOT;

------------------------------------------------------------------------------------------------------------------------------------------------
--Step 5 - Update Tenancies on Contract Object 
------------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE tgt_5_Tenancies2;


--Insert sub tenancies into Target Tenancies
INSERT INTO tgt_5_Tenancies2
SELECT * FROM sub_Tenancies
where accountid is not null
and "Unit__c" is not null; 


select * from tgt_5_Tenancies2;

------------------------------------------------------------------------------------------------------------------------------------------------
--Step 6 - UPSERT licence tenancy to parent residential tenancy 
------------------------------------------------------------------------------------------------------------------------------------------------
Select * from tgt_6_Contract_Upsert

------------------------------------------------------------------------------------------------------------------------------------------------
--Step 7 - Insert tenancy Contact Roles
------------------------------------------------------------------------------------------------------------------------------------------------

Select * from tgt_Contact_Roles;







