#!/usr/bin/perl

# Author: Joe Soria
# Date: July 23, 2007
#
# This script will alert when the freespace threashold is met.

push(@INC, "/home/jsoria/SCRIPTS/PERL");
require 'serv_info.pl';

use DBI;
use strict;

$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

#Define your variables
my(@database,$database,$contact,$domain,$diff,$test,$usr,$passwd,$sid,$dbh,$sth,$sth2,
$dbname,$job,$what,$EXIT);
 # Exit 0 = good 1 = critical
$EXIT = 0;
@database=qw(remrep);
$contact='jsoria';
$domain='bresnan.com';
$test='2';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);

foreach $database(@database) 
	{

	$dbh = DBI->connect("dbi:Oracle:$database",$usr,$passwd) || die "Cannot establish connection to the database";
	$dbh->{RaiseError}=1;

	$sth=$dbh->prepare(q{select max(create_date)-sysdate from bz_incident_dat});
	$sth->execute();
	$sth->bind_columns({},\($diff));

	while ($sth->fetch)
		{
		if ($diff =~ '-')
			{
			print STDOUT "REMREP.MASTERM.BZ_INCIDENT_DAT: has not updated in $diff\n";
			$EXIT = 1;	
			}
		}
	}
exit($EXIT)

