select count(*) from
(select USERID from pi
where deletestatus=0
and USERID like '8313%'
minus
select account_number from subscriber_details_info
where account_number like '8313%');
