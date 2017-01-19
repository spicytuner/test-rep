#!/usr/bin/perl 

#exec('touch /home/dbotsch/users.log');

push(@INC, "/home/jsoria/SCRIPTS/PERL");
require 'serv_info.pl';
require('/opt/inventory/connect.info'); #holds all server unique data
use DBI;
use Data::Dumper;
$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

$cableprov{'billings'}{'primary'} = "cableprov1";
$cableprov{'billings'}{'secondary'} = "cableprov0";
$cableprov{'grandjunction'}{'primary'} = "cableprov3";
$cableprov{'grandjunction'}{'secondary'} = "cableprov2";
$cableprov{'cheyenne'}{'primary'} = "cableprov6";
$cableprov{'cheyenne'}{'secondary'} = "cableprov4";
$cableprov{'missoula'}{'primary'} = "cableprov7";
$cableprov{'missoula'}{'secondary'} = "cableprov5";

my(@database,$database,$contact,$domain,$test,$usr,$passwd,$sid,$dbh,$sth,$sth2,
$sth3,$sth4,$sth5,$sth6,$sth7,$sth8,$sth9,$sth10,$dbname,$acctnum,$parentref);

#print "in job script\n";

$contact='jsoria';
$domain='bresnan.com';
$test='1';
$usr="";
$passwd="";
$mta = "";

($usr,$passwd,$sid)=&serv_info($test);

        $dbh = DBI->connect('dbi:Oracle:remrep',$usr,$passwd) || die "Cannot establish connection to the database";
        $dbh->{RaiseError}=1;

open(ACCTLIST, "/home/jsoria/SCRIPTS/PERL/acct.lst");
open(DELLOG,">>/home/jsoria/SCRIPTS/PERL/del.sql");
open(NODELLOG,">>/home/jsoria/SCRIPTS/PERL/nodel.sql");

while($acctnum=<ACCTLIST>)
	{
	chomp($acctnum);
		print "Looking for $acctnum\n";
		print DELLOG "insert into delete_account values (\'$acctnum\')\;\n";

        	$sth=$dbh->prepare(q{select distinct parentref from pi where userid= ?});
        	$sth->execute($acctnum);
        	$sth->bind_columns({},\($parentref));
		
        	if($sth->fetch)
                {

			chomp($parentref);
#			print "Searching for hardware with parentref $parentref\n";

			$sth3=$dbh->prepare(q{select a.userid 
			from pi a, hsd b
			where a.parentref=b.parentref
			and b.parentref=?});
                	$sth3->execute($parentref);
			$sth3->bind_columns({},\($acct));
	
			while ($sth3->fetch)
                	{
				print NODELLOG "insert into nodelete_account values (\'$acct\')\;\n";
			}
                }
	}
	print "search finished\n";

close(ACCTLIST);
close(LOG);
close(LOG2);
