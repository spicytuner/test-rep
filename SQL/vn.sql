select c.account, c.node, b.node_name
from Inventory.cm a, Inventory.node b, jbis.modem
where a.node_id=b.node_id
and c.cm_mac=a.cm_mac
into /tmp/acct_node_node.lst;
