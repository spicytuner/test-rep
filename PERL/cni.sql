truncate table cust_node_info_old;
insert into cust_node_info_old (select * from cust_node_info);
commit;
truncate table cust_node_info;
insert into cust_node_info (select distinct accountnumber,node from cust_node_info_old);
commit;
