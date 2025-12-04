--Drop Table If Exists stg_PBI_Data;

Create Table if not exists stg_PBI_Data
(	
	Unit__c VARCHAR(50),
	FromDate DATE,
	ToDate DATE, 
	PriceBookValue DECIMAL(10,6),
	PRIMARY KEY (Unit__c, FromDate)
);

-- Select * from stg_PBI_Data

/*
Select id, PMS_Reference__c, Product__c
from Unit__c 
where PMS_Reference__c != null
*/

--Drop table if exists stg_UnitProducts;

Create Table if not exists stg_UnitProducts
(	
	Unit__c VARCHAR(50),
	PMS_Reference__c VARCHAR(50),
	Product__c VARCHAR(50), 
	PRIMARY KEY (Unit__c)
);

-- Select * from stg_UnitProducts

/*
Select id, Name, Effective_Date__c
from Pricebook2 
where IsActive = true
and Type__c = 'Price Book Rent'
*/

--Drop table if exists stg_Pricebooks;

Create Table stg_Pricebooks
(	
	id VARCHAR(50),
	Name VARCHAR(255),
	Effective_Date__c Date, 
	PRIMARY KEY (id)
);


/*
	select Id, Pricebook2Id, Product2Id
	from PricebookEntry 
	where Pricebook2.Type__c = 'Price Book Rent'
	and IsActive = true
*/

-- Drop Table if Exists stg_PBE

Create Table IF Not Exists stg_PBE
(
	id VARCHAR(50),
	Pricebook2Id VARCHAR(50),
	Product2Id VARCHAR(50),
	PRIMARY KEY (id)
);