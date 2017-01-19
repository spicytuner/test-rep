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

my($sth,$sth2,$test,$usr,$passwd,$sid,$date,$sth3,$host,$acct,$pack,$mdate,$countdata,$countvoice);
our ($dbh);

$test='5';
$usr="";
$passwd="";
($usr,$passwd,$sid)=&serv_info($test);

system("rm /home/jsoria/SCRIPTS/PERL/dailyoptimumreport.csv");

$dbh = DBI->connect('dbi:Oracle:smpprd',$usr,$passwd) || die "Cannot establish connection to the database";
$dbh->{RaiseError}=1;
open(LOG,">>/home/jsoria/SCRIPTS/PERL/dailyoptimumreport.csv");

	$dbh->do("alter session set nls_date_format='MM/DD/YYYY'");
	$sth3=$dbh->prepare("select trunc(sysdate -1) from dual");
        $sth3->execute();
        $sth3->bind_columns({}, \($date));

	$sth=$dbh->prepare(q{select count(distinct acct_number)
	from forever_boost where (new_value like '%OLRSTAND%'
	or new_value like '%OLCSTAND%'
	or new_value like '%OLRBOOST%'
	or new_value like '%OLCBOOST%')
	and
	(new_value not like '%OVRVOIP%'
	or new_value not like '%OVCVOIP%')});
	$sth->execute();
	$sth->bind_columns({}, \($countdata));

	$sth2=$dbh->prepare(q{select count(distinct acct_number)
	from forever_boost where 
	(new_value like '%OVRVOIP%'
	or new_value like '%OVCVOIP%')});
	$sth2->execute();
	$sth2->bind_columns({}, \($countvoice));

	#while ($sth3->fetch)
		#{
		#print LOG "$date\n";
		#}

	while ($sth->fetch)
		{
		print LOG "Data: $countdata\n";
		}

	while ($sth2->fetch)
		{
		print LOG "Voice: $countvoice\n";
		}


close(LOG);
		#system("mailx -n -s \"Yesterday's Upgraded Boost Customers\" kbrosnan\@cablevision.com kmoloney\@cablevision.com jsoria\@bresnan.com jrobey\@bresnan.com -- -r noreply\@bresnan.net < /home/jsoria/SCRIPTS/PERL/dailyboostupgradereport.csv");
		system("mailx -s \"Optimum Upgrade Counts\" jsoria\@cablevision.com jnoon\@cablevision.com bdaniels\@cablevision.com cgerdvil\@cablevision.com aweinreb\@cablevision.com rmahoney\@cablevision.com -- -r no-reply\@cablevision.com < /home/jsoria/SCRIPTS/PERL/dailyoptimumreport.csv");
