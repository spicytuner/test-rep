#!/usr/bin/perl
#
# This script is used to populate the appropriate cust table with csg
# data.
##First you need to take the contents of the file from the csgdump directory
use strict;
use DBI;

my($line,$dbh,$sql,$sql1,$sql2,$sth,$sth1,$sth2,$sql3,$sth3,$sql4,$sth4,$lcnt,$sql5,$sth5,$email,
$acct,$node,$fname,$lname,$phone,$s1,$s2,$city,$st,$zip,$lcd,$status,$vid,$data,$bdp,$dctunitid,
$j1,$j2,$j3,$j4,$j5,$j6,$j7,$j8,$j9,$j10,$j11,$j12,$j13,$j14,$j15,$j16,$dctserialid,$modelname);

$ENV{'ORACLE_SID'}="remdev";
$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

$dbh = DBI->connect( 'dbi:Oracle:remdev',
'masterm','mMmMbeeR',) || die "Database connection not made: $DBI::errstr";

open(FILE,"/home/jsoria/SCRIPTS/PERL/CI.csv");
open(FILE2,">/home/jsoria/SCRIPTS/PERL/video.dat");

while ($line=<FILE>)
{
$line=~ s/\'//g;
$line=~ s/\015//g;
$line=~ s/ \"/\"/g;
$line=~ s/\*//g;
$line=~ s/\'//g;
($acct,$j1,$j2,$j3,$j4,$j5,$j6,$j7,$j8,$j9,$lcd,$j10,$j11,$j12,$j13,$j14,$j15,$dctunitid,$dctserialid,$modelname,$j16)=split(/,/,$line);
if ($dctunitid)
{
print FILE2 "$acct,$dctunitid,$dctserialid,$modelname,$lcd\n";
}
}

close(FILE);
close(FILE2);

#Load data into video_info

system("/home/oracle/OraHome1/bin/sqlldr masterm/mMmMbeeR\@remdev control=/home/jsoria/SCRIPTS/PERL/videoinfo.ctl errors=50000 log=remprderror.log");


