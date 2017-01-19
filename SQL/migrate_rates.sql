insert into rate_plan_entry (lata,class,rate,rate_plan_id,type) 
select NULL,1,class1,2,'Interstate'
	from interstate_billing_rates
union
select NULL,2,class2,2,'Interstate'
	from interstate_billing_rates
union
select NULL,3,class3,2,'Interstate'
	from interstate_billing_rates
union
select NULL,4,class4,2,'Interstate'
	from interstate_billing_rates
union
select NULL,5,class5,2,'Interstate'
	from interstate_billing_rates
union
select NULL,6,class6,2,'Interstate'
	from interstate_billing_rates
union
select NULL,1,class1,2,'Intrastate'
	from intrastate_billing_rates
union
select NULL,4,class4,2,'Intrastate'
	from intrastate_billing_rates
union
select NULL,5,class5,2,'Intrastate'
	from intrastate_billing_rates
union
select NULL,6,class6,2,'Intrastate'
	from intrastate_billing_rates
;
