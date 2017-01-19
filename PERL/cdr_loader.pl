#!/usr/bin/perl -w

# Author: Joe Soria
# Date: May 7, 2002
# This script will grab data from the acct_backup table on the accounting server
# and split the column: radiusattr the columns will be inserted back into the
# database into the table: customer_account_record
#
#

push(@INC, "/export/home/jsoria/SCRIPTS/PERL");
require 'serv_info.pl';

use strict;
use warnings;
#use Data::Dumper;
use DBI;


my %numhash=(	'Call Type'		=>	'call_time',
		'Date'			=>	'cdr_date',
		'Calling Number'	=>	'calling_number',
		'Called Number'		=>	'called_number',
		'Time'			=>	'call_time',
		'Length of Call'	=>	'length_of_call',
		'CIC'			=>	'cic',
		'Carrier Connect Date'	=>	'carrier_connect_date',
		'Carrier Connect Time'	=>	'carrier_connect_time',
		'Carrier Elapse Time'	=>	'carrier_elapse_time',
		'Trunk Group Number'	=>	'trunk_group_number');

##############
##############
#do your thing
##############
##############

my @database=qw(remprd);
my ($date_param, $dateResults, $sqlResults, @sqlResults, @sqlResults1, 
$result, $sqlget, $i, $orasqlsource, $orasqlsource2, $insertsql, @sqlset,
@sqlResults2,$sdate,%data); 


my $orauser="masterm";
my $orapass="mMmMbeeR";
my $orahost=".147.45.208";
my $orasid="remdev";

my ($cdrattr,@cdrattrvalues,@newcol,@col,@newval,@val,$numhash,$id,@records);

$orasqlsource="dbi:Oracle:host=$orahost;sid=$orasid";

$sdate=localtime;


my $cnt;
BEGIN
{
open(LOG, "cdr.txt");
local $/ = undef;
@records = split(/End of record/, <LOG>);
}
foreach (@records)
{
	$cnt++;
	my @recs=split(/\n/,$_);
	foreach (@recs)
	{
		chomp;
		$data{$cnt}{calltype} = $1 if (/^Call type: (.*)$/);
		$data{$cnt}{date} = $1 if (/^Date: (.*)$/);
		$data{$cnt}{callingnumber} = $1 if (/^Calling number: (.*)$/);
		$data{$cnt}{callednumber} = $1 if (/^Called number: (.*)$/);
		$data{$cnt}{calllength} = $1 if (/^Length of call: (.*)$/);
		#$data{$cnt}[5] = $1 if (/^Time: (.*)$/);
		#$data{$cnt}[6] = $1 if (/^Carrier connect date: (.*)$/);
		#$data{$cnt}[7] = $1 if (/^Carrier connect time: (.*)$/);
		#$data{$cnt}[8] = $1 if (/^Carrier elapsed time: (.*)$/);
		#$data{$cnt}[9] = $1 if (/^Trunk Group Number : (.*)$/);
		#$cic = $1 if (/^ : (.*)$/);
	} 
	next;
} 
foreach (keys(%data)) {
	print qq#insert into calltype = $data{$_}{calltype} calllength = $data{$_}{calllength}\n#;
}
