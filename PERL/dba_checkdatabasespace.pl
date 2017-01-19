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
my($database,@tablespace,$tablespace,$tblspace,$segment,$contact,$domain,$test,$usr,$passwd,$sid,$dbh,$sth,$sth2,
$dbname,$tbspace,$EXIT,$total,$free,$pctfree,$frags,$bfrag,$segname,$freesp,$nextext,$largest);
 # Exit 0 = good 1 = critical
$EXIT = 0;
@tablespace=qw(METASERV31_DATA METASERV31_IDX METASERV31AZR_DATA METASERV31AZR_IDX);

$contact='jsoria';
$domain='bresnan.com';
$test='2';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);
print "\n";
foreach $tablespace(@tablespace) 
	{

	$dbh = DBI->connect("dbi:Oracle:<enter database name here>",$usr,$passwd) || die "Cannot establish connection to the database";
	$dbh->{RaiseError}=1;

	$sth=$dbh->prepare(q{
	select name from v$database});
	$sth->execute();
	$sth->bind_columns({},\($dbname));

print STDOUT "Checking tablespaces in tablespace: $dbname\n";
	
	$sth2=$dbh->prepare(q{select a.segment_name, b.tablespace_name,
	decode(ext.extents,1,b.next_extent,
	a.bytes*(1+b.pct_increase/100)) nextext,
	freesp.largest
	from user_extents a,
	user_segments b,
	(select segment_name, max(extent_id) extent_id,
	count(*) extents
	from user_extents
	group by segment_name) ext,
	(select tablespace_name, max(bytes) largest
	from user_free_space
	group by tablespace_name) freesp
	where
	a.segment_name=b.segment_name and
	a.segment_name=ext.segment_name and
	a.extent_id=ext.extent_id and
	b.tablespace_name = freesp.tablespace_name and
	b.tablespace_name= ?  and
	decode(ext.extents,1,b.next_extent,
	a.bytes*(1+b.pct_increase/100)) > (freesp.largest)});
	$sth2->execute($tablespace);
	$sth2->bind_columns({},\($segname,$tblspace,$nextext,$largest));

	while ($sth->fetch)
		{
		if ($sth2->fetch)
			{
			if ($tblspace)
				{
				print STDOUT "Database: $dbname needs more space to grow: $tbspace\n";
				$EXIT = 1;	
				}
				else 
				{print STDOUT "Database: $dbname:$tablespace is fine\n";}	
			}
		}
	}
exit($EXIT)

