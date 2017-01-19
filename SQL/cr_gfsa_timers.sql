create user gf_sa
identified by gf_sa
default tablespace users
temporary tablespace temp;

grant connect,resource to gf_sa;

connect as gf_sa identified as fg_sa;

CREATE TABLE EJB__TIMER__TBL (
CREATIONTIMERAW      NUMBER(19)    NOT NULL,
BLOB                 BLOB          NULL,
TIMERID              VARCHAR(256)  NOT NULL,
CONTAINERID          NUMBER(19)    NOT NULL,
OWNERID              VARCHAR(256)  NULL,
STATE                INTEGER NOT   NULL,
PKHASHCODE           INTEGER NOT   NULL,
INTERVALDURATION     NUMBER(19)    NOT NULL,
INITIALEXPIRATIONRAW NUMBER(19)    NOT NULL,
LASTEXPIRATIONRAW    NUMBER(19)    NOT NULL,
CONSTRAINT PK_EJB__TIMER__TBL PRIMARY KEY (TIMERID)
) tablespace users;

