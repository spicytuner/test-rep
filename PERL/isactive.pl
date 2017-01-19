#!/usr/bin/perl

# Author: Joe Soria
# Date: May 15, 2007
#
# This script builds the cust table in remrep, prepares the data for Auspice,
# inserts the data from cust into the Correlated Device Inventory 

push(@INC, "/home/jsoria/SCRIPTS/PERL");
push(@INC,"/home/jsoria/SCRIPTS/DATA");
require 'serv_info.pl';
#require 'updateVSM.pl';

use DBI;
use strict;
use Spreadsheet::WriteExcel;
use Getopt::Long;
#use warnings;
use Data::Dumper;

$ENV{'ORACLE_SID'}="remrep";
$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

my($cm,$test,$usr,$passwd,$sid,$host,$sth9,$cmmac,$mta_ip,$cmts);

$test='2';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);

our ($dbh);
$dbh = DBI->connect('dbi:Oracle:remrep',$usr,$passwd) || 
die "Cannot establish connection to the database";

open(FILE, "/home/jsoria/SCRIPTS/PERL/mac.lst");
open(LOG, ">/home/jsoria/SCRIPTS/PERL/full_information.lst");

while ($cmmac=<FILE>)
{

	chomp($cmmac);

	print STDOUT "Grabbing True CMTS Information from MySQL\n";
        my($mtaip,$cnt,$dbh2,$sth9,$sth10,$sth11,$nmsuser,$nmspass);

        $test='3';

        ($usr,$passwd,$sid)=&serv_info($test);
        $nmsuser=$usr;
        $nmspass=$passwd;

        print STDOUT "connecting to mysql\n";

        $dbh2 = DBI->connect("dbi:mysql:database=Inventory:$sid", $nmsuser, $nmspass) ||  
	die "Can't connect to nms2!";

	print STDOUT "Looking for $cmmac\n";

        #$sth9=$dbh2->prepare(q{select cm_mac, cmts_name, mta_ip 
	#from cm 
	#inner join cmts on cm.cmts_id = cmts.cmts_id 
	#left join mta on cm.cm_id = mta.cm_id 
	#where cm.cm_mac = ?});
        #$sth9->execute($cmmac);
        #$sth9->bind_columns({}, \($cm,$cmts,$mtaip));

        $sth9=$dbh2->prepare(q{select cm_mac, cmts_name
	from cm 
	inner join cmts on cm.cmts_id = cmts.cmts_id 
	where cm.cm_mac = ?});
        $sth9->execute($cmmac);
        $sth9->bind_columns({}, \($cm,$cmts));

	print STDOUT "found $cm, $cmts, $mtaip\n";
	print LOG "found $cm, $cmts, $mtaip\n";

}
