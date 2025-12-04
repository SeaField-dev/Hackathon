WITH PBI_with_Pricebook AS (
  SELECT 
    p.Unit__c AS Qube_Unit_ID,
    up.Product__c,
    p.FromDate,
    p.ToDate,
    ROUND(p.PriceBookValue, 2) AS Rent_Default,
    pb.id AS Pricebook2Id,
    pb.Name AS Pricebook_Name,
    pb.Effective_Date__c AS Pricebook_Effective_Date,
    ROW_NUMBER() OVER (
      PARTITION BY p.Unit__c, p.FromDate 
      ORDER BY pb.Effective_Date__c DESC
    ) AS rn
  FROM stg_PBI_Data p 
  JOIN stg_UnitProducts up
    ON p.Unit__c = up.PMS_Reference__c  -- Map using PMS Reference
  JOIN stg_Pricebooks pb
    ON pb.Effective_Date__c <= p.FromDate
)

SELECT 
  Product__c as Product2Id,
  Pricebook2Id,
  Rent_Default AS UnitPrice,
  'Monthly' AS Rent_Periodicity__c,
  TRUE AS IsActive
FROM PBI_with_Pricebook
WHERE rn = 1
ORDER BY Product__c, FromDate;

-- Combine both diagnostics into one report
WITH Missing_Unit AS (
  SELECT 
    p.Unit__c AS Qube_Unit_ID,
    NULL AS Product__c,
    p.FromDate,
    p.ToDate,
    p.PriceBookValue,
    'No match in stg_UnitProducts (via PMS_Reference__c)' AS Reason
  FROM stg_PBI_Data p
  LEFT JOIN stg_UnitProducts up
    ON p.Unit__c = up.PMS_Reference__c
  WHERE up.Unit__c IS NULL
),
Missing_Pricebook AS (
  SELECT 
    p.Unit__c AS Qube_Unit_ID,
    up.Product__c,
    p.FromDate,
    p.ToDate,
    p.PriceBookValue,
    'No pricebook with Effective_Date__c <= FromDate' AS Reason
  FROM stg_PBI_Data p
  JOIN stg_UnitProducts up
    ON p.Unit__c = up.PMS_Reference__c
  LEFT JOIN stg_Pricebooks pb
    ON pb.Effective_Date__c <= p.FromDate
  WHERE pb.id IS NULL
)
SELECT * FROM Missing_Unit
UNION ALL
SELECT * FROM Missing_Pricebook
ORDER BY FromDate;



