LOAD DATA
INFILE video.dat
INTO TABLE VIDEO_INFO append
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
CUS_ACCOUNTNUMBER,
UNIT_ID,
SERIAL_ID,
model_number,
LAST_CHANGED date "MM/DD/YYYY"
)
