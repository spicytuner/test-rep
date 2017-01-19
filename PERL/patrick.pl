#!/usr/bin/perl -w
#script: patrick.pl
#author: jsoria

#push(@INC, "/home/jsoria");
require ('/home/jsoria/SCRIPTS/PERL/serv_info.pl');

#use strict;
use DBI;

my (@db_table,$db_table,$count,$emailid,$dbh,$DBI,$acctnum,$email,
$test,$usr,$passwd,$sid,$owner,$status,$sth,$junk,$line);

#$emailid=$ARGV[0];
#chomp($emailid);

$test='2';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);

$dbh = DBI->connect('dbi:Oracle:remrep',$usr,$passwd) ||
die "Cannot establish connection to the database";

@db_table = ('QUALITYCENTER_DEMO_DB.system_field',
'TRAINING_TEST_DB.system_field',
'APPDEV_BSMP_PORTAL_DB.system_field',
'TEST_NRT_DB.system_field',
'TEST_PROJECTMASTERREPLACEMENT_.system_field',
'APPDEV_ELMER_DB.system_field',
'APPDEV_TWODOT_DB.system_field',
'APPDEV_NODEHEALTH_DB.system_field',
'APPDEV_SIMULTANEOUS_CALLS_TOOL.system_field',
'APPDEV_REMEDY_DB.system_field',
'APPDEV_ROUNDUP_DB.system_field',
'APPDEV_BOIS_DB.system_field',
'APPDEV_METAVIEW_LITE_DB.system_field',
'TEST_TEMPLATE_TEST_DB.system_field',
'SYSOPS_SYSOPS_2008_DB.system_field',
'TRAINING_QC_TRAINING_01_DB.system_field',
'TRAINING_QC_TRAINING_02_DB.system_field',
'TRAINING_QC_TRAINING_03_DB.system_field',
'TRAINING_QC_TRAINING_04_DB.system_field',
'TRAINING_QC_TRAINING_05_DB.system_field',
'TRAINING_QC_TRAINING_06_DB.system_field',
'TRAINING_QC_TRAINING_07_DB.system_field',
'TRAINING_QC_TRAINING_08_DB.system_field',
'TRAINING_QC_TRAINING_09_DB.system_field',
'TRAINING_QC_TRAINING_10_DB.system_field',
'TRAINING_TEMPLATE_TRAINING_DB.system_field',
'TEST_TEST_DB.system_field',
'TEST_DEVCOMMENTSTEST_DB.system_field',
'TEST_DETECTEDINRELEASE_DB.system_field',
'TEST_BOIS_DETECTEDIN_TEST_DB.system_field',
'TEST_REMEDYTEST_DB.system_field',
'TEST_TEMPLATE_DEV_DB.system_field');

foreach $db_table(@db_table)
{
print "$db_table\n";

	$sth=$dbh->prepare("
	UPDATE $db_table
	SET SF_REFERENCE_TABLE='RELEASES',
	SF_REFERENCE_NAME_COLUMN='REL_NAME'
 	WHERE SF_COLUMN_NAME = 'BG_DETECTED_IN_REL'");
	$sth->execute();

	$sth=$dbh->prepare("
	UPDATE $db_table 
	SET SF_REFERENCE_TABLE = 'RELEASE_CYCLES',
	SF_REFERENCE_NAME_COLUMN= 'RCYC_NAME'
 	WHERE SF_COLUMN_NAME = 'BG_DETECTED_IN_RCYC'");
	$sth->execute();

	$sth=$dbh->prepare("
	UPDATE $db_table 
	SET SF_REFERENCE_TABLE = 'RELEASES',
 	SF_REFERENCE_NAME_COLUMN='REL_NAME'
 	WHERE SF_COLUMN_NAME = 'BG_TARGET_REL'");
	$sth->execute();

	$sth=$dbh->prepare("
	UPDATE $db_table 
	SET SF_REFERENCE_TABLE = 'RELEASE_CYCLES',
 	SF_REFERENCE_NAME_COLUMN ='RCYC_NAME'
 	WHERE SF_COLUMN_NAME = 'BG_TARGET_RCYC'");
	$sth->execute();
}
