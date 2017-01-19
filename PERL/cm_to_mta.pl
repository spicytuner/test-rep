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

my($test,$usr,$passwd,$sid,$host,$row,$col1,$col2,$col3,$col4,$col5,$col6,$col7,$col8,$col9,
$col10,$col11,$col12,$col13,$col14,$col15,$col16,$col17,$col18,$col19,$col20,$col21,$qname,$workbook,
$log,$log2,$sth,$sth1,$sth2,$sth3,$sth4,$sth5,$sth6,$sth7,$sth8,$sth9,$sth10,$sth11,$sth12,$sth13,
$sth14,$sth15,$sth16,$sth17,$sth18,$sth19,$sth20,$name,$status,$id,$owner,$worksheet,$cmmac,$node,
$devtype,$n1,$n2,$n3,$n4,$mtamac,$fname,$lname,$n5,$street1,$street2,$city,$state,$zip,$acct,$n6,
$phone,$n7,$cmsfqdn,$cmts,$n8,$loadvsm,$loadvsmonly,$prov,$line,$mdate,$file,$val,$runall,$loadcdi,$loadcust,$sth66);


$test='2';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);

our ($dbh);
$dbh = DBI->connect('dbi:Oracle:remrep',$usr,$passwd) || 
die "Cannot establish connection to the database";

$dbh->{RaiseError}=0;
$dbh->{PrintError}=0;


	print STDOUT "Grabbing MTA information by CMMAC from MySQL\n";
	#print LOG2 "Grabbing MTA information by CMMAC from MySQL\n";
        my($mtaip,$cnt,$dbh2,$sth9,$sth10,$sth11,$nmsuser,$nmspass,$mtamac);

        $test='3';

        ($usr,$passwd,$sid)=&serv_info($test);
        $nmsuser=$usr;
        $nmspass=$passwd;

        print STDOUT "connecting to mysql\n";
        #print LOG2 "connecting to mysql\n";

        $dbh2 = DBI->connect("dbi:mysql:database=Inventory:$sid", $nmsuser, $nmspass) ||  
	die "Can't connect to nms2!";

        $sth9=$dbh2->prepare(q{select cm_mac, cmts_name, mta_ip , mta_mac
	from cm 
	inner join cmts on cm.cmts_id = cmts.cmts_id 
	left join mta on cm.cm_id = mta.cm_id });
        $sth9->execute();
        $sth9->bind_columns({}, \($cmmac,$cmts,$mtaip,$mtamac));

        print LOG2 "fetching data from mysql\n";

        while ($sth9->fetch)
        {
                $sth10=$dbh->prepare(q{ insert into cm_to_mta values ( ?,?,?,?) });
                $sth10->execute($cmmac,$cmts,$mtaip,$mtamac);
        }

