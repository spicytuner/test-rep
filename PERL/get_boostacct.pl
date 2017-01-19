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


$dbh = DBI->connect('dbi:Oracle:smpprd',$usr,$passwd) || die "Cannot establish connection to the database";
$dbh->{RaiseError}=1;

	$dbh->do("alter session set nls_date_format='MM/DD/YYYY hh:mi:ss AM'");
	$sth=$dbh->prepare(q{select acct_number,modified_date,new_value 
	from bobs_device_orders where new_value like '%BOOST%'
	and modified_date > (select max(modified_date) from device_order_modified_date)});
	$sth->execute();
	$sth->bind_columns({}, \($acct,$mdate,$pack));

	while ($sth->fetch)
		{
		print STDOUT "$acct upgraded to boost $pack\n";
		system("mailx -n -s \"$acct Upgraded to Boost $pack\" mciszek\@cablevision.com rspencer\@cablevision.com kbrosnan\@cablevision.com kmoloney\@cablevision.com jsoria\@bresnan.com jrobey\@bresnan.com -- -r no-reply\@bresnan.com < /dev/null");
		$sth2=$dbh->prepare(q{insert into device_order_modified_date values (?)});
        	$sth2->execute($mdate);
		}

#system("/usr/bin/uuencode /home/jsoria/SCRIPTS/PERL/emailids.csv /tmp/emailids.csv | /usr/bin/mailx -s \"Email List\" dbotsch\@bresnan.com AKHAIMOV\@cablevision.com INIYAZOV\@cablevision.com JDIGAUDI\@cablevision.com");
