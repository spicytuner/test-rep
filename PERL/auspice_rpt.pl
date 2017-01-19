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
open(FILE1,">/home/jsoria/SCRIPTS/DATA/missoula.csv");
open(FILE2,">/home/jsoria/SCRIPTS/DATA/cheyenne.csv");
open(FILE3,">/home/jsoria/SCRIPTS/DATA/billings.csv");
open(FILE4,">/home/jsoria/SCRIPTS/DATA/grandjunction.csv");

#define the sql
$sth=$dbh->prepare(q{select substr(cmmac, 1,2)||':'||substr(cmmac,3,2)||':'||substr(cmmac,5,2)||':'||
substr(cmmac, 7,2)||':'||substr(cmmac,9,2)||':'||substr(cmmac,11,2), node, devicetype, 
'','', '','',substr(mtamac, 1,2)||':'||substr(mtamac,3,2)||':'||substr(mtamac,5,2)||':'||
substr(mtamac, 7,2)||':'||substr(mtamac,9,2)||':'||substr(mtamac,11,2),
firstname, lastname, '',replace(street1,',',''), street2, city, state, 
zip, accountnumber, '', phone, '', cmsfqdn, a.cmts, '', b.prov
from cust a, cmts_to_prov b
where a.cmts=b.cmts(+)
and prov like 'mls%'
and a.mtamac is not null
union
select substr(cmmac, 1,2)||':'||substr(cmmac,3,2)||':'||substr(cmmac,5,2)||':'||
substr(cmmac, 7,2)||':'||substr(cmmac,9,2)||':'||substr(cmmac,11,2), node, devicetype,
'','', '','',
'',
firstname, lastname, '',replace(street1,',',''), street2, city, state,
zip, accountnumber, '', phone, '', cmsfqdn, a.cmts, '', b.prov
from cust a, cmts_to_prov b
where a.cmts=b.cmts(+)
and prov like 'mls%'
and a.mtamac is null
});

#execute it
$sth->execute;

#bind the results
$sth->bind_columns({}, \($cmmac,$node,$devtype,$n1,$n2,$n3,$n4,$mtamac,
$fname,$lname,$n5,$street1,$street2,$city,$state,$zip,$acct,$n6,$phone,
$n7,$cmsfqdn,$cmts,$n8,$prov));

#print the results to a file
while ($sth->fetch)
        {
	chomp($cmmac,$node,$devtype,$n1,$n2,$n3,$n4,$mtamac,$fname,$lname,$n5,$street1,$street2,$city,$state,$zip,$acct,$n6,$phone,$n7,$cmsfqdn,$cmts,$n8,$prov);
	print FILE1 "$cmmac,$node,$devtype,$n1,$n2,$n3,$n4,$mtamac,$fname,$lname,$n5,$street1,$street2,$city,$state,$zip,$acct,$n6,$phone,$n7,$cmsfqdn,$cmts,$n8,$prov\n";
	}
$sth->finish;

$sth2=$dbh->prepare(q{select substr(cmmac, 1,2)||':'||substr(cmmac,3,2)||':'||substr(cmmac,5,2)||':'||
substr(cmmac, 7,2)||':'||substr(cmmac,9,2)||':'||substr(cmmac,11,2), node, devicetype,
'','', '','',substr(mtamac, 1,2)||':'||substr(mtamac,3,2)||':'||substr(mtamac,5,2)||':'||
substr(mtamac, 7,2)||':'||substr(mtamac,9,2)||':'||substr(mtamac,11,2),
firstname, lastname, '',replace(street1,',',''), street2, city, state,
zip, accountnumber, '', phone, '', cmsfqdn, a.cmts, '', b.prov
from cust a, cmts_to_prov b
where a.cmts=b.cmts(+)
and prov like 'chy%'
and a.mtamac is not null
union
select substr(cmmac, 1,2)||':'||substr(cmmac,3,2)||':'||substr(cmmac,5,2)||':'||
substr(cmmac, 7,2)||':'||substr(cmmac,9,2)||':'||substr(cmmac,11,2), node, devicetype,
'','', '','',
'',
firstname, lastname, '',replace(street1,',',''), street2, city, state,
zip, accountnumber, '', phone, '', cmsfqdn, a.cmts, '', b.prov
from cust a, cmts_to_prov b
where a.cmts=b.cmts(+)
and prov like 'chy%'
and a.mtamac is null
});

$sth2->execute;
$sth2->bind_columns({}, \($cmmac,$node,$devtype,$n1,$n2,$n3,$n4,$mtamac,
$fname,$lname,$n5,$street1,$street2,$city,$state,$zip,$acct,$n6,$phone,
$n7,$cmsfqdn,$cmts,$n8,$prov));

#print the results to a file
while ($sth2->fetch)
        {
	chomp($cmmac,$node,$devtype,$n1,$n2,$n3,$n4,$mtamac,$fname,$lname,$n5,$street1,$street2,$city,$state,$zip,$acct,$n6,$phone,$n7,$cmsfqdn,$cmts,$n8,$prov);
	print FILE2 "$cmmac,$node,$devtype,$n1,$n2,$n3,$n4,$mtamac,$fname,$lname,$n5,$street1,$street2,$city,$state,$zip,$acct,$n6,$phone,$n7,$cmsfqdn,$cmts,$n8,$prov\n";
	}
