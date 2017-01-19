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

my($test,$usr,$passwd,$sid,$host,$row,$col1,$col2,$col3,$col4,$col5,$col6,$col7,$col8,$col9,
$col10,$col11,$col12,$col13,$col14,$col15,$col16,$col17,$col18,$col19,$col20,$col21,$qname,$workbook,
$log,$log2,$sth,$sth1,$sth2,$sth3,$sth4,$sth5,$sth6,$sth7,$sth8,$sth9,$sth10,$sth11,$sth12,$sth13,
$sth14,$sth15,$sth16,$sth17,$sth18,$sth19,$sth20,$name,$status,$id,$owner,$worksheet,$cmmac,$node,
$devtype,$n1,$n2,$n3,$n4,$mtamac,$fname,$lname,$n5,$street1,$street2,$city,$state,$zip,$acct,$n6,
$phone,$n7,$cmsfqdn,$cmts,$n8,$loadvsm,$loadvsmonly,$prov,$line,$mdate,$file,$val,$runall,$loadcdi,$loadcust,$sth66);

GetOptions("0" => \$runall,
           "1" => \$loadcdi,
           "2" => \$loadcust,
	   "3" => \$loadvsm,
	   "4" => \$loadvsmonly);

$test='2';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);

our ($dbh);
$dbh = DBI->connect('dbi:Oracle:remrep',$usr,$passwd) || 
die "Cannot establish connection to the database";

$dbh->{RaiseError}=1;

#open(FILE, "/home/jsoria/SCRIPTS/PERL/ACCOUNT_NODE_STATUS.txt");
open(FILE, "/home/csgdump/ACCOUNT_NODE_STATUS.txt");
open(LOG, ">/home/jsoria/SCRIPTS/PERL/sub2node.dat");
open(LOG2, ">/home/jsoria/SCRIPTS/PERL/load_node.log");

while ($file=<FILE>)
{
	($acct,$node,$mdate,$status,$cmmac)=split(/\,/,$file);
	chomp($acct,$node,$mdate,$status,$cmmac);
	chop($cmmac);
	print LOG "$acct,$node,$mdate,$status,$cmmac\n";
}

close(FILE);
close(LOG);

if ($runall) 
{
print "Loading Account Node Status Information\n";
	&load_ans; 
print "Performing CMTS Lookup\n";
	&mysql_cmts;
print "Associating data by provisioning region\n";
	&data_by_prov;
print "Building Cust Table\n";
	&build_cust;
print "Preparing Auspice Files\n";
	&auspice_report;
print "Updating VSM\n";
	&update_VSM;
#	&undefined_nodes;
}

if ($loadcdi) 
{
print "Performing CMTS Lookup\n";
	&mysql_cmts;
print "Associating data by provisioning region\n";
	&data_by_prov;
print "Building Cust Table\n";
	&build_cust;
print "Preparing Auspice Files\n";
	&auspice_report;
print "Updating VSM\n";
	&update_VSM;
}

if ($loadcust) 
{
	&load_ans; 
	&mysql_cmts;
	&data_by_prov;
	&build_cust;
}

if ($loadvsm)
{
print "Preparing Auspice Files\n";
	&auspice_report;
print "Updating VSM\n";
	&update_VSM;
}

if ($loadvsmonly)
{
print "Updating VSM\n";
	&update_VSM;
}

sub load_ans
{
	print LOG2 "Eliminating old Account_node_status data\n";
	$sth=$dbh->prepare(q{truncate table account_node_status});
	$sth->execute();
	print LOG2 "Using SQLLDR to Insert New Data into ACCOUNT_NODE_STATUS\n";
	system("/home/oracle/OraHome1/bin/sqlldr $usr\/$passwd\@remrep silent=feedback control=/home/jsoria/SCRIPTS/PERL/account_node.ctl data=/home/csgdump/ACCOUNT_NODE_STATUS.txt errors=50000");
}

sub mysql_cmts
{
	print LOG2 "Grabbing True CMTS Information from MySQL\n";
        my($mtaip,$cnt,$dbh2,$sth9,$sth10,$sth11,$nmsuser,$nmspass);

        $test='3';

        ($usr,$passwd,$sid)=&serv_info($test);
        $nmsuser=$usr;
        $nmspass=$passwd;

        print LOG2 "connecting to mysql\n";

        $dbh2 = DBI->connect("dbi:mysql:database=Inventory:$sid", $nmsuser, $nmspass) ||  
	die "Can't connect to nms2!";

        $sth9=$dbh2->prepare(q{select cm_mac, cmts_name, mta_ip 
	from cm 
	inner join cmts on cm.cmts_id = cmts.cmts_id 
	left join mta on cm.cm_id = mta.cm_id });
        $sth9->execute();
        $sth9->bind_columns({}, \($cmmac,$cmts,$mtaip));

        print LOG2 "truncating cmmac_to_cmts table\n";

        $sth11=$dbh->prepare("truncate table cmmac_to_cmts");
        $sth11->execute();

        print LOG2 "fetching data from mysql\n";

        while ($sth9->fetch)
        {
                $sth10=$dbh->prepare(q{ insert into cmmac_to_cmts values ( ?,?,?) });
                $sth10->execute($cmmac,$cmts,$mtaip);
        }
}

sub data_by_prov
{
my ($sth99);
	print LOG2 "Eliminating cust_auspice_new Data\n";
	$sth5=$dbh->prepare(q{truncate table cust_auspice_new });
	$sth5->execute();

	print LOG2 "Inserting data into cust_auspice_new\n";
	$sth6=$dbh->prepare(q{insert into cust_auspice_new (
	select distinct b.userid,
	nvl(a.node,'undef') "NODE", b.firstname "FIRSTNAME",
	b.lastname "LASTNAME",
	f.linenumber "PHONE", replace(b.streetaddress1,',',null) "STREET1", 
	replace(b.streetaddress2,',',null) "STREET2",
	b.city "CITY", b.state "STATE",
	b.zipcode "ZIP", i.macaddressofcm "CMMAC", 'HSD & VOICE' "SERVICE_TYPE",
	f.fqdnformta "MTAFQDN",
	f.macaddressofmta "MTAMAC", f.cmsfqdn "CMSFQDN", i.vendor "MTA_VENDOR",
	i.mtabinfilename "IMAGEFILE",
	g.locationname "CMTS",sysdate,0,1,1,null, j.packageid 
	from account_node_status a, pi b, subscriberproxy d, subscriber e,
	endpoint f, locationtree g, voice i,
	subscribertopackage j
	where b.userid=a.accountnumber(+)
	and b.parentref=d.recordnumber
	and d.recordnumber=i.parentref
	and d.recordnumber=f.parentref
	and e.recordnumber=j.parentref
	and b.deletestatus=0
	and f.deletestatus=0
	and i.deletestatus=0
	and (upper(j.packageid) like '%VOIP%' or upper(j.packageid) like '%_V%' or upper(j.packageid) like '%TESTING_ONLY%')
	and (upper(j.packageid) not like '%VOIP%ONLY%' or upper(j.packageid) not like '%V_ONLY%')
	and (upper(j.packageid) not like '%BB%' or upper(j.packageid) not like '%COM%')
	and d.recordnumber=e.recordnumber
	and e.locationid=g.recordnumber
	and upper(f.macaddressofmta)=upper(i.macaddressofmta)
	and upper(a.status)='ACTIVE'
	union
	select distinct b.userid, nvl(a.node,'undef') "NODE",
	b.firstname "FIRSTNAME",
	b.lastname "LASTNAME",
	null "PHONE", b.streetaddress1 "STREET1", b.streetaddress2 "STREET2",
	b.city "CITY", b.state "STATE",
	b.zipcode "ZIP", c.macaddressofcm "CMMAC", 'HSD' "SERVICE_TYPE",
	null "MTAFQDN",
	null "MTAMAC", null "CMSFQDN", null "MTA_VENDOR", c.imagefile "IMAGEFILE",
	g.locationname "CMTS",sysdate,0,1,0,null, h.packageid
	from account_node_status a, pi b, hsd c, subscriberproxy d, subscriber e,
	locationtree g, subscribertopackage h
	where b.userid=a.accountnumber(+)
	and b.parentref=d.recordnumber
	and d.recordnumber=c.parentref
	and b.deletestatus=0
	and c.deletestatus=0
	and h.deletestatus=0
	and (upper(h.packageid) not like '%VOIP%' or upper(h.packageid) not like '%_V%')
	and (upper(h.packageid) not like '%BB%' or upper(h.packageid) not like '%COM%')
	and (c.imagefile not like '%VOIP%' or c.imagefile not like '%V_%' or c.imagefile not like '%_V%')
	and d.recordnumber=e.recordnumber
	and e.locationid=g.recordnumber
	and h.parentref=d.recordnumber
	and h.deletestatus=0
	and upper(a.status)='ACTIVE'
	union
	select distinct b.userid, nvl(a.node,'undef') "NODE",
	b.firstname "FIRSTNAME",
	b.lastname "LASTNAME",
	f.linenumber "PHONE", b.streetaddress1 "STREET1", b.streetaddress2 "STREET2",
	b.city "CITY", b.state "STATE",
	b.zipcode "ZIP", i.macaddressofcm "CMMAC", 'VOICE' "SERVICE_TYPE",
	f.fqdnformta "MTAFQDN",
	f.macaddressofmta "MTAMAC", f.cmsfqdn "CMSFQDN", i.vendor "MTA_VENDOR",
	i.mtabinfilename "IMAGEFILE",
	g.locationname "CMTS",sysdate,0,0,1,null,j.packageid
	from account_node_status a, pi b, subscriberproxy d, subscriber e,
	endpoint f, locationtree g, voice i,subscribertopackage j
	where b.userid=a.accountnumber(+)
	and b.parentref=d.recordnumber
	and d.recordnumber=i.parentref
	and d.recordnumber=f.parentref
	and j.parentref=e.recordnumber
	and b.deletestatus=0
	and f.deletestatus=0
	and i.deletestatus=0
	and j.deletestatus=0
	and (upper(j.packageid) like '%VOIP_ONLY%' or upper(j.packageid) like '%V_ONLY%')
	and d.recordnumber=e.recordnumber
	and e.locationid=g.recordnumber
	and upper(f.macaddressofmta)=upper(i.macaddressofmta)
	and upper(a.status)='ACTIVE'
	union
	select distinct d.userid, nvl(f.node,'undef') "NODE", d.firstname "FIRSTNAME",
        d.lastname "LASTNAME", null "PHONE",
        replace(d.streetaddress1,',',null) "STREET1", 
        replace(d.streetaddress2,',',null) "STREET2",
        d.city "CITY", d.state "STATE",
        d.zipcode "ZIP",
        e.macaddressofcm "CMMAC", 'HSD & VOICE' "SERVICE_TYPE", i.FQDNFORMTA "MTAFQDN",
        i.MACADDRESSOFMTA "MTAMAC", null "CMSFQDN", i.vendor "MTA_VENDOR", i.mtabinfilename "IMAGEFILE",
        g.locationname "CMTS", sysdate , 0 ,1 ,1 ,null,a.packageid 
        from subscribertopackage a, subscriber b, subscriberproxy c, pi d, hsd e, 
        account_node_status f, locationtree g, voice i
        where a.parentref=b.recordnumber
        and b.recordnumber=c.recordnumber
        and c.recordnumber=d.parentref
        and e.parentref=d.parentref
        and d.userid=f.accountnumber(+)
        and b.locationid=g.recordnumber
        and (a.packageid like '%BB%VOI%' or a.packageid like '%COM%_V%')
        and e.macaddressofcm=i.macaddressofcm
	and a.deletestatus=0
	and d.deletestatus=0
	and e.deletestatus=0
	union
	select distinct d.userid, nvl(f.node,'undef') "NODE", d.firstname "FIRSTNAME",
        d.lastname "LASTNAME", null "PHONE",
        replace(d.streetaddress1,',',null) "STREET1",
        replace(d.streetaddress2,',',null) "STREET2",
        d.city "CITY", d.state "STATE",
        d.zipcode "ZIP",
        e.macaddressofcm "CMMAC", 'HSD' "SERVICE_TYPE", null "MTAFQDN",
       null "MTAMAC", null "CMSFQDN", null "MTA_VENDOR", null "IMAGEFILE",
        g.locationname "CMTS", sysdate , 0 ,1 ,1 ,null,a.packageid
        from subscribertopackage a, subscriber b, subscriberproxy c, pi d, hsd e,
        account_node_status f, locationtree g
        where a.parentref=b.recordnumber
        and b.recordnumber=c.recordnumber
        and c.recordnumber=d.parentref
        and e.parentref=d.parentref
        and d.userid=f.accountnumber
        and b.locationid=g.recordnumber
        and (a.packageid like '%BB%' or a.packageid like '%COM%')
	and a.deletestatus=0
	and d.deletestatus=0
	and e.deletestatus=0
        and (a.packageid not like '%VOIP%' or a.packageid not like '%_V%'))});
	$sth6->execute();

	print LOG2 "Updating MTA device types in cust_auspice_new\n";
	$sth7=$dbh->prepare(q{update cust_auspice_new set devicetype='MTA' where packageid like '%_V%'});
	$sth7->execute();

	print LOG2 "Updating CM device types in cust_auspice_new\n";
	$sth8=$dbh->prepare(q{update cust_auspice_new set devicetype='CM' where packageid not like '%_V%'});
	$sth8->execute();
}

sub build_cust
{
	print LOG2 "Eliminating cust_backup\n";
	$sth9=$dbh->prepare(q{truncate table cust_backup});
	$sth9->execute();

	print LOG2 "Backing up the Current CUST Data\n";
	$sth10=$dbh->prepare(q{insert into cust_backup select * from cust});
	$sth10->execute();

	print LOG2 "Dropping Cust Synonym\n";
	$sth11=$dbh->prepare(q{drop public synonym cust});
	$sth11->execute();

	print LOG2 "Pointing User to cust_backup\n";
	$sth12=$dbh->prepare(q{create public synonym cust for masterm.cust_backup});
	$sth12->execute();

	print LOG2 "Eliminating CUST Data\n";
	$sth13=$dbh->prepare(q{truncate table cust});
	$sth13->execute();

	print LOG2 "Inserting New Data into CUST\n";
	$sth14=$dbh->prepare(q{insert into cust select distinct a.accountnumber, a.node, 
	a.firstname, a.lastname, 
	a.phone,a.street1, a.street2, a.city,a.state,a.zip, a.cmmac, a.service_type, a.mtafqdn, a.mtamac, 
	a.cmsfqdn, a.mta_vendor, a.imagefile, b.cmts, a.last_changed, a.video, a.data, a.bdp, 
	a.devicetype, a.packageid, b.mta_ip_address
	from cust_auspice_new a, cmmac_to_cmts b
	where upper(a.cmmac)=upper(b.cmmac)});
	$sth14->execute();

	#print LOG2 "Updating CMTS Information with CMTS_CMS_MAP Data\n";
	#$sth17=$dbh->prepare(q{update cust a
	#set a.cmsfqdn=(select b.cms from cmts_cms_map b
	#where a.cmts=b.cmts)
	#where bdp=1});
	#$sth17->execute();

	print LOG2 "Updating Transponders\n";
	$sth15=$dbh->prepare(q{update cust set node='trans' where imagefile like '%ransp%'});
	$sth15->execute();

	print LOG2 "Updating RFTools\n";
	$sth16=$dbh->prepare(q{update cust set node='RFTOOLS' where imagefile like '%RFT%'});
	$sth16->execute();

	print LOG2 "Dropping Public Synonym Cust\n"; 
	$sth18=$dbh->prepare(q{drop public synonym cust});
	$sth18->execute();

	print LOG2 "Pointing Users back to Cust\n"; 
	$sth19=$dbh->prepare(q{create public synonym cust for masterm.cust});
	$sth19->execute();
}

