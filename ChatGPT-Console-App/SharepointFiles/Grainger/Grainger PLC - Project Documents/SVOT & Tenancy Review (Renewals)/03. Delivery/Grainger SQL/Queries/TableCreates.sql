--============================================================================================================================================--
------------------------------------------------------------------------------------------------------------------------------------------------
-- Staging Tables
------------------------------------------------------------------------------------------------------------------------------------------------
--============================================================================================================================================--


------------------------------------------------------------------------------------------------------------------------------------------------
-- stg_QubeActiveTenancies
------------------------------------------------------------------------------------------------------------------------------------------------
-- Taken From Qube Extract
------------------------------------------------------------------------------------------------------------------------------------------------

-- DROP TABLE IF EXISTS public.stg_QubeActiveTenancies;

CREATE TABLE IF NOT EXISTS public.stg_QubeActiveTenancies
(
    con_tran VARCHAR(255) COLLATE pg_catalog."default",
	Tenant_Reference VARCHAR(255) COLLATE pg_catalog."default",
	parent_reference VARCHAR(255) COLLATE pg_catalog."default",
    name VARCHAR(255) COLLATE pg_catalog."default",
    status VARCHAR(255) COLLATE pg_catalog."default",
    unit_reference Varchar(255) COLLATE pg_catalog."default",
    unit_status Varchar(255) COLLATE pg_catalog."default",
    unit_tenure Varchar(255) COLLATE pg_catalog."default",
	Unit_Type Varchar(255) COLLATE pg_catalog."default",
    tenancy_commenced date,
    tenancy_terminates Varchar(255) COLLATE pg_catalog."default",
    tenant_info Varchar(255) COLLATE pg_catalog."default",
    tenant_type Varchar(255) COLLATE pg_catalog."default",
    salesforce_unit_id Varchar(255) COLLATE pg_catalog."default",
	Start_Date date,
	End_Date date
)

select * from public.stg_QubeActiveTenancies;

------------------------------------------------------------------------------------------------------------------------------------------------
-- stg_Unit
------------------------------------------------------------------------------------------------------------------------------------------------
/*
Select id, Name from unit__c
*/
------------------------------------------------------------------------------------------------------------------------------------------------

-- DROP TABLE IF EXISTS public.stg_Unit;

CREATE TABLE IF NOT EXISTS public.stg_Unit
(
	id VARCHAR(18) Primary key,
	Name VARCHAR(55)
)

select * from public.stg_Unit;
------------------------------------------------------------------------------------------------------------------------------------------------
-- stg_Contacts
------------------------------------------------------------------------------------------------------------------------------------------------
/*
select id, AccountId
from Contact 
where AccountId != null
*/
------------------------------------------------------------------------------------------------------------------------------------------------

-- DROP TABLE IF EXISTS public.stg_Contacts;

CREATE TABLE IF NOT EXISTS public.stg_Contacts
(
	id character varying(255) COLLATE pg_catalog."default" NOT NULL,
	AccountId character varying(255) COLLATE pg_catalog."default" NOT NULL,
	CONSTRAINT contacts_pkey PRIMARY KEY (id)
)


select * from public.stg_Contacts;
------------------------------------------------------------------------------------------------------------------------------------------------
-- stg_Opportunities
------------------------------------------------------------------------------------------------------------------------------------------------
/*
select id, Primary_Offer__r.unit__c, Primary_Offer_Live_Unit__c, StageName, Move_In_Date__c, Tenancy_Type__c, Agreement_Type__c, CreatedDate,PMS_Reference__C
from Opportunity 
where 
(
Primary_Offer__c != null 
or 
Primary_Offer_Live_Unit__c != null
)
order by Primary_Offer__r.unit__c desc, Move_In_Date__c desc
*/
------------------------------------------------------------------------------------------------------------------------------------------------

-- DROP TABLE IF EXISTS public.stg_Opportunities;

CREATE TABLE IF NOT EXISTS stg_Opportunities (
    Id VARCHAR(18) PRIMARY KEY,  
    Primary_Offer__r VARCHAR(18),  
	Primary_Offer_Live_Unit__c VARCHAR(18), 
    StageName VARCHAR(50),  
    Move_In_Date__c DATE, 
    Tenancy_Type__c VARCHAR(50), 
    Agreement_Type__c VARCHAR(50),  
    CreatedDate TIMESTAMP,  
    PMS_Reference__c VARCHAR(50),
	Primary_Offer_Unit__c VARCHAR(18)
);

select * from public.stg_Opportunities;
------------------------------------------------------------------------------------------------------------------------------------------------
-- stg_Contracts
------------------------------------------------------------------------------------------------------------------------------------------------
/*
select id, Tenancy__c, Opportunity__c, PMS_Reference__c, AccountId, RecordTypeId, Unit__c, Status, Tenancy_Status__c,  
StartDate, EndDate, OwnerId, Agreement_Type__c, Document_Type__c, Memorandum_of_Agreement_Date__c, Actual_Move_Out_Date__c, 
Uplift_Percentage__c, Security_Deposit_Amount__c, Break_Clause__c, Special_Clauses__c, Special_Clause_Free_Text__c, 
Vehicle_Make__c, Vehicle_Model__c, Vehicle_Registration__c
from Contract
*/
------------------------------------------------------------------------------------------------------------------------------------------------

