#!/usr/bin/perl
#
# This script is used to populate the appropriate cust table with csg
# data.
##First you need to take the contents of the file from the csgdump directory
use strict;
use DBI;
use Scalar::Util qw(looks_like_number);

$ENV{'ORACLE_SID'}="remprd";
$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

my ($dbh);
$dbh = DBI->connect( 'dbi:Oracle:remprd', 'masterm','mMmMbeeR',) || die "Database connection not made: $DBI::errstr";

my ($count);

#system("rm -f /home/jsoria/SCRIPTS/PERL/Cust_Import.csv");
#system("pushd /home/jsoria/SCRIPTS/PERL/; unzip /home/csgdump/Cust_Import2*.zip");
#system("touch /home/jsoria/SCRIPTS/PERL/insertion.log");
open(FILE,"/home/jsoria/SCRIPTS/PERL/Cust_Import.csv");
open(LOG,">>/home/jsoria/SCRIPTS/PERL/insertion.log");

my ($techlname,$techfname,$line,$acct,$node,$lname,$fname,$phone,$add1,$add2,$city,$state,$zip,$lcd,$status,$vid,$data,$bdp,$fiber,$res,$dctunitid,$dctserialid,$model,$email,$techid,$techname,$techco,$pid,$instdt);

while ($line=<FILE>) {
print LOG "$line";
if ($line =~ /^8213/ || $line =~ /^Subs/) { print LOG "skipped \n"; next; }
$count++;
#print "$count\n";
print LOG "$count\n";
	$line=~ s/\'//g;
	$line=~ s/\015//g;
	$line=~ s/ \"/\"/g;
	$line=~ s/\"//g;
	$line=~ s/\*//g;
	$line=~ s/\'//g;
	$line=~ s/\(Unknown\)//g;

###SubscriberKey,Node,LastName,FirstName,Phone,Address1,Address2,City,State,Zip,LastChangedDate,Status,Video,DATA,BDP,Fiber,IsResidential,EQP_MODEL_EQP,EQP_SERIAL_EQP,ModleName,EmailAddress,TechId,TechName,TechCompanyName,PeopleId,InstallDate
#

	($acct,$node,$fname,$lname,$phone,$add1,$add2,$city,$state,$zip,$lcd,$status,$vid,$data,$bdp,$fiber,$res,$dctunitid,$dctserialid,$model,$email,$techid,$techlname,$techfname,$techco,$pid,$instdt)=split(/,/,$line);
$techname="$techlname\, $techfname";
print LOG "\n $acct with $instdt";
	my($found);
	$found=0;

my ($sth_q_ci,$sth_q_vi);

	$sth_q_ci=$dbh->prepare(q{select remedy_id  
		from customer_info
		where accountnumber = ?});
     	$sth_q_ci->execute($acct);

	while ($sth_q_ci->fetch) { $found = 1;}

if ($dctunitid) {
	$sth_q_vi=$dbh->prepare(q{select remedy_id  
		from video_info
		where cus_accountnumber = ?
		and unit_id = ?});
     	$sth_q_vi->execute($acct, $dctunitid);

	while ($sth_q_vi->fetch) { $found = 2;}
}

if ($instdt != "") {
print LOG "instdt not is empty \n";
} else {
print LOG "instdt is empty \n";
}

if ($found==0) {
	#run all subs
	&customer_insert;
}
if ($found==0) {
	if (($dctunitid) && ($model !=~ 'ARRIS')) {&video_insert;}
	&hsi_insert;
	&tech_insert;
	}
	
if ($found==1) {
	#run all subs
	if (($dctunitid) && ($model !=~ 'ARRIS')) {&video_insert;}
	&hsi_insert;
	&tech_insert;
	}
	
if ($found==2) {
	#run all subs
	&hsi_insert;
	&tech_insert;
	}
}
	
        	
sub customer_insert
{
my ($sth_cust);
	$sth_cust=$dbh->prepare(q{insert into customer_info
	(accountnumber,node,firstname,lastname,phone,street1,street2,city,state,zip,last_changed) 
	values (?,?,?,?,?,?,?,?,?,?,?)});
	$sth_cust->execute($acct,$node,$lname,$fname,$phone,$add1,$add2,$city,$state,$zip,$lcd);

}

sub video_insert
{
my ($sth_video);
	$sth_video=$dbh->prepare(q{insert into video_info
	(cus_accountnumber,unit_id,serial_id,model_number,last_changed) 
	values (?,?,?,?,?)});
	$sth_video->execute($acct,$dctunitid,$dctserialid,$model,$lcd);
}

sub hsi_insert
{
my ($sth_hsi);
	$sth_hsi=$dbh->prepare(q{insert into hsi_info
	(cus_accountnumber,service_type,cmmac,mtamac,mtafqdn,cmsfqdn,cm_vendor,
	imagefile,cmts,packageid,email,last_changed) 
	(select accountnumber,service_type,cmmac,mtamac,mtafqdn,cmsfqdn,mta_vendor,
	imagefile,cmts,packageid,null,last_changed from cust@remrep
	where accountnumber = ? )});
	$sth_hsi->execute($acct);
}

sub tech_insert
{
my ($sth_tech,$mm,$dd,$yy);
print "instdt is $instdt \n";
	($mm,$dd,$yy)=split(/\//,$instdt);
print LOG " splito of mm dd yy $mm $dd $yy \n";
chomp($mm);
chomp($dd);
chomp($yy);

print LOG " after chomp $mm $dd $yy \n";
if (looks_like_number($mm) && looks_like_number($dd) && looks_like_number($yy) ) {
if ($mm < 10)
{
$mm = "0$mm";
}

if ($dd < 10)
{
$dd = "0$dd";
}

if ($yy < 2000)
{
$yy = "0$yy";
}
}else {
print "mm dd yy is not a number \n";
}
$instdt="$mm\/$dd\/$yy";
print LOG "INSTALL DATE: $instdt \n";

        $sth_tech=$dbh->prepare(q{insert into tech_info
        (cus_accountnumber,tech_id,tech_name,tech_company,last_equipment_change)
        values (?,?,?,?,?)});
        $sth_tech->execute($acct,$techid,$techname,$techco,$instdt);
}

#}

#system("mv /home/csgdump/Cust_Import2*.zip /home/csgdump/LOADED/.");

close(FILE);
close(LOG);
