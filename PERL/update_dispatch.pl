#!/usr/bin/perl

# Author: Joe Soria
# Date: July 23, 2007
#
# This script will update the Dispatches table in remrep 

push(@INC, "/home/jsoria/SCRIPTS/PERL");
require 'serv_info.pl';

use DBI;
use strict;

$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

#Define your variables
my(@database,$database,$contact,$domain,$test,$usr,$passwd,$sid,$dbh,$sth,$sth1,$sth2,$sth3,$sth4,
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

	$sth=$dbh->prepare(q{truncate table dispatches});
	$sth->execute();

	$sth2=$dbh->prepare(q{insert into dispatches  
	select submitter,
	to_date('01/01/1970 00:00:00')+create_date/86400 as create_date,
	assigned_to, last_modified_by,
	to_date('01/01/1970 00:00:00')+modified_date/86400 as modified_date,
	status, description, incident_id as related_incident_id, work_order_id,
	to_date('01/01/1970 00:00:00')+dispatch_start_date/86400 as start_date,
	to_date('01/01/1970 00:00:00')+dispatch_end_date/86400 as end_date,
	wo_status, field_technician, account_number, job_number
	from aradmin.bz_incident@remprd
	where work_order_id is not null
	or job_number is not null});
	$sth2->execute();

#	$sth3=$dbh->prepare(q{truncate table dispatches_backup});
#	$sth3->execute();
#
#	$sth4=$dbh->prepare(q{drop table dispatches_backup});
#	$sth4->execute();
#	
#	$sth=$dbh->prepare(q{rename dispatches to dispatches_backup});
#	$sth->execute();
#
#	$sth1=$dbh->prepare(q{rename d2 to dispatches});
#	$sth1->execute();
	}
exit($EXIT)
