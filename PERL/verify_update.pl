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

my($test,$usr,$passwd,$sid,$dbh,$sth1);


$test='2';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);

our ($dbh);
$dbh = DBI->connect('dbi:Oracle:remrep',$usr,$passwd) || 
die "Cannot establish connection to the database";

$dbh->{RaiseError}=0;
$dbh->{PrintError}=0;


	print STDOUT "Grabbing NODE_ID and CM_MAC information from CM\n";
	#print LOG2 "Grabbing MTA information by CMMAC from MySQL\n";
        my($dbh2,$sth9,$sth10,$sth11,$nmsuser,$nmspass,$nodeid,$cm_mac,$newnodeid,$newcm_mac);

        $test='7';

        ($usr,$passwd,$sid)=&serv_info($test);
        $nmsuser=$usr;
        $nmspass=$passwd;

        print STDOUT "connecting to mysql\n";
        #print LOG2 "connecting to mysql\n";

        $dbh2 = DBI->connect("dbi:mysql:database=Inventory:$sid", $nmsuser, $nmspass) ||  
	die "Can't connect to nms2!";

        $sth9=$dbh2->prepare(q{select node_id, cm_mac
	from cm });
        $sth9->execute();
        $sth9->bind_columns({}, \($nodeid,$cm_mac));

        print LOG2 "fetching data\n";

        while ($sth9->fetch)
        {
	chomp($nodeid);
	chomp($cm_mac);
                $sth10=$dbh->prepare(q{ insert into cm values ( ?,? ) });
                $sth10->execute($nodeid,$cm_mac);
        }

        $sth10=$dbh2->prepare(q{select c.cm_mac, b.node_id
	from Inventory.node b, jbis.modem c
	where b.node_name=c.node
	});

        $sth10->execute();
        $sth10->bind_columns({}, \($newcm_mac,$newnodeid));

        print LOG2 "fetching data\n";

        while ($sth10->fetch)
        {
	chomp($newnodeid);
	chomp($newcm_mac);
                $sth11=$dbh->prepare(q{ insert into live_cm values ( ?,? ) });
                $sth11->execute($newnodeid,$newcm_mac);
        }
