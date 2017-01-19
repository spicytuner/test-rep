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


	print STDOUT "Truncating verify_node table\n";
        $sth1=$dbh->do(q{ truncate table verify_node });

	print STDOUT "Grabbing MTA information by CMMAC from MySQL\n";
	#print LOG2 "Grabbing MTA information by CMMAC from MySQL\n";
        my($dbh2,$sth9,$sth10,$sth11,$nmsuser,$nmspass,$acct,$mynode,$cmmac);

        $test='7';

        ($usr,$passwd,$sid)=&serv_info($test);
        $nmsuser=$usr;
        $nmspass=$passwd;

        print STDOUT "connecting to mysql\n";
        #print LOG2 "connecting to mysql\n";

        $dbh2 = DBI->connect("dbi:mysql:database=jbis:$sid", $nmsuser, $nmspass) ||  
	die "Can't connect to nms2!";

        $sth9=$dbh2->prepare(q{select account, node, cm_mac
	from modem });
        $sth9->execute();
        $sth9->bind_columns({}, \($acct,$mynode,$cmmac));

        print LOG2 "fetching data from mysql\n";

        while ($sth9->fetch)
        {
	chomp($acct);
	chomp($mynode);
                $sth10=$dbh->prepare(q{ insert into verify_node values ( ?,?,?) });
                $sth10->execute($acct,$mynode,$cmmac);
        }