print LOG2 "Finished with initial CUST LOAD\n";

#open(FILE1,">/home/jsoria/SCRIPTS/DATA/missoula.csv");
#open(FILE2,">/home/jsoria/SCRIPTS/DATA/cheyenne.csv");
#open(FILE3,">/home/jsoria/SCRIPTS/DATA/billings.csv");
#open(FILE4,">/home/jsoria/SCRIPTS/DATA/grandjunction.csv");

############################################
############################################
############################################
############################################

sub auspice_report 
{
my @market=("1", "mlsmt001aus", "chywy001aus", "blnmt001aus", "gdjco001aus");
my @prov_file=("1", "missoula.csv", "cheyenne.csv", "billings.csv", "grandjunction.csv");
my $i="1";
my $query="";

#open(FILE0,">/home/dbotsch/missoula.csv");
#open(FILE1,">/home/dbotsch/cheyenne.csv");
#open(FILE2,">/home/dbotsch/billings.csv");
#open(FILE3,">/home/dbotsch/grandjunction.csv");

   for($i=1;$i<=4;$i++)
   {

        my $file = "/home/jsoria/SCRIPTS/DATA/auspice_$prov_file[$i]_subscriber_inventory.csv";
        open(FILE,">$file") or die "Can't open $file $!";

        print "Creating $prov_file[$i] File for Auspice Import\n";
        $query = "select a.cmmac "CM_MAC_ADDRESS", b.firstname "FIRST_NAME",
	b.lastname "LAST_NAME", b.street1 "ADDRESS_LINE_1", b.street2 "ADDRESS_LINE_2",
	b.city "CITY", b.state "STATE", b.zip "ZIP_CODE", b.phone "TELEPHONE_NUM",
	'MTA' "DEVICETYPE", nvl(a.mtamac,null) "AGENT_MAC_ADDRESS",
	nvl(a.mtafqdn,null) "AGENT_FQDN",
	null "CMS",a.cmts "CMTS", b.node "NODE", a.cus_accountnumber "ACCOUNT_NUM"
	from hsi_info a, customer_info b
	where a.cus_accountnumber=b.accountnumber";

        $sth=$dbh->prepare($query);
        $sth->execute();
        $sth->bind_columns({}, \( $cmmac,$fname,$lname,$street1,$street2,$city,$state,$zip,$phone,$devtype,$agentmac,$mtafqdn,$cmsfqdn,$cmts,$node,$acct));

        #print the results to a file
        
         while ($sth->fetch)
         {
            chomp($cmmac,$node,$devtype,$n1,$n2,$n3,$n4,$mtamac,$fname,$lname);
            chomp($n5,$street1,$street2,$city,$state,$zip,$acct,$n6,$phone,$n7);
            chomp($cmsfqdn,$cmts,$n8,$prov);
            print FILE "$cmmac,$fname,$lname,$street1,$street2,$city,$state,$zip,$phone,$devtype,$agentmac,$mtafqdn,$cmsfqdn,$cmts,$node,$acct\n";
         }
        close(FILE);

        $sth->finish;
        }

#        close(FILE0);
#        close(FILE1);
#        close(FILE2);
#        close(FILE3);


}

