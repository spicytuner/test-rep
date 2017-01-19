#!/usr/bin/perl

# Author: Joe Soria
# Date: July 8, 2004
#
#

push(@INC, "/home/jsoria/SCRIPTS/PERL");
require 'serv_info.pl';

use DBI;
use strict;
use Spreadsheet::WriteExcel;

$ENV{'ORACLE_SID'}="remprd";
$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

#Define your variables
my($contact,$domain,$test,$usr,$passwd,$dbh,$sth,$sid,);

$contact='jsoria';
$domain='bresnan.com';
$test='2';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);

$dbh = DBI->connect('dbi:Oracle:remprd',$usr,$passwd) || die "Cannot establish connection to the database";

$dbh->{RaiseError}=1;
#Define your queries

##################################Nodes#############################
##################################Nodes#############################
##################################Nodes#############################

my ($cmts,$cms,$node,$pnode);

$sth=$dbh->do(q{grant all on aradmin.bz_incident to scripts});

