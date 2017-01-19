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
my(@database,$database,$contact,$domain,$test,$usr,$passwd,$sid,$dbh,$sth,$sth2,
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

	
	$sth2=$dbh->prepare(q{insert into dispatches
	(submitter,create_date,assigned_to,last_modified_by,modified_date,status,description,related_incident_id,
	work_order_id,start_date,end_date,wo_status,field_technician,customer_id,job_number)
	select submitter,
	to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+create_date/86400,'GMT','MST'),'MM/DD/YYYY hh24:mi:ss') as create_date,
	assigned_to, last_modified_by,
	to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+modified_date/86400,'GMT','MST'),'MM/DD/YYYY hh24:mi:ss') as modified_date,
	null,description,incident_id, work_order_id,
	to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+dispatch_start_date/86400,'GMT','MST'),'MM/DD/YYYY hh24:mi:ss') as start_date,
	to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+dispatch_end_date/86400,'GMT','MST'),'MM/DD/YYYY hh24:mi:ss') as end_date,
	wo_status, field_technician, customer_id, job_number
	from aradmin.bz_incident@remprd
	where to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+create_date/86400,'GMT','MST'),'MM/DD/YYYY hh24:mi:ss') >= '08/07/2009' 
	and to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+create_date/86400,'GMT','MST'),'MM/DD/YYYY hh24:mi:ss') < '09/06/2009'
	and (work_order_id is not null
	or job_number is not null)});
	$sth2->execute();

	}
exit($EXIT)
