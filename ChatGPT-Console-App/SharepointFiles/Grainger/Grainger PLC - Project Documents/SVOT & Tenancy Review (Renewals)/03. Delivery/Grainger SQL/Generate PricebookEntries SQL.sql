truncate table product2
truncate table pricebook2

-- paste from Excel file to insert into product2 and pricebook2

select 
	pb.composite_key__c as "Pricebook2:Pricebook2:Composite_Key__c", 
	--pb.Name, 
	--pb.effective_date__c, 
	0 as UnitPrice,
	p.id as Product2Id,
	'TRUE' as IsActive
from product2 p
inner join pricebook2 pb on 1=1
order by Product2Id