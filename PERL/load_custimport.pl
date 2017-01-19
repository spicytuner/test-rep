#!/usr/bin/perl
#
# This script is used to populate the appropriate cust table with csg
# data.
##First you need to take the contents of the file from the csgdump directory
use strict;
use DBI;

my($line,$dbh,$sql,$sql1,$sql2,$sth,$sth1,$sth2,$sql3,$sth3,$sql4,$sth4,$lcnt,$sql5,$sth5,$email,
$acct,$node,$fname,$lname,$phone,$s1,$s2,$city,$st,$zip,$lcd,$status,$vid,$data,$bdp,$dctunitid,$dctserialid);

$ENV{'ORACLE_SID'}="remprd";
$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

$dbh = DBI->connect( 'dbi:Oracle:remprd',
'masterm','mMmMbeeR',) || die "Database connection not made: $DBI::errstr";

open(FILE,"/home/jsoria/SCRIPTS/PERL/Cust_Import.csv");
open(FILE2,">/home/jsoria/SCRIPTS/PERL/cust_remedy.dat");

while ($line=<FILE>)
{
$line=~ s/\'//g;
$line=~ s/\015//g;
$line=~ s/ \"/\"/g;
$line=~ s/\*//g;
$line=~ s/\'//g;
($acct,$node,$fname,$lname,$phone,$s1,$s2,$city,$st,$zip,$lcd,$status,$vid,$data,$bdp,$dctunitid,$dctserialid,$email)=split(/,/,$line);
print FILE2 "$acct,$node,$fname,$lname,$phone,$s1,$s2,$city,$st,$zip,$lcd,$vid,$data,$bdp,$dctunitid,$dctserialid,$email\n";
}

close(FILE);
close(FILE2);

#Load data into cust_import

#system("/home/oracle/OraHome1/bin/sqlldr masterm/mMmMbeeR\@remrep control=/home/jsoria/SCRIPTS/PERL/cust_import.ctl errors=50000 log=error.log skip=1");
system("/home/oracle/OraHome1/bin/sqlldr masterm/mMmMbeeR\@remprd control=/home/jsoria/SCRIPTS/PERL/cust_import.ctl errors=50000 log=remprderror.log");


