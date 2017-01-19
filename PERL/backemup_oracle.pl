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
$sth2,$workdir,@database,$sql);

$test='4';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);

#GetOptions("0" => \$fullbackup,
           #"1" => \$logicalbackup);

@database=('hms_config','vsm_billings_config');


open(BACKUPISAM,">/home/jsoria/SCRIPTS/PERL/oracle.log");

foreach $database(@database)
	{
	$dbh = DBI->connect("dbi:oracle:database=Inventory:$sid", $usr, $passwd) ||
	die "Can't connect to $database";

	#print "$database\n";

	##Obtain list of table names
	$sth=$dbh->prepare(q{select tablespace_name from dba_tablespaces});
	$sth->execute;
	$sth->bind_columns({}, \($table));

	while ($sth->fetch)
		{
		my($a,$b);
		
		$sql="show create table $table";
	
		##Obtain engine type of table creation
		$sth2=$dbh->prepare("$sql");
		$sth2->execute();
		$sth2->bind_columns({}, \($a,$b));

		$sth=$dbh->prepare(q{create table dbbackup_info
		(tablespace_name	varchar2(30) not null,
		file_name		varchar2(50) not null,
		backup_flag		int default 0,
		data_flag		int default 0,
		last_backup_date 	date)};
		$sth->execute();
	
			
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
