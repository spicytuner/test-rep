LOAD DATA
INFILE 'A72419843.DAT'
INTO TABLE QWEST_MAY_2014
FIELDS TERMINATED BY ','
TRAILING NULLCOLS
(
CALL_SERVICE_TYPE position(1:2) char
,COMPONENT_GROUP_CD position(3:4) char
,COMPONENT_GRP_VAL position(5:28) char
,PRODUCT_ACCT_ID position(29:40) char
,CUSTOMER_NUMBER position(41:50) char
,ORIG_DT position(51:58) char
,DISCN_DT position(59:66) char
,ORIG_TIME position(67:72) char
,DISCN_TIME position(73:78) char
,CALL_DURATION_MINUTES position(79:83) char
,CALL_DURATION_SECONDS position(84:85) char
,DIALEDNO position(86:100) char
,CALLEDNO position(101:115) char
,ANI position(116:130) char
,ANSTYPE position(131:136) char
,PINDIGS position(137:140) char
,INFODIG position(141:142) char
,SURCHARGE position(143:143) char
,COMPCODE position(144:149) char
,PREDIG position(150:150) char
,TRTMTCD position(151:156) char
,ORIG_TRUNK_GROUP_NAME position(157:168) char
,ORIGMEM position(169:174) char
,TERM_TRUNK_GROUP_NAME position(175:186) char
,TERMMEM position(187:192) char
,INTRA_LATA_IND position(193:193) char      
,CALL_AREA position(194:194) char
,CITY_CALLING position(195:204) char
,STATE_CALLING position(205:206) char
,CITY_CALLED position(207:216) char
,STATE_CALLED position(217:218) char
,RATE_PERIOD position(219:219) char
,TERMINATING_COUNTRY_CODE position(220:223) char
,ORIGINATING_COUNTRY_CODE position(224:227) char
,PAC_CODES position(228:239) char
,ORIG_PRICING_NPA position(240:242) char
,ORIG_PRICING_NXX position(243:245) char
,TERM_PRICING_NPA position(246:248) char
,TERM_PRICING_NXX position(249:251) char
,AUTHORIZATION_CODE_FULL position(252:265) char
,UNIVACC position(266:275) char
,PRCMP_ID position(276:281) char
,CARRSEL position(282:282) char
,CIC position(283:288) char                  
,ORIGLRN position(289:298) char
,PORTEDNO position(299:308) char
,LNPCHECK position(309:309) char            
,ORIGINATING_IDDD_CITY_CODE position(310:310) char
,TERMINATING_IDDD_CITY_CODE position(318:325) char
,ORIGINATING_LATA position(326:329) char
,TERMINATING_LATA position(330:333) char
,CLASS_TYPE position(334:335) char
,MEXICO_RATE_STEP position(336:337) char
,ESTIMATED_CHARGE position(338:343) char
,BILLING_OCN position(344:347) char
,ORIG_TERM_CODE position(348:348) char
,CLGPTYNO position(349:363) char
,CLGPTYNO_IDENTIFIER position(364:364) char
,ORIG_OCN position(365:368) char
,TERM_OCN position(369:372) char
,UNROUNDED_PRICE position(373:382) char
,RATE_PER_MINUTE position(383:390) char
,FINSID position(391:396) char
,FINAL_TRUNK_GROUP_NAME position(397:408) char
,CARRIAGE_RETURN position(409:409)
)