--DROP TABLE IF EXISTS public.stg_Contracts;

CREATE TABLE IF NOT EXISTS stg_Contracts (
    Id VARCHAR(18) PRIMARY KEY, 
    Tenancy__c VARCHAR(18), 
	Opportunity__c VARCHAR(18),
    PMS_Reference__c VARCHAR(50),
    AccountId VARCHAR(18), 
    RecordTypeId VARCHAR(18), 
    Unit__c VARCHAR(18), 
    Status VARCHAR(50),
	Tenancy_Status__c VARCHAR(50),
    StartDate DATE,
	EndDate DATE,
    OwnerId VARCHAR(18), 
    Agreement_Type__c VARCHAR(225), 
    Document_Type__c VARCHAR(225), 
    Memorandum_of_Agreement_Date__c DATE, 
    Actual_Move_Out_Date__c DATE, 
    Uplift_Percentage__c DECIMAL(5,2), 
    Security_Deposit_Amount__c DECIMAL(10,2), 
	Break_Clause__c VARCHAR(50),
	Special_Clauses__c VARCHAR(5000), 
	Special_Clause_Free_Text__c VARCHAR(5000), 
    Vehicle_Make__c VARCHAR(50), 
    Vehicle_Model__c VARCHAR(50), 
    Vehicle_Registration__c VARCHAR(50)
);

select * from public.stg_Contracts;
------------------------------------------------------------------------------------------------------------------------------------------------
-- stg_Agreements
------------------------------------------------------------------------------------------------------------------------------------------------
/*
select id, CreatedDate, echosign_dev1__Status__c, echosign_dev1__Contract__c, echosign_dev1__Opportunity__c, echosign_dev1__Opportunity__r.StageName, echosign_dev1__Opportunity__r.Tenancy__c, echosign_dev1__Opportunity__r.Tenancy__r.Status
from echosign_dev1__SIGN_Agreement__c 
where echosign_dev1__Opportunity__c !=null
and echosign_dev1__Opportunity__r.StageName  = 'Closed Won'
*/
------------------------------------------------------------------------------------------------------------------------------------------------

--DROP TABLE IF EXISTS public.stg_Agreements;

CREATE TABLE stg_Agreements (
    Id VARCHAR(50) PRIMARY KEY,
    CreatedDate TIMESTAMP,
    Status VARCHAR(50),
    ContractID VARCHAR(50),
    OpportunityId VARCHAR(50),
    Opportunity_StageName VARCHAR(50)
);

Select * from public.stg_Agreements;

------------------------------------------------------------------------------------------------------------------------------------------------
-- stg_EOT
------------------------------------------------------------------------------------------------------------------------------------------------
/*
select id, Status__c, Tenancy__c, Tenancy__r.Tenancy__c
from End_Of_Tenancy__c 
*/
------------------------------------------------------------------------------------------------------------------------------------------------

--DROP TABLE IF EXISTS public.stg_EOT;

CREATE TABLE stg_EOT (
    Id VARCHAR(50) PRIMARY KEY,
    Status__c VARCHAR(50),
    Tenancy__c VARCHAR(50)
);

Select * from public.stg_EOT;

------------------------------------------------------------------------------------------------------------------------------------------------
-- stg_Unit_dates
------------------------------------------------------------------------------------------------------------------------------------------------
/*
Unit Export From grainger
*/
------------------------------------------------------------------------------------------------------------------------------------------------

--DROP TABLE IF EXISTS public.stg_Unit_dates;

CREATE TABLE stg_Unit_dates (
	Reference VARCHAR(50) PRIMARY KEY,
	Unit__c VARCHAR(50),
	Description VARCHAR(50),
	StartDate DATE,
	EndDate DATE,
	Term_Years INT,
	Term_Months INT,
	Term_Days INT,
	Status VARCHAR(50),
	Tenure VARCHAR(50),
	Type VARCHAR(50)
);

Select * from public.stg_Unit_dates;

------------------------------------------------------------------------------------------------------------------------------------------------
-- stg_OCR
------------------------------------------------------------------------------------------------------------------------------------------------
/*
select id, OpportunityId, Tenancy__c, ContactId, Contact.FirstName, Contact.LastName, Role, Active__c
from OpportunityContactRole 
*/
------------------------------------------------------------------------------------------------------------------------------------------------

--DROP TABLE IF EXISTS public.stg_OCR;

