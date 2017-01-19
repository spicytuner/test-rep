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

my($test,$usr,$passwd,$sid,$dbh);


$test='2';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);

our ($dbh);
$dbh = DBI->connect('dbi:Oracle:remrep',$usr,$passwd) || 
die "Cannot establish connection to the database";

$dbh->{RaiseError}=0;
$dbh->{PrintError}=0;


        $sth9=$dbh->prepare(q{select 'update modem set node='||b.node||' where account='||a.account||'''
	from verify_node a, account_node_status b
	where a.account=b.accountnumber
	and a.node != b.node
	and a.node ='UNKNOWN' });
        $sth9->execute();
        $sth9->bind_columns({}, \($acct,$mynode));


        while ($sth9->fetch)
        {
	chomp($acct);
	chomp($mynode);
        }

