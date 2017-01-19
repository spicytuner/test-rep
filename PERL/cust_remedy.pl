#!/usr/bin/perl

push(@INC, "/home/jsoria/SCRIPTS/PERL");
require 'serv_info.pl';

use DBI;
use strict;
use Spreadsheet::WriteExcel;

$ENV{'ORACLE_SID'}="remrep";
$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

#Define your variables
my($format,@database,$contact,$domain,$test,$usr,$passwd,$sid,
$test,$dbh,$sth,$host,$row,
$col1,$col2,$col3,$col4,$col5,$col6,$col7,$col8,$col9,$col10,
$col11,$col12,$col13,$col14,$col15,$col16,$col17,$col18,$col19,$col20,$col21,
$worksheet,
$qname,$workbook,$log,$log2,$sth4,$sth6,$sth7,$sth8,$sth9,$sth10,
$name,$status,$id,$owner,$timew,$timee,$timel,$lastu,$workbook2,
$worksheet,@data,$data,$sth2,$counts,$dcounts,$dname,$sth3,$subj,$fmt2,
$sth5,$cmmac,$node,$devtype,$n1,$n2,$n3,$n4,$mtamac,
$fname,$lname,$n5,$street1,$street2,$city,$state,$zip,$acct,$n6,$phone,
$n7,$cmsfqdn,$cmts,$n8,$prov);

$contact='jsoria';
$domain='bresnan.com';
$test='2';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);

$dbh = DBI->connect('dbi:Oracle:remrep',$usr,$passwd) || die "Cannot establish connection to the database";

$dbh->{RaiseError}=1;


##Define your queries
#
####################
####################
####################
####################

$sth5=$dbh->prepare(q{truncate table cust_auspice });
$sth5->execute();


$sth6=$dbh->prepare(q{insert into cust_remedy (
select distinct b.userid,
nvl(a.node,'undef') "NODE", b.firstname "FIRSTNAME",
b.lastname "LASTNAME",
b.phonenumber "PHONE", replace(b.streetaddress1,',','') "STREET1", replace(b.streetaddress2,',','') "STREET2",
b.city "CITY", b.state "STATE",
b.zipcode "ZIP", c.macaddressofcm "CMMAC", 'HSD & VOICE' "SERVICE_TYPE",
f.fqdnformta "MTAFQDN",
f.macaddressofmta "MTAMAC", f.cmsfqdn "CMSFQDN", c.vendor "MTA_VENDOR",
c.imagefile "IMAGEFILE",
g.locationname "CMTS",sysdate,0,1,1,''
from account_node_status a, pi b, hsd c, subscriberproxy d, subscriber e,
endpoint f, locationtree g
where b.userid=a.accountnumber(+)
and b.parentref=d.recordnumber
and d.recordnumber=c.parentref
and d.recordnumber=f.parentref
and b.deletestatus=0
and c.deletestatus=0
and f.deletestatus=0
and c.imagefile like '%VOIP%'
and c.imagefile not like '%ONLY%'
and c.imagefile not like '%Only%'
and d.recordnumber=e.recordnumber
and e.locationid=g.recordnumber
union
select distinct b.userid, nvl(a.node,'undef') "NODE",
b.firstname "FIRSTNAME",
b.lastname "LASTNAME",
b.phonenumber "PHONE", b.streetaddress1 "STREET1", b.streetaddress2 "STREET2",
b.city "CITY", b.state "STATE",
b.zipcode "ZIP", c.macaddressofcm "CMMAC", 'HSD' "SERVICE_TYPE",
'' "MTAFQDN",
'' "MTAMAC", '' "CMSFQDN", '' "MTA_VENDOR", c.imagefile "IMAGEFILE",
g.locationname "CMTS",sysdate,0,1,0,''
from account_node_status a, pi b, hsd c, subscriberproxy d, subscriber e,
locationtree g
where b.userid=a.accountnumber(+)
and b.parentref=d.recordnumber
and d.recordnumber=c.parentref
and b.deletestatus=0
and c.deletestatus=0
and c.imagefile not like '%VOIP%'
and d.recordnumber=e.recordnumber
and e.locationid=g.recordnumber
union
select distinct b.userid, nvl(a.node,'undef') "NODE",
b.firstname "FIRSTNAME",
b.lastname "LASTNAME",
b.phonenumber "PHONE", b.streetaddress1 "STREET1", b.streetaddress2 "STREET2",
b.city "CITY", b.state "STATE",
b.zipcode "ZIP", c.macaddressofcm "CMMAC", 'VOICE' "SERVICE_TYPE",
f.fqdnformta "MTAFQDN",
f.macaddressofmta "MTAMAC", f.cmsfqdn "CMSFQDN", c.vendor "MTA_VENDOR",
c.imagefile "IMAGEFILE",
g.locationname "CMTS",sysdate,0,0,1,''
from account_node_status a, pi b, hsd c, subscriberproxy d, subscriber e,
endpoint f, locationtree g
where b.userid=a.accountnumber(+)
and b.parentref=d.recordnumber
and d.recordnumber=c.parentref
and d.recordnumber=f.parentref
and b.deletestatus=0
and c.deletestatus=0
and f.deletestatus=0
and c.imagefile like '%VOIPO%'
and d.recordnumber=e.recordnumber
and e.locationid=g.recordnumber
)
});
$sth6->execute();

$sth7=$dbh->prepare(q{update cust_auspice set devicetype='MTA' where mtamac is not null});
$sth7->execute();

$sth8=$dbh->prepare(q{update cust_auspice set devicetype='CM' where devicetype is null});
$sth8->execute();

system("/home/oracle/OraHome1/bin/sqlplus $usr\/$passwd\@remrep \@/home/jsoria/SCRIPTS/PERL/auspice_data_by_prov.sql");
