LOAD DATA
INFILE ACCOUNT_NODE_STATUS.txt
INTO TABLE account_node_status insert
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
accountnumber,
node,
last_modified,
status,
macaddress
)