CREATE TABLE stg_OCR (
	Id VARCHAR(50) PRIMARY KEY,
	OpportunityId VARCHAR(50),
	Tenancy__c VARCHAR(50),
	ContactId VARCHAR(50),
	Contact_FirstName VARCHAR(50),
	Contact_LastName VARCHAR(50),
	Role VARCHAR(50),
	Active__c VARCHAR(50)
);

Select * from public.stg_OCR;

--============================================================================================================================================--
------------------------------------------------------------------------------------------------------------------------------------------------
-- Target Tables
------------------------------------------------------------------------------------------------------------------------------------------------
--============================================================================================================================================--


------------------------------------------------------------------------------------------------------------------------------------------------
-- tgt_1_Tenancies
------------------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS public.tgt_1_Tenancies;

CREATE TABLE IF NOT EXISTS tgt_1_Tenancies (
    PMS_Reference__c VARCHAR(255) PRIMARY KEY,         
    accountid VARCHAR(255),               
    break_clause__c VARCHAR(100),          
    recordtypeid VARCHAR(50),              
    Unit__c VARCHAR(255),                 
    StartDate DATE,                    
    Tenancy_End_Date__c VARCHAR(255),
	status Varchar(255),
    Agreement_Type__c VARCHAR(100),        
    Description VARCHAR(255),
	_unit_rn int
	--opportunity__c VARCHAR(100)

);


------------------------------------------------------------------------------------------------------------------------------------------------
-- tgt_2_Contracts - 
------------------------------------------------------------------------------------------------------------------------------------------------

--DROP TABLE IF EXISTS public.tgt_2_Contracts;


CREATE TABLE IF NOT EXISTS tgt_2_Contracts (
    Id VARCHAR(18) PRIMARY KEY, 
    "Tenancy__r:Contract:PMS_Reference__c" VARCHAR(50),
	OwnerId VARCHAR(18), 
    AccountId VARCHAR(18), 
    RecordTypeId VARCHAR(18), 
    Unit__c VARCHAR(18), 
    Status VARCHAR(50),
	Tenancy_Status__c VARCHAR(50),
    StartDate DATE,
	Tenancy_End_Date__c DATE,
    Agreement_Type__c VARCHAR(225), 
    Document_Type__c VARCHAR(225), 
    Memorandum_of_Agreement_Date__c DATE, 
    Actual_Move_Out_Date__c DATE, 
    Uplift_Percentage__c DECIMAL(5,2), 
    Security_Deposit_Amount__c DECIMAL(10,2), 
	Break_Clause__c VARCHAR(50),
	Special_Clauses__c VARCHAR(5000), 
	Special_Clause_Free_Text__c VARCHAR(5000), 
    Vehicle_Make__c VARCHAR(50), 
    Vehicle_Model__c VARCHAR(50), 
    Vehicle_Registration__c VARCHAR(50),
	opportunity__c VARCHAR(50)
);



select * from sub_contracts
Select * from tgt_2_Contracts




------------------------------------------------------------------------------------------------------------------------------------------------
-- tgt_3_Opportunities
------------------------------------------------------------------------------------------------------------------------------------------------
-- DROP TABLE IF EXISTS public.tgt_3_Opportunities;

CREATE TABLE IF NOT EXISTS tgt_3_Opportunities (
	Id VARCHAR(18) PRIMARY KEY,
	"Tenancy__r:Contract:PMS_Reference__C" VARCHAR(18)
)
	
-- DROP TABLE IF EXISTS public.tgt_Opportunities;

------------------------------------------------------------------------------------------------------------------------------------------------
-- tgt_4_EOT
------------------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS public.tgt_4_EOT;

Create Table tgt_4_EOT (
	id VARCHAR(18) PRIMARY KEY,
	"Tenancy__r:Contract:PMS_Reference__C" VARCHAR(18)
);

------------------------------------------------------------------------------------------------------------------------------------------------
-- tgt_5_Tenancies
------------------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS public.tgt_5_Tenancies2;

CREATE TABLE IF NOT EXISTS tgt_5_Tenancies2 (
    PMS_Reference__c VARCHAR(255) PRIMARY KEY,         
    accountid VARCHAR(255),               
    break_clause__c VARCHAR(100),          
    recordtypeid VARCHAR(50),              
    Unit__c VARCHAR(255),                 
    StartDate DATE,  
	tenancy_end_date__c date,
    --_EndDate VARCHAR(255),
	status Varchar(255),
    Agreement_Type__c VARCHAR(100),
	Description character varying(255),
	_unit_rn int,
	--opportunity__c VARCHAR(100),
	ownerid VARCHAR(18), 
    document_type__c VARCHAR(225), 
    memorandum_of_agreement_date__c date,
    actual_move_out_date__c date,
    uplift_percentage__c numeric(5,2),
    security_deposit_amount__c numeric(10,2),
    special_clauses__c VARCHAR(5000),
    special_clause_free_text__c VARCHAR(5000),
    vehicle_make__c  VARCHAR(50),
    vehicle_model__c VARCHAR(50),
    vehicle_registration__c  VARCHAR(50)
);











