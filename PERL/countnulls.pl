#!/usr/bin/perl

# Author: Joe Soria
# Date: Oct 6, 2008
#
#This script will create the necessary partitions for the ip_allocation_events
#table in the remrep database.
#
push(@INC, "/home/jsoria/SCRIPTS/PERL");
push(@INC,"/home/jsoria/SCRIPTS/DATA");
require 'serv_info.pl';

use DBI;
use strict;
#use Getopt::Long;
use warnings;
#use Data::Dumper;

$ENV{'ORACLE_SID'}="remrep";
$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

my($tablename,$indindex,$ipindex,$subpartname,$partitionname,$sth,$sth1,$sth2,$test,$usr,$passwd,$sid,$host,$runalliae,$runallse,$sql,$q1);
our($column);

#GetOptions("0" => \$runalliae,
           #"1" => \$runallse);

$test='2';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);

our ($dbh);
$dbh = DBI->connect('dbi:Oracle:remrep',$usr,$passwd) || 
die "Cannot establish connection to the database";

$dbh->{RaiseError}=1;

our($date1);

$dbh->do("ALTER SESSION SET NLS_DATE_FORMAT='DDMONRRRR'");

$sth=$dbh->prepare(q{select column_name from dba_tab_cols
where table_name='BZ_INCIDENT_DAT'
order by column_name });
$sth->execute();
$sth->bind_columns({}, \($column));

open(LOG,">nulls.lst");


while ($sth->fetch)
        {

	foreach ($column)
		{

		my($cnt);
		#$q1="select round(to_number(count(incident_id))/(select to_number(count(incident_id)) from bz_incident_dat where create_date >= trunc(sysdate-31) and create_date < trunc(sysdate-1)) * 100) from bz_incident_dat where $column is null and create_date >= trunc(sysdate-31) and create_date < trunc(sysdate-1)";

		$q1="select count(incident_id) from bz_incident_dat where $column is null and create_date >= trunc(sysdate-31) and create_date < trunc(sysdate-1)";
		
		print "$q1\n";

		$sth1=$dbh->prepare("$q1");
		$sth1->execute();
		$sth1->bind_columns({}, \($cnt));

		while ($sth1->fetch)
		{
		
		print LOG "$column $cnt\n";
		
		}
	
	
		}
	}
 
close(LOG);
