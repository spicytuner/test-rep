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

$ENV{'ORACLE_SID'}="remrep";
$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

my($sth,$test,$usr,$passwd,$sid,$host,$csg,$e,$own,$create,$st);
our ($dbh);

$test='2';
$usr="";
$passwd="";
($usr,$passwd,$sid)=&serv_info($test);

open(LOG,">/home/optemail/emailids.csv");

print LOG "AccountID,WebMailId,Master,CreateDate,SubType\n";

#$dbh = DBI->connect('dbi:Oracle:samprd',$usr,$passwd) || die "Cannot establish connection to the database";
$dbh = DBI->connect('dbi:Oracle:remrep',$usr,$passwd) || die "Cannot establish connection to the database";
$dbh->{RaiseError}=1;

	#$sth=$dbh->prepare(q{select email_id, subtype from all_email_addresses});
	$sth=$dbh->prepare(q{select csg_id, email_id, owner, create_date, subtype from all_email_addresses});
	$sth->execute();
	$sth->bind_columns({}, \($csg,$e,$own,$create,$st));

	while ($sth->fetch)
		{
		print LOG "$csg,$e,$own,$create,$st\n";
		}
close(LOG);

#system("/usr/bin/zip -f /home/dbotsch/emailids.csv.zip /home/dbotsch/emailids.csv");

#system("/usr/bin/uuencode /home/jsoria/SCRIPTS/PERL/emailids.csv.zip /tmp/emailids.csv.zip | /usr/bin/mailx -s \"Email List\" jboelter\@bresnan.com dbotsch\@bresnan.com cwlewis\@bresnan.com");

#system("/usr/bin/uuencode /home/dbotsch/emailids.csv.zip /tmp/emailids.csv.zip | /usr/bin/mailx -s \"Email List\" dbotsch\@bresnan.com ");

#system("/usr/bin/uuencode /home/jsoria/SCRIPTS/PERL/emailids.csv /tmp/emailids.csv | /usr/bin/mailx -s \"Email List\" dbotsch\@bresnan.com AKHAIMOV\@cablevision.com INIYAZOV\@cablevision.com JDIGAUDI\@cablevision.com");
