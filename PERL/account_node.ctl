LOAD DATA
INFILE sub2node.dat
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
