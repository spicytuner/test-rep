select a.csg_act,b.status, a.act_status,a.firstname,a.lastname,
        a.telephone_number, a.street1, a.street2, a.city, a.state, a.zip, a.cmmac, a.service_type,
        a.mtamac,a.vendor,a.mta_fqdn
        from vw_cust a, account_node_status b
        where lower(a.cmmac) = '&mac'
        and a.csg_act=b.accountnumber;
