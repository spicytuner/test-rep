LOAD DATA
INFILE cust_remedy.dat
INTO TABLE CUSTOMER_INFO append
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
ACCOUNTNUMBER,
NODE,
LASTNAME,
FIRSTNAME,
PHONE,
STREET1,
STREET2,
CITY,
STATE,
ZIP,
LAST_CHANGED date "MM/DD/YYYY hh24:mi:ss"
)