$sth2->finish;

$sth3=$dbh->prepare(q{select substr(cmmac, 1,2)||':'||substr(cmmac,3,2)||':'||substr(cmmac,5,2)||':'||
substr(cmmac, 7,2)||':'||substr(cmmac,9,2)||':'||substr(cmmac,11,2), node, devicetype,
'','', '','',substr(mtamac, 1,2)||':'||substr(mtamac,3,2)||':'||substr(mtamac,5,2)||':'||
substr(mtamac, 7,2)||':'||substr(mtamac,9,2)||':'||substr(mtamac,11,2),
firstname, lastname, '',replace(street1,',',''), street2, city, state,
zip, accountnumber, '', phone, '', cmsfqdn, a.cmts, '', b.prov
from cust a, cmts_to_prov b
where a.cmts=b.cmts(+)
and prov like 'bl%'
and a.mtamac is not null
union
select substr(cmmac, 1,2)||':'||substr(cmmac,3,2)||':'||substr(cmmac,5,2)||':'||
substr(cmmac, 7,2)||':'||substr(cmmac,9,2)||':'||substr(cmmac,11,2), node, devicetype,
'','', '','',
'',
firstname, lastname, '',replace(street1,',',''), street2, city, state,
zip, accountnumber, '', phone, '', cmsfqdn, a.cmts, '', b.prov
from cust a, cmts_to_prov b
where a.cmts=b.cmts(+)
and prov like 'bl%'
and a.mtamac is null
});

$sth3->execute;
$sth3->bind_columns({}, \($cmmac,$node,$devtype,$n1,$n2,$n3,$n4,$mtamac,
$fname,$lname,$n5,$street1,$street2,$city,$state,$zip,$acct,$n6,$phone,
$n7,$cmsfqdn,$cmts,$n8,$prov));

while ($sth3->fetch)
        {
	chomp($cmmac,$node,$devtype,$n1,$n2,$n3,$n4,$mtamac,$fname,$lname,$n5,$street1,$street2,$city,$state,$zip,$acct,$n6,$phone,$n7,$cmsfqdn,$cmts,$n8,$prov);
	print FILE3 "$cmmac,$node,$devtype,$n1,$n2,$n3,$n4,$mtamac,$fname,$lname,$n5,$street1,$street2,$city,$state,$zip,$acct,$n6,$phone,$n7,$cmsfqdn,$cmts,$n8,$prov\n";
        }
$sth3->finish;

$sth4=$dbh->prepare(q{select substr(cmmac, 1,2)||':'||substr(cmmac,3,2)||':'||substr(cmmac,5,2)||':'||
substr(cmmac, 7,2)||':'||substr(cmmac,9,2)||':'||substr(cmmac,11,2), node, devicetype,
'','', '','',substr(mtamac, 1,2)||':'||substr(mtamac,3,2)||':'||substr(mtamac,5,2)||':'||
substr(mtamac, 7,2)||':'||substr(mtamac,9,2)||':'||substr(mtamac,11,2),
firstname, lastname, '',replace(street1,',',''), street2, city, state,
zip, accountnumber, '', phone, '', cmsfqdn, a.cmts, '', b.prov
from cust a, cmts_to_prov b
where a.cmts=b.cmts(+)
and prov like 'g%'
and a.mtamac is not null
union
select substr(cmmac, 1,2)||':'||substr(cmmac,3,2)||':'||substr(cmmac,5,2)||':'||
substr(cmmac, 7,2)||':'||substr(cmmac,9,2)||':'||substr(cmmac,11,2), node, devicetype,
'','', '','',
'',
firstname, lastname, '',replace(street1,',',''), street2, city, state,
zip, accountnumber, '', phone, '', cmsfqdn, a.cmts, '', b.prov
from cust a, cmts_to_prov b
where a.cmts=b.cmts(+)
and prov like 'g%'
and a.mtamac is null
});

$sth4->execute;
$sth4->bind_columns({}, \($cmmac,$node,$devtype,$n1,$n2,$n3,$n4,$mtamac,
$fname,$lname,$n5,$street1,$street2,$city,$state,$zip,$acct,$n6,$phone,
$n7,$cmsfqdn,$cmts,$n8,$prov));

while ($sth4->fetch)
        {
	chomp($cmmac,$node,$devtype,$n1,$n2,$n3,$n4,$mtamac,$fname,$lname,$n5,$street1,$street2,$city,$state,$zip,$acct,$n6,$phone,$n7,$cmsfqdn,$cmts,$n8,$prov);
	print FILE4 "$cmmac,$node,$devtype,$n1,$n2,$n3,$n4,$mtamac,$fname,$lname,$n5,$street1,$street2,$city,$state,$zip,$acct,$n6,$phone,$n7,$cmsfqdn,$cmts,$n8,$prov\n";
        }
$sth4->finish;

close(FILE1);
close(FILE2);
close(FILE3);
close(FILE4);