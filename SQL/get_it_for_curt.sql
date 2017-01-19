--january 2010 tdm file
SELECT *
FROM MASTERM.QWEST_JANUARY_2010 calls
WHERE calls.prcmp_id =11
 and calls.component_group_cd = 'DL'
 and calls.ANI = 4068303002
 --january 2010 ip file
SELECT *
FROM MASTERM.QWEST_JANUARY_2010 calls
WHERE calls.prcmp_id =11
 and calls.component_group_cd = 'DL'
 and calls.ANI <> 4068303002
 
--december 2009 tdm file
SELECT *
FROM MASTERM.QWEST_DECEMBER_2009 calls
WHERE calls.prcmp_id =11
 and calls.component_group_cd = 'DL'
 and calls.ANI = 4068303002
 --december 2009 ip file
SELECT *
FROM MASTERM.QWEST_DECEMBER_2009 calls
WHERE calls.prcmp_id =11
 and calls.component_group_cd = 'DL'
 and calls.ANI <> 4068303002 

 --november 2009 tdm file
SELECT *
FROM MASTERM.QWEST_NOVEMBER_2009 calls
WHERE calls.prcmp_id =11
 and calls.component_group_cd = 'DL'
 and calls.ANI = 4068303002
--november 2009 ip file
SELECT *
FROM MASTERM.QWEST_NOVEMBER_2009 calls
WHERE calls.prcmp_id =11
 and calls.component_group_cd = 'DL'
 and calls.ANI <> 4068303002
--january 2010 toll free
SELECT *
FROM MASTERM.QWEST_JANUARY_2010 calls
WHERE calls.component_group_cd = 'IW'
--december 2009 toll free
 SELECT *
FROM MASTERM.QWEST_DECEMBER_2009 calls
WHERE calls.component_group_cd = 'IW'
--november 2009 toll free
 SELECT *
FROM MASTERM.QWEST_NOVEMBER_2009 calls
WHERE calls.component_group_cd = 'IW'
