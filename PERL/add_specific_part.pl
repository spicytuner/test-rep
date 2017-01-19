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

my($tablename,$indindex,$ipindex,$subpartname,$partitionname,$sth,$sth1,$sth2,$test,$usr,$passwd,$sid,$host,$runalliae,$runallse,$sql);

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

$sth=$dbh->prepare(q{select trunc(sysdate-1) from dual});
$sth->execute();
$sth->bind_columns({}, \($date1));



while ($sth->fetch)
        {

my($ystrday,$today,$sql1,$sql2,$sql3,$sql4);

	$dbh->do("alter session set nls_date_format='dd-Mon-yyyy'");

	$sth1=$dbh->prepare(q{select trunc(sysdate-1),trunc(sysdate-2) from dual});
	$sth1->execute();
	$sth1->bind_columns({}, \($today,$ystrday));

while($sth1->fetch)
	
	{
	print "SCRIPT RUNNING FOR PARTITIONS: $date1\n";
	print "Beginning: $ystrday \n";
	print "Ending: $today \n";

	print "Adding partition to subscriber_events table\n";

	$sql1="alter table metaserv31.subscriber_events
	add partition subscriber_events_$date1
	values less than (to_date(\'$today\', \'dd-Mon-yyyy\'))";

	$sth=$dbh->prepare("$sql1");
	$sth->execute();
	
	print "Inserting data into new subscriber_events partition\n";

	$sql2="insert into metaserv31.subscriber_events
	select * from metaserv31.subscriber_events\@samprd
	where eventtime >= \'$ystrday\'
	and eventtime < \'$today\'";

	$sth=$dbh->prepare("$sql2");
	$sth->execute();
	
	print "Adding partition to ip_allocation_events table\n";

	$sql3="alter table metaserv31.ip_allocation_events
	add partition ip_allocation_events_$date1
	values less than (to_date(\'$today\', \'dd-Mon-yyyy\'))";

	$sth=$dbh->prepare("$sql3");
	$sth->execute();
	
	print "Inserting data into new ip_allocation_events partition\n";

	$sql4="insert into metaserv31.ip_allocation_events
	select *  from metaserv31.ip_allocation_events\@samprd
	where eventtime >= \'$ystrday\'
	and eventtime <\'$today\'";

	$sth=$dbh->prepare("$sql4");
	$sth->execute();
	}	
	}
 
