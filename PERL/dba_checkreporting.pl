#!/usr/bin/perl

# Author: Joe Soria
# Date: July 30, 2007
#
# This script will alert when the freespace threashold is met.

push(@INC, "/home/jsoria/SCRIPTS/PERL");
require 'serv_info.pl';

use DBI;
use strict;

$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

#Define your variables
my(@database,$database,$contact,$domain,$test,$usr,$passwd,$sid,$dbh,$sth,$sth2,
$dbname,$tbspace,$EXIT,$data,$total,$free,$pctfree,$frags,$bfrag,$ntime);
 # Exit 0 = good 1 = critical
$EXIT = 0;
@database=qw(remrep);
$contact='jsoria';
$domain='bresnan.com';
$test='2';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);
print "\n";
foreach $database(@database) 
	{

	$dbh = DBI->connect("dbi:Oracle:$database",$usr,$passwd) || die "Cannot establish connection to the database";
	$dbh->{RaiseError}=1;

	$sth=$dbh->prepare(q{
	select name from v$database});
	$sth->execute();
	$sth->bind_columns({},\($dbname));
	
	$sth2=$dbh->prepare(q{select max(new_time(create_date,'GMT','MDT')),(sysdate-.05) from bz_incident_dat});
	$sth2->execute();
	$sth2->bind_columns({},\($data,$ntime));

	while ($sth->fetch)
		{
		if ($sth2->fetch)
			{
			if ($data < $ntime )
				{
				print STDOUT "Database: $dbname Reporting environment not updating correctly\n";
				$EXIT = 1;	
				}
				else
				{
				print STDOUT "$dbname Reporting environment is properly updated\n";
				print STDOUT "Last updated: $data\n";
				}
			}
		}
	}
exit($EXIT)

