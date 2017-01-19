LOAD DATA
INFILE cust_remedy.dat
INTO TABLE CUST_OLD append
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
cust_id sequence,
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
LAST_CHANGED date "MM/DD/YYYY",
VIDEO,
DATA,
BDP,
UNIT_ID,
SERIAL_ID,
EMAIL
)
