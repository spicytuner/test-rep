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
my(@database,$database,$contact,$domain,$procs,$test,$usr,$passwd,$sid,$dbh,$sth,$sth2,
$dbname,$job,$what,$EXIT);
 # Exit 0 = good 1 = critical
$EXIT = 0;
@database=('smpprd','remrep','remprd');
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

	$sth=$dbh->prepare(q{
	select name from v$database});
	$sth->execute();
	$sth->bind_columns({},\($dbname));
	
	$sth2=$dbh->prepare(q{
	select to_number(a.value)-to_number(count(b.pid))
	from v$parameter a, v$process b
	where a.name='processes'
	group by a.value
	order by a.value
	});
	$sth2->execute();
	$sth2->bind_columns({},\($procs));

	while ($sth->fetch)
		{
		while ($sth2->fetch)
			{
		 	print STDOUT "$database Available Process Count: $procs\n";
			if ($procs < 20)
			{
			print STDOUT "Database: $dbname is approaching its process limit  current process count: $procs\n";
			$EXIT = 1;	
			}
			}
		}
	}
exit($EXIT)

