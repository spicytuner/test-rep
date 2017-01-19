create table joe_test
(record_id	number(13),
fname		varchar2(20),
mname		varchar2(20),
lname		varchar2(20)) tablespace users;

insert into joe_test values (1,'Joe','','Soria');
insert into joe_test values (2,'Blake','','Williams');
insert into joe_test values (3,'Jason','','Robey');
insert into joe_test values (4,'Chris','','Owen');
insert into joe_test values (5,'Ned','','Bronson');
insert into joe_test values (6,'Crystal','','Hopper');
insert into joe_test values (7,'Joe','','Riebe');
insert into joe_test values (8,'Dan','','Dostal');
insert into joe_test values (9,'Rob','','Phair');
insert into joe_test values (10,'Bob','','Halstead');
commit;
