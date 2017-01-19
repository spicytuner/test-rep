select substr(c.mtamac, 1,2)||':'||substr(c.mtamac,3,2)||':'||
        substr(c.mtamac,5,2)||':'||substr(c.mtamac, 7,2)||':'||
        substr(c.mtamac,9,2)||':'||substr(c.mtamac,11,2) "AGENT_MAC_ADDRESS"
from cmmac_to_cmts c;
