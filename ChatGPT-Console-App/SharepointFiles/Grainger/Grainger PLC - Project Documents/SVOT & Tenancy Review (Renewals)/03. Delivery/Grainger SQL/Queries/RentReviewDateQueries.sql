WITH extract_next_rr AS (
  SELECT
    rr.Unit__c,
    rr.Event_Date,
    ROW_NUMBER() OVER (PARTITION BY rr.Unit__c ORDER BY rr.Event_Date ASC) AS rn
  FROM stg_RentReview rr
  WHERE lower(rr.Include_Exclude) = 'include'
    AND rr.Event_Date > CURRENT_DATE
),
per_unit_next AS (
  SELECT Unit__c, Event_Date
  FROM extract_next_rr
  WHERE rn = 1
),
current_tenancy AS (
  SELECT t.ID, t.Unit__c
  FROM stg_Tenancy t
)

SELECT
  ct.ID            AS ID,
  ct.Unit__c       AS _unit_id,
  pun.Event_Date   AS Next_Rent_Review_Date__c
FROM current_tenancy ct
JOIN per_unit_next pun
  ON pun.Unit__c = ct.Unit__c
ORDER BY _unit_id;


WITH extract_next_rr AS (
  SELECT
    rr.Unit__c,
    rr.Event_Date,
    ROW_NUMBER() OVER (PARTITION BY rr.Unit__c ORDER BY rr.Event_Date ASC) AS rn
  FROM stg_RentReview rr
  WHERE lower(rr.Include_Exclude) = 'include'
    AND rr.Event_Date > CURRENT_DATE
),
per_unit_next AS (
  SELECT Unit__c, Event_Date
  FROM extract_next_rr
  WHERE rn = 1
),
current_tenancy AS (
  SELECT DISTINCT t.Unit__c
  FROM stg_Tenancy t
)
SELECT
  pun.Unit__c,
  pun.Event_Date AS next_rent_review_date
FROM per_unit_next pun
LEFT JOIN current_tenancy ct
  ON ct.Unit__c = pun.Unit__c
WHERE ct.Unit__c IS NULL
ORDER BY pun.Unit__c;



