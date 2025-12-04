-- Drop table IF Exists public.stg_TenancyUnits;

/*
select id, Unit__c
from contract
where RecordType.name = 'Residential Tenancy'
and Tenancy_Status__c = 'Current'
and Unit__c != null
*/

Create TABLE IF NOT EXISTS public.stg_TenancyUnits
(
    ID Varchar(18) COLLATE pg_catalog."default",
    Unit__c Varchar(18),
	CONSTRAINT contacts_pkey PRIMARY KEY (id)

);

-- Drop table IF Exists public.stg_Tenancy;

/*
select id, Unit__c, StartDate, Tenancy_End_Date__c
from contract
where RecordType.name = 'Residential Tenancy'
and Tenancy_Status__c = 'Current'
and Unit__c != null
*/

Create TABLE IF NOT EXISTS public.stg_Tenancy
(
    ID Varchar(18) COLLATE pg_catalog."default",
    Unit__c Varchar(18),
	StartDate Date,
	EndDate Date,
	CONSTRAINT contacts_pkey2 PRIMARY KEY (id)

);

-- Drop table IF Exists stg_RentReview;

Create Table IF NOT EXISTS stg_RentReview
(
    Unit_Reference Varchar(255),
	Unit__c	Varchar(255),
	Unit_Description Varchar(255),
	Event Varchar(255),
	Action_Date Date,
	Event_Date Date,
	Status Varchar(255),	
	Attention_Of Varchar(255),	
	Unit_Tenure Varchar(255),	
	Unit_Type Varchar(255),	
	Unit_Status Varchar(255),	
	Include_Exclude Varchar(255),	
	Multiple_Rent_Review_Diary Varchar(255),
	Comment Varchar(255)
);

