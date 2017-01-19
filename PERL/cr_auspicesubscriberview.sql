select distinct substr(a.cmmac, 1,2)||':'||substr(a.cmmac,3,2)||':'||
        substr(a.cmmac,5,2)||':'||substr(a.cmmac, 7,2)||':'||
        substr(a.cmmac,9,2)||':'||substr(a.cmmac,11,2) "CM_MAC_ADDRESS",
        a.firstname "FIRST_NAME", a.lastname "LAST_NAME", a.street1 "ADDRESS_LINE_1",
a.street2 "ADDRESS_LINE_2", a.city "CITY", a.state "STATE", a.zip "ZIP_CODE",
nvl(a.telephone_number,'0000000000') "TELEPHONE_NUM",
'MTA' "DEVICETYPE", substr(c.mtamac, 1,2)||':'||substr(c.mtamac,3,2)||':'||
        substr(c.mtamac,5,2)||':'||substr(c.mtamac, 7,2)||':'||
        substr(c.mtamac,9,2)||':'||substr(c.mtamac,11,2) "AGENT_MAC_ADDRESS", 
'a'||a.mtamac||'.dt.bresnan.net' "AGENT_FQDN",
null "CMS",c.cmts "CMTS", b.node "NODE", a.csg_act "ACCOUNT_NUM"
from vw_cust a, account_node_status b, cmmac_to_cmts c
where a.mtamac is not null
and a.csg_act=b.accountnumber
and lower(a.cmmac)=lower(c.cmmac)
union
select distinct substr(a.cmmac, 1,2)||':'||substr(a.cmmac,3,2)||':'||
        substr(a.cmmac,5,2)||':'||substr(a.cmmac, 7,2)||':'||
        substr(a.cmmac,9,2)||':'||substr(a.cmmac,11,2) "CM_MAC_ADDRESS",
        a.firstname "FIRST_NAME", a.lastname "LAST_NAME", a.street1 "ADDRESS_LINE_1",
a.street2 "ADDRESS_LINE_2", a.city "CITY", a.state "STATE", a.zip "ZIP_CODE",
nvl(a.telephone_number,'0000000000') "TELEPHONE_NUM",
'CM' "DEVICETYPE", null "AGENT_MAC_ADDRESS", null "AGENT_FQDN",
null "CMS",c.cmts "CMTS", b.node "NODE", a.csg_act "ACCOUNT_NUM"
from vw_cust a, account_node_status b, cmmac_to_cmts c
where a.mtamac is null
and a.csg_act=b.accountnumber
and lower(a.cmmac)=lower(c.cmmac)

