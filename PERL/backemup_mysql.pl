#!/usr/bin/perl
#
# This script is used to backup/recover all mysql db's
#
#
push(@INC, "/home/jsoria/SCRIPTS/PERL");

require 'serv_info.pl';
use strict;
use DBI;
use Getopt::Long;

my($test,$usr,$passwd,$sth,$dbh,$sid,$fullbackup,$logicalbackup,$database,$table,
$sth2,$workdir,@database,$sql,$cr);

$test='4';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);

#GetOptions("0" => \$fullbackup,
           #"1" => \$logicalbackup);

@database=('hms_config','vsm_billings_config');


open(BACKUPISAM,">/home/jsoria/SCRIPTS/PERL/bisam.log");
open(BACKUPINNO,">/home/jsoria/SCRIPTS/PERL/binno.log");
open(BACKUPOTHER,">/home/jsoria/SCRIPTS/PERL/bother.log");

foreach $database(@database)
	{
	$dbh = DBI->connect("dbi:mysql:database=Inventory:$sid", $usr, $passwd) ||
	die "Can't connect to $database";

	#print "$database\n";

	##Obtain list of table names
	$sth=$dbh->prepare(q{show tables});
	$sth->execute;
	$sth->bind_columns({}, \($table));

		$cr=$dbh->prepare(q{drop table dbbackup_info});
		$cr->execute();
	
		$cr=$dbh->prepare(q{create table dbbackup_info
		(tablename	varchar(30) not null,
		engine		varchar(10) not null,
		backup_flag	tinyint default 0,
		data_flag	tinyint default 0,
		last_backup_date timestamp)});
		$cr->execute();
	

	while ($sth->fetch)
		{
		my($a,$b);
		
		$sql="show create table $table";
	
		##Obtain engine type of table creation
		$sth2=$dbh->prepare("$sql");
		$sth2->execute();
		$sth2->bind_columns({}, \($a,$b));

		while ($sth2->fetch)
			{
			my ($sth3);
			if ($b =~ /InnoDB/)
				{
				print BACKUPINNO "$a\n";

				$sth3=$dbh->prepare(q{insert into dbbackup_info
				(tablename,engine) values (?,'InnoDB')});
				$sth3->execute($a);
				}
			if ($b =~ /ISAM/)
				{
				print BACKUPISAM "$a\n";

				$sth3=$dbh->prepare(q{insert into dbbackup_info
				(tablename,engine) values (?,'ISAM')});
				$sth3->execute($a);
				}
				else
				{
				print BACKUPOTHER "$a\n";

				$sth3=$dbh->prepare(q{insert into dbbackup_info
				(tablename,engine) values (?,'Other')});
				$sth3->execute($a);
				}
			}
		}
	}

close(BACKUPINNO);
close(BACKUPISAM);

#if ($fullbackup)
#{
#&db_with_data;
#}
#
#if ($logicalbackup)
#{
#&db_no_data;
#}
#
#sub db_with_data
#{
#system("mysqldump -u $usr -p $passwd --databases $database > $workdir/$database.sql");
#}
#
#sub db_no_data
#{
#system("mysqldump -u $usr -p $passwd --no-data --databases $database > $workdir/$database.sql");
#}
