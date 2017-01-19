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

system("rm -f /home/jsoria/SCRIPTS/PERL/Cust_Import.csv");
system("pushd /home/jsoria/SCRIPTS/PERL/; unzip /home/csgdump/Cust_Import2*.zip");
system("> /home/jsoria/SCRIPTS/PERL/insertion.log");
open(FILE,"/home/jsoria/SCRIPTS/PERL/Cust_Import.csv");
open(LOG,">>/home/jsoria/SCRIPTS/PERL/insertion.log");

my ($techlname,$techfname,$line,$acct,$node,$lname,$fname,$phone,$add1,$add2,$city,$state,$zip,$lcd,$status,$vid,$data,$bdp,$fiber,$res,$dctunitid,$dctserialid,$model,$email,$techid,$techname,$techco,$pid,$instdt);

while ($line=<FILE>) {

if ($line =~ /^8213/ || $line =~ /Subs/) { print LOG "skipped by format rule \n"; next; }
$count++;
#print "$count\n";
#print LOG "$count\n";
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



if ($found==0) {
	#run all subs
	&customer_insert;
}
if ($found==0) {
	if (($dctunitid) && ($model !=~ 'ARRIS')) {&video_insert;}
	&hsi_insert;
	if ($instdt != "") { 
	 &tech_insert;
	} else {
	 print LOG "instdt is empty \n";
	}

}
	
if ($found==1) {
	#run all subs
	&customer_update;
	if (($dctunitid) && ($model !=~ 'ARRIS')) {&video_insert;}
	&hsi_insert;
        if ($instdt != "") {
         &tech_insert;
        } else {
         print LOG "instdt is empty \n";
        }
}
	
if ($found==2) {
	#run all subs
	&hsi_insert;
        if ($instdt != "") {
         &tech_insert;
        } else {
         print LOG "instdt is empty \n";
        }
	
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

sub customer_update
{
my ($sth_cust);
        $sth_cust=$dbh->prepare(q{update customer_info set 
	node=?,firstname=?,lastname=?,phone=?,street1=?,street2=?,city=?,state=?,zip=?,last_changed=?
	where accountnumber = ? and (last_changed < ? or (last_changed = ? and (node!=? or firstname!=? or lastname!=? or phone!=? or street1!=? or street2!=? or city!=? or state!=? or zip!=?))) });
        $sth_cust->execute($node,$lname,$fname,$phone,$add1,$add2,$city,$state,$zip,$lcd,$acct,$lcd,$lcd,$node,$lname,$fname,$phone,$add1,$add2,$city,$state,$zip);

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
#	$sth_hsi=$dbh->prepare(q{insert into hsi_info
#	(cus_accountnumber,service_type,cmmac,mtamac,mtafqdn,cmsfqdn,cm_vendor,
#	imagefile,cmts,packageid,email,last_changed) 
#	(select accountnumber,service_type,cmmac,mtamac,mtafqdn,cmsfqdn,mta_vendor,
#	imagefile,cmts,packageid,null,last_changed from cust@remrep
#	where accountnumber = ? )});

 $sth_hsi=$dbh->prepare(q{merge into hsi_info h
using  (select accountnumber,service_type,cmmac,mtamac,mtafqdn,cmsfqdn,mta_vendor,imagefile,cmts,packageid,null,last_changed from cust@remrep
	where accountnumber = ?) r
	on (h.cus_accountnumber=r.accountnumber and h.cmmac=r.cmmac )
	when matched then update 
	set  h.SERVICE_TYPE=r.service_type,
	h.MTAMAC=r.mtamac,
	h.MTAFQDN=r.mtafqdn,
	h.CMSFQDN=r.cmsfqdn,
	h.CM_VENDOR=r.mta_vendor,
	h.IMAGEFILE=r.imagefile,
	h.CMTS=r.cmts,
	h.PACKAGEID=r.packageid,
	h.LAST_CHANGED=r.last_changed
	when not matched then 
	insert (h.cus_accountnumber,h.service_type,h.cmmac,h.mtamac,h.mtafqdn,h.cmsfqdn,h.cm_vendor, h.imagefile,h.cmts,h.packageid,h.email,h.last_changed)
	values (r.accountnumber,r.service_type,r.cmmac,r.mtamac,r.mtafqdn,r.cmsfqdn,r.mta_vendor,r.imagefile,r.cmts,r.packageid,null,r.last_changed )});

	$sth_hsi->execute($acct);
}

sub tech_insert
{
my ($sth_tech,$mm,$dd,$yy);
	($mm,$dd,$yy)=split(/\//,$instdt);
chomp($mm);
chomp($dd);
chomp($yy);
if (looks_like_number($mm) && $mm < 13 && looks_like_number($dd) && looks_like_number($yy))
 {

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

$instdt="$mm\/$dd\/$yy";
#print STDOUT "INSTALL DATE: $instdt\n";
        $sth_tech=$dbh->prepare(q{insert into tech_info
        (cus_accountnumber,tech_id,tech_name,tech_company,last_equipment_change)
        values (?,?,?,?,?)});
        $sth_tech->execute($acct,$techid,$techname,$techco,$instdt);
 }
}

#}

#system("mv /home/csgdump/Cust_Import2*.zip /home/csgdump/LOADED/.");

close(FILE);
close(LOG);
