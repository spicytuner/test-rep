/*==============================================================*/
/* Database name:  CUST REDESIGN                                */
/* DBMS name:      ORACLE Version 8i2 (8.1.6)                   */
/* Created on:     9/18/2007 1:50:33 PM                         */
/*==============================================================*/


drop index RLSH_1_FK
/


drop table VIDEO_INFO cascade constraints
/


drop table TECH_INFO cascade constraints
/


drop index RLSH_2_FK
/


drop table HSI_INFO cascade constraints
/


drop table CUSTOMER_INFO cascade constraints
/


/*==============================================================*/
/* Table : CUSTOMER_INFO                                        */
/*==============================================================*/


create table CUSTOMER_INFO  (
   ACCOUNTNUMBER        VARCHAR2(20)                     not null,
   NODE                 VARCHAR2(10),
   FIRSTNAME            VARCHAR2(50),
   LASTNAME             VARCHAR2(50),
   PHONE                VARCHAR2(24),
   STREET1              VARCHAR2(50),
   STREET2              VARCHAR2(50),
   CITY                 VARCHAR2(25),
   STATE                VARCHAR2(2),
   ZIP                  VARCHAR2(10),
   LAT                  NUMBER(10,6),
   LNG                  NUMBER(10,6),
   DEPTH                NUMBER(10,6),
   LAST_CHANGED         DATE,
   constraint PK_CUSTOMER_INFO primary key (ACCOUNTNUMBER)
)
/


/*==============================================================*/
/* Table : HSI_INFO                                             */
/*==============================================================*/


create table HSI_INFO  (
   CUS_ACCOUNTNUMBER    VARCHAR2(20)                     not null,
   SERVICE_TYPE         VARCHAR2(11),
   CMMAC                VARCHAR2(12)                     not null,
   MTAMAC               VARCHAR2(12),
   MTAFQDN              VARCHAR2(255),
   CMSFQDN              VARCHAR2(255),
   CM_VENDOR            VARCHAR2(255),
   IMAGEFILE            VARCHAR2(50),
   CMTS                 VARCHAR2(35),
   PACKAGEID            VARCHAR2(50),
   EMAIL                VARCHAR2(50),
   LAST_CHANGED         DATE,
   constraint PK_HSI_INFO primary key (CUS_ACCOUNTNUMBER, CMMAC),
   constraint FK_HSI_INFO_REFERENCE_CUSTOMER foreign key (CUS_ACCOUNTNUMBER)
         references CUSTOMER_INFO (ACCOUNTNUMBER)
)
/


/*==============================================================*/
/* Table : TECH_INFO                                            */
/*==============================================================*/


create table TECH_INFO  (
   CUS_ACCOUNTNUMBER    VARCHAR2(20)                     not null,
   TECH_ID              varchar2(20),
   TECH_NAME            varchar2(50),
   TECH_COMPANY         varchar2(50),
   LAST_EQUIPMENT_CHANGE DATE                             not null,
   constraint PK_TECH_INFO primary key (CUS_ACCOUNTNUMBER, LAST_EQUIPMENT_CHANGE),
   constraint FK_TECH_INF_REFERENCE_CUSTOMER foreign key (CUS_ACCOUNTNUMBER)
         references CUSTOMER_INFO (ACCOUNTNUMBER)
)
/


/*==============================================================*/
/* Table : VIDEO_INFO                                           */
/*==============================================================*/


create table VIDEO_INFO  (
   CUS_ACCOUNTNUMBER    VARCHAR2(20)                     not null,
   UNIT_ID              VARCHAR2(20)                     not null,
   SERIAL_ID            VARCHAR2(20),
   MODEL_NUMBER         VARCHAR2(20),
   LAST_CHANGED         DATE,
   constraint PK_VIDEO_INFO primary key (CUS_ACCOUNTNUMBER, UNIT_ID),
   constraint FK_VIDEO_IN_REFERENCE_CUSTOMER foreign key (CUS_ACCOUNTNUMBER)
         references CUSTOMER_INFO (ACCOUNTNUMBER)
)
/


