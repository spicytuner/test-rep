#!/usr/bin/perl -w
##===============================================================================
##   Author:
##   Notes: 
##       ..................
##===============================================================================
##===============================================================================
##   configuration
##===============================================================================
my $log_level 	= 10;
my $log_file 	= "cdrlog.txt";
my $test	= '2';
my $username	= "";
my $password	= "";

##===============================================================================
##   Initialization
##===============================================================================
use strict;
use warnings;
use diagnostics;
$| = 1;

##---------------------------------------
##   Libraries
##---------------------------------------
use DBI;
use POSIX qw(mktime strftime);
require("/home/jsoria/SCRIPTS/PERL/serv_info.pl");

##---------------------------------------
##   Files
##---------------------------------------
open(LOG, "cdr.txt");

##---------------------------------------
##   Global Variables
##---------------------------------------
my (
	$sid,
	$sth,
	$dbh,
	$cnt,
	@records,
	%data,
);
($username,$password,$sid)=&serv_info($test);
$dbh = DBI->connect('dbi:Oracle:remrep',$username,$password) || die "Cannot establish connection to the database";
$dbh->{RaiseError}=1;

##===============================================================================
##   Main Program
##===============================================================================
logger(10, "Program Start");
@records = load_records();
foreach (@records) {
	$cnt++;
	my @fields = split(/\n/,$_);
	foreach (@fields) {
		$data{$cnt}{calltype} = $1 if (/^Call type: (\d+)/);
		$data{$cnt}{date} = $1 if (/^Date: (\d\s+\w+\s+\d+)/);
		$data{$cnt}{callingnumber} = $1 if (/^Calling number: (.*)/);
		$data{$cnt}{callednumber} = $1 if (/^Called number: (\d{3,}\-\d{3,}\-\d{4,})/);
		$data{$cnt}{calllength} = $1 if (/^Length of call: (\w+:\w+\.\w+)/);
		$data{$cnt}{calltime} = $1 if (/^Time: (\w+:\w+\w+\.\w+)/);
		$data{$cnt}{ccd} = $1 if (/^Carrier connect date: (\d\s+\w+\s+\d+)/);
		$data{$cnt}{cct} = $1 if (/^Carrier connect time: (\w+:\w+\w+\.\w+)/);
		$data{$cnt}{cet} = $1 if (/^Carrier elapsed time: (\w+:\w+\.\w+)/);
		$data{$cnt}{ttn} = $1 if (/^Trunk Group Number : (.*)/);
		#$cic = $1 if (/^ : (.*)$/);
	} 
	next;
} 
foreach (keys(%data)) {
	print "insert into cdr_log values $data{$_}{calltype} $data{$_}{calllength} $data{$_}{date} $data{$_}{calllength} $data{$_}{calltime} $data{$_}{ccd} $data{$_}{cct} $data{$_}{cet}\n";
	#logger(10, "insert into cdr_log values length = $data{$_}{calltype} $data{$_}{callednumber} $data{$_}{date} $data{$_}{calllength} $data{$cnt}{calltime} $data{$cnt}{ccd} $data{$cnt}{cct}$data{$cnt}{cet}");
	$sth=$dbh->prepare(q{insert into cdr_log values (?,?,?,?,?,?,?,?,?,?)});
	$sth->bind_param(1,$data{$_}{calltype});
	$sth->bind_param(2,$data{$_}{date});
	$sth->bind_param(3,$data{$_}{callingnumber});
	$sth->bind_param(4,$data{$_}{callednumber});
	$sth->bind_param(5,$data{$_}{calllength});
	$sth->bind_param(6,$data{$_}{calltime});
	$sth->bind_param(7,$data{$_}{ccd});
	$sth->bind_param(8,$data{$_}{cct});
	$sth->bind_param(9,$data{$_}{cet});
	$sth->bind_param(10,$data{$_}{ttn});
	$sth->execute();
	#$sth->execute($data{$_}{calltype},$data{$_}{callednumber},$data{$_}{date},$data{$_}{calllength},$data{$cnt}{calltime},$data{$cnt}{ccd},$data{$cnt}{cct}$data{$cnt}{cet});
}
logger(10, "Program Finished");
##===============================================================================
##   Subroutines
##===============================================================================
sub load_records {
	$/ = '';
        $_ = <LOG>;
        my @recs = split(/End of record/);
	return @recs;
}

sub logger {
        my $dval        = shift;
        my $log         = shift;
        my $date  = strftime("%Y-%m-%d",localtime) ;
        my $time  = strftime("%H:%M:%S",localtime) ;
        if ($log_level >= $dval) {
                $log =~ s/\n//g;
                open(FOUT, ">>$log_file-$date.log");
                print FOUT "$date ${time}: $dval   $log\n";
                close(FOUT);
        }

}
##===============================================================================
##   END
##===============================================================================
