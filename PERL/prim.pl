#!/usr/bin/perl -w
#script: address.pl
#author: jsoria
#date: 02-15-2005
#
#This script will pull one of the following reports:
#
# 1> [-p] Associate a package with the given ip address
#
# 2> [-e] Supply an email list of all residential customers
#
# 3> [-r] Supply an email list of all primary residential customers
#
# 4> [-s] Supply a list of all static customers on a per market basis
#
#  usage: ./address -[eprs]
#

#push(@INC, "/home/jsoria");
require ('/home/jsoria/SCRIPTS/PERL/serv_info.pl');

use strict;
use DBI;

$ENV{'ORACLE_SID'}="samprd";
$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

my ($count,$emailid,$dbh,$sth,$DBI,$acctnum,$email,$owner,$status,$sql,$junk,$line);

#$emailid=$ARGV[0];
#chomp($emailid);

$dbh = DBI->connect( 'dbi:Oracle:samprd',
'masterm','mMmMbeeR',) || die "Database connection not made: $DBI::errstr";

#open (FILE, "/home/jsoria/SCRIPTS/PERL/vmail.txt");

open(LOG,">/home/jsoria/SCRIPTS/PERL/prim.log");

	$sql = qq{
	select count(a.recordnumber)
	from email a,subscriberproxy b, subscriber c, subscribertopackage d
	where a.parentref=b.recordnumber
	and b.recordnumber=c.recordnumber
	and d.parentref=c.recordnumber
	and a.isowner=1
	and a.deletestatus=0
	and c.deletestatus=0
	and d.deletestatus=0
	and (d.packageid like 'BOL%' or d.packageid like 'RES%')
	};
	$sth = $dbh->prepare($sql);
	$sth->execute();
	$sth->bind_columns(\$count);

	#print LOG "$sql\n";

	if ($sth->fetch() ) 
		{
		print LOG "Primary Residential Email Count:\n";
		print LOG "$count\n";
		}
close(LOG);

#system("/bin/mail -s \"Primary Residential Email Count\" jsoria\@bresnan.com < /home/jsoria/SCRIPTS/PERL/prim.log\n");
#system("/usr/bin/uuencode /home/jsoria/SCRIPTS/PERL/prim.log /tmp/prim.log \| /bin/mail -s \"Primary Residential Email Count\" jsoria\@bresnan.com joe_soria\@yahoo.com \n");
