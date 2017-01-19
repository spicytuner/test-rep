#!/usr/bin/perl
# Author: Joe Soria
# DATE: Sep 09, 2010
#
# This script grabs all of the active email address for bresnan.net out of alopa
# and writes them to a file. The file is then sent to CVC

push(@INC, "/home/jsoria/SCRIPTS/PERL");
push(@INC,"/home/jsoria/SCRIPTS/DATA");
require 'serv_info.pl';

use DBI;
use strict;
use Data::Dumper;

$ENV{'ORACLE_SID'}="smpprd";
$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

my($sth,$sth2,$test,$usr,$passwd,$sid,$host,$acct,$pack,$mdate);
our ($dbh);

$test='5';
$usr="";
$passwd="";
($usr,$passwd,$sid)=&serv_info($test);

system("rm /home/jsoria/SCRIPTS/PERL/dailyboostupgradereport.csv");

$dbh = DBI->connect('dbi:Oracle:smpprd',$usr,$passwd) || die "Cannot establish connection to the database";
$dbh->{RaiseError}=1;
open(LOG,">>/home/jsoria/SCRIPTS/PERL/dailyboostupgradereport.csv");

	$dbh->do("alter session set nls_date_format='MM/DD/YYYY hh:mi:ss AM'");
	$sth=$dbh->prepare(q{select acct_number,modified_date,new_value 
	from yesterdays_boost where new_value like '%BOOST%'
	and modified_date >= trunc(sysdate-1)
	and modified_date <= trunc(sysdate)});
	$sth->execute();
	$sth->bind_columns({}, \($acct,$mdate,$pack));

	while ($sth->fetch)
		{
		print LOG "$acct,$mdate,$pack\n";
		#system("mailx -n -s \"Yesterday's Upgraded Boost Customers\" mciszek\@cablevision.com rspencer\@cablevision.com kbrosnan\@cablevision.com kmoloney\@cablevision.com jsoria\@bresnan.com jrobey\@bresnan.com -- -r noreply\@bresnan.net < /dev/null");
		#$sth2=$dbh->prepare(q{insert into device_order_modified_date values (?)});
        	#$sth2->execute($mdate);
		}

close(LOG);
		#system("mailx -n -s \"Yesterday's Upgraded Boost Customers\" kbrosnan\@cablevision.com kmoloney\@cablevision.com jsoria\@bresnan.com jrobey\@bresnan.com -- -r noreply\@bresnan.net < /home/jsoria/SCRIPTS/PERL/dailyboostupgradereport.csv");
		system("mailx -n -s \"Boost Customer Upgrades\" jsoria\@bresnan.com jrobey\@bresnan.com -- -r noreply\@bresnan.net < /home/jsoria/SCRIPTS/PERL/dailyboostupgradereport.csv");
