Select *
from stg_Pricebooks

Select *
from stg_Units

Select * 
from stg_SEP24

Select *
from stg_MARCH25

INSERT INTO tgt_PBE_SEP24 (
    Pricebook2Id,
    Product2Id,
    IsActive,
    UnitPrice,
    Rent_Periodicity__c
)
SELECT
    pb.Id AS Pricebook2Id,
    u.Product__c AS Product2Id,
    TRUE AS IsActive,
    s.ERV/12 AS UnitPrice,
    'Monthly' AS Rent_Periodicity__c
FROM stg_SEP24 s
JOIN stg_Units u
    ON s.Qube_Unit_ID = u.PMS_Reference__c
JOIN stg_Pricebooks pb
    ON pb.Name = 'ERV Sept 2024'
WHERE s.Qube_Unit_ID IS NOT NULL
  AND u.PMS_Reference__c IS NOT NULL
  AND u.Product__c IS NOT NULL;

INSERT INTO tgt_PBE_March25 (
Pricebook2Id,
Product2Id,
IsActive,
UnitPrice,
Rent_Periodicity__c
)
SELECT
    pb.Id AS Pricebook2Id,
    u.Product__c AS Product2Id,
    TRUE AS IsActive,
    s.ERV/12 AS UnitPrice,
    'Monthly' AS Rent_Periodicity__c
FROM stg_MARCH25 s
JOIN stg_Units u
    ON s.Qube_Unit_ID = u.PMS_Reference__c
JOIN stg_Pricebooks pb
    ON pb.Name = 'ERV March 2025'
WHERE s.Qube_Unit_ID IS NOT NULL
  AND u.PMS_Reference__c IS NOT NULL
  AND u.Product__c IS NOT NULL;

Select *
from tgt_PBE_SEP24

Select *
from tgt_PBE_March25



