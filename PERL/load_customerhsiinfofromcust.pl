#!/usr/bin/perl
#
# This script is used to populate the appropriate cust table with csg
# data.
##First you need to take the contents of the file from the csgdump directory
use strict;
use DBI;

my($line,$dbh,$dbh2,$sql,$sql1,$sql2,$sth,$sth1,$sth2,$sql3,$sth3,$sql4,$sth4,$lcnt,$sql5,$sth5,
$acct,$stype,$cmmac,$mtamac,$mfqdn,$cfqdn,$cvendor,$ifile,$cmts,$pkg,$email,$lcd);

$ENV{'ORACLE_SID'}="remdev";
$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

$dbh = DBI->connect( 'dbi:Oracle:remdev',
'masterm','mMmMbeeR',) || die "Database connection not made: $DBI::errstr";

$dbh2 = DBI->connect( 'dbi:Oracle:remrep',
'masterm','mMmMbeeR',) || die "Database connection not made: $DBI::errstr";

open(FILE,">/home/jsoria/SCRIPTS/PERL/hsiinfo.dat");

$sth=$dbh2->prepare(q{select accountnumber, service_type, cmmac, mtamac, mtafqdn,
cmsfqdn,mta_vendor,imagefile,cmts,packageid,last_changed
from cust});
$sth->execute();
$sth->bind_columns({},\($acct,$stype,$cmmac,$mtamac,$mfqdn,$cfqdn,$cvendor,$ifile,$cmts,$pkg,$lcd));


while ($sth->fetch)
{
print FILE "$acct,$stype,$cmmac,$mtamac,$mfqdn,$cfqdn,$cvendor,$ifile,$cmts,$pkg,$lcd\n";
}

close(FILE);

#Load data into video_info

system("/home/oracle/OraHome1/bin/sqlldr masterm/mMmMbeeR\@remdev control=/home/jsoria/SCRIPTS/PERL/hsiinfo.ctl errors=50000 log=hsiinfo.log");


