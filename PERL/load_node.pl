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

$dbh->{RaiseError}=0;
$dbh->{PrintError}=0;

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
print "Step 1 of 5\n";
	&load_ans; 
print "Step 2 of 5\n";
	&mysql_cmts;
print "Step 3 of 5\n";
	&data_by_prov;
print "Step 4 of 5\n";
	&build_cust;
print "Step 5 of 5\n";
	&delete_crap;
}

if ($loadcdi) 
{
print "Step 1 of 6\n";
	&mysql_cmts;
print "Step 2 of 6\n";
	&data_by_prov;
print "Step 3 of 6\n";
	&build_cust;
print "Step 4 of 6\n";
	&delete_crap;
}

if ($loadcust) 
{
print "Step 1 of 5\n";
	&load_ans; 
print "Step 2 of 5\n";
	&mysql_cmts;
print "Step 3 of 5\n";
	&data_by_prov;
print "Step 4 of 5\n";
	&build_cust;
print "Step 5 of 5\n";
	&delete_crap;
}

if ($loadvsm)
{
}

if ($loadvsmonly)
{
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
	print STDOUT "Grabbing True CMTS Information from MySQL\n";
	print LOG2 "Grabbing True CMTS Information from MySQL\n";
        my($mtaip,$cnt,$dbh2,$sth9,$sth10,$sth11,$nmsuser,$nmspass,$mtamac);

        $test='3';

        ($usr,$passwd,$sid)=&serv_info($test);
        $nmsuser=$usr;
        $nmspass=$passwd;

        print STDOUT "connecting to mysql\n";
        print LOG2 "connecting to mysql\n";

        $dbh2 = DBI->connect("dbi:mysql:database=Inventory:$sid", $nmsuser, $nmspass) ||  
	die "Can't connect to nms2!";

        $sth9=$dbh2->prepare(q{select cm_mac, cmts_name, mta_ip, mta_mac
	from cm 
	inner join cmts on cm.cmts_id = cmts.cmts_id 
	left join mta on cm.cm_id = mta.cm_id });
        $sth9->execute();
        $sth9->bind_columns({}, \($cmmac,$cmts,$mtaip,$mtamac));

        print LOG2 "truncating cmmac_to_cmts table\n";

        $sth11=$dbh->prepare("truncate table cmmac_to_cmts");
        $sth11->execute();

        print LOG2 "fetching data from mysql\n";

        while ($sth9->fetch)
        {
                $sth10=$dbh->prepare(q{ insert into cmmac_to_cmts values ( ?,?,?,?) });
                $sth10->execute($cmmac,$cmts,$mtaip,$mtamac);
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
	and (upper(j.packageid) not like '%VOIP%ONLY%' or upper(j.packageid) not like '%V%_ONLY%')
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
        and (a.packageid not like '%VOI%' or a.packageid not like '%_V%'))});
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

sub delete_crap
{
	$sth=$dbh->prepare(q{delete from cust where devicetype='MTA' and mtamac is null });
	$sth->execute();

	$sth=$dbh->prepare(q{delete from cust where devicetype='CM' and imagefile is null });
	$sth->execute();
	
	$sth=$dbh->prepare(q{truncate table cust_missing});
	$sth->execute();
	
	$sth=$dbh->prepare(q{insert into cust_missing  (
        select distinct e.macaddressofcm "CMMAC"
        from subscribertopackage a, subscriber b, subscriberproxy c, pi d, hsd e,
        account_node_status f, locationtree g
        where a.parentref=b.recordnumber
        and b.recordnumber=c.recordnumber
        and c.recordnumber=d.parentref
        and e.parentref=d.parentref
        and d.userid=f.accountnumber
        and b.locationid=g.recordnumber
        and (a.packageid like '%BB%' or a.packageid like '%COM%')
        and (a.packageid like '%VOIP%' or a.packageid like '%_V%')
        and a.deletestatus=0
        and d.deletestatus=0
        and e.deletestatus=0
        minus
        select distinct cmmac
        from cust
        )});
	$sth->execute();
	
	$sth=$dbh->prepare(q{insert into cust 
  select distinct d.userid, nvl(f.node,'undef') "NODE", d.firstname "FIRSTNAME",
        d.lastname "LASTNAME", null "PHONE",
        replace(d.streetaddress1,',',null) "STREET1",
        replace(d.streetaddress2,',',null) "STREET2",
        d.city "CITY", d.state "STATE",
        d.zipcode "ZIP",
        e.macaddressofcm "CMMAC", 'HSD' "SERVICE_TYPE", null "MTAFQDN",
       null "MTAMAC", null "CMSFQDN", null "MTA_VENDOR", e.imagefile "IMAGEFILE",
        g.locationname "CMTS", sysdate , 0 ,1 ,1 ,'CM',a.packageid,null
        from subscribertopackage a, subscriber b, subscriberproxy c, pi d, hsd e,
        account_node_status f, locationtree g        
        where a.parentref=b.recordnumber
        and b.recordnumber=c.recordnumber
        and c.recordnumber=d.parentref
        and e.parentref=d.parentref
        and d.userid=f.accountnumber
        and b.locationid=g.recordnumber
        and (a.packageid like '%BB%' or a.packageid like '%COM%')
        and (a.packageid like '%VOIP%' or a.packageid like '%_V%')
        and a.deletestatus=0
        and d.deletestatus=0
        and e.deletestatus=0
        and e.macaddressofcm in (select cmmac from cust_missing)});
	$sth->execute();
	
	$sth=$dbh->prepare(q{insert into cust
	select distinct d.userid, nvl(f.node,'undef') "NODE", d.firstname "FIRSTNAME",
        d.lastname "LASTNAME", null "PHONE",
        replace(d.streetaddress1,',',null) "STREET1",
        replace(d.streetaddress2,',',null) "STREET2",
        d.city "CITY", d.state "STATE",
        d.zipcode "ZIP",
        e.macaddressofcm "CMMAC", 'HSD' "SERVICE_TYPE", null "MTAFQDN",
       null "MTAMAC", null "CMSFQDN", null "MTA_VENDOR", e.imagefile "IMAGEFILE",
        g.locationname "CMTS", sysdate , 0 ,1 ,1 ,'CM',a.packageid,null
        from subscribertopackage a, subscriber b, subscriberproxy c, pi d, hsd e,
        account_node_status f, locationtree g        
        where a.parentref=b.recordnumber
        and b.recordnumber=c.recordnumber
        and c.recordnumber=d.parentref
        and e.parentref=d.parentref
        and d.userid=f.accountnumber
        and b.locationid=g.recordnumber
        and a.deletestatus=0
        and d.deletestatus=0
        and e.deletestatus=0
                and e.macaddressofcm in
        (select macaddressofcm from hsd
        minus
        select cmmac
        from cust)});
	$sth->execute();
	
	print  "Updating CMTS Information\n";
	$sth=$dbh->prepare(q{update cust a
	set a.cmts=(select b.cmts from cmmac_to_cmts b
	where a.cmmac=b.cmmac)});
	$sth->execute();
        
}


print LOG2 "Finished with initial CUST LOAD\n";


print LOG2 "Auspice Update Complete!!!\n";

sub undefined_nodes
{
	my $workbook=shift;
	print LOG2 "Create Undefined Node Report\n";
	my ($cmts,$cms,$node,$pnode);

	$sth=$dbh->prepare(q{select cmts, sum(cms) "CM's", sum(node) "UNDEF's", (sum(node)/sum(cms))  "% of UNDEF's"
	from (select distinct cmts, count(cmmac) as cms,0 as node
	from cust
	where cmmac is not null
	and (accountnumber like '8313%' or accountnumber like '8029')
	group by cmts
	union
	select distinct cmts,0 as cms,count(node) as node
	from cust
	where node='undef'
	and (accountnumber like '8313%' or accountnumber like '8029')
	group by cmts)
	group by cmts});
	$sth->execute();
	$sth->bind_columns({}, \($cmts,$cms,$node,$pnode));

	$workbook = Spreadsheet::WriteExcel->new($log);
	$row = $col1 = 0;
	$col2 = 1;
	$col3 = 2;
	$col4 = 3;
	$col5 = 4;

	#Create the worksheet
	$worksheet = $workbook->add_worksheet("Node");
	$worksheet->set_column('A:A',15);
	$worksheet->set_column('B:B',15);
	$worksheet->set_column('C:C',15);
	$worksheet->set_column('D:D',15.2);
	$worksheet->set_row(0,33.75);

	my $format = $workbook->add_format();
	$format->set_align('center');
	#$format->set_bold();
	$format->set_text_wrap();
	$format->set_size(8);
	$format->set_border();
	$format->set_font('Arial');

	my $format2 = $workbook->add_format();
	$format2->set_align('center');
	#$format2->set_bold();
	$format2->set_text_wrap();
	$format2->set_bg_color('light yellow');
	$format2->set_size(8);
	$format2->set_border();
	$format2->set_font('Arial');
	$format2->set_num_format('0.0000%');

	$worksheet->write($row, $col1, 'CMTS', $format);
	$worksheet->write($row, $col2, 'CMs', $format);
	$worksheet->write($row, $col3, 'Undef Node', $format);
	$worksheet->write($row, $col4, 'Percent Undef', $format);

	while ($sth->fetch)
        {
        	$row++;
        	$worksheet->write($row, $col1, $cmts, $format);
        	$worksheet->write($row, $col2, $cms, $format);
        	$worksheet->write($row, $col3, $node, $format);
        	$worksheet->write($row, $col4, $pnode, $format2);
        }
	$sth->finish;

##################################Accounts Missing Nodes############################
##################################Accounts Missing Nodes############################
##################################Accounts Missing Nodes############################

	my ($an,$fname,$lname,$cmmac,$mtamac);

	$sth4=$dbh->prepare(q{select '^' || accountnumber "Account Number", firstname, lastname,
	cmmac, mtamac
	from cust
	where node='undef'
	and (accountnumber like '8313%' or accountnumber like '8029')});
	$sth4->execute();
	$sth4->bind_columns({}, \($an,$fname,$lname,$cmmac,$mtamac));

	$row = $col1 = 0;
	$col2 = 1;
	$col3 = 2;
	$col4 = 3;
	$col5 = 4;
	$col6 = 5;

	#Create the worksheet
	$worksheet = $workbook->add_worksheet("Accounts without Nodes");
	$worksheet->set_column('A:A',15);
	$worksheet->set_column('B:B',15);
	$worksheet->set_column('C:C',15);
	$worksheet->set_column('D:D',15);
	$worksheet->set_column('E:E',15);
	$worksheet->set_row(0,33.75);

	$worksheet->write($row, $col1, 'Account Number', $format);
	$worksheet->write($row, $col2, 'FirstName', $format);
	$worksheet->write($row, $col3, 'LastName', $format);
	$worksheet->write($row, $col4, 'CM MAC', $format);
	$worksheet->write($row, $col5, 'MTA MAC', $format);

	while ($sth4->fetch)
        {
		$row++;
                $worksheet->write($row, $col1, $an, $format);
                $worksheet->write($row, $col2, $fname, $format);
                $worksheet->write($row, $col3, $lname, $format);
                $worksheet->write($row, $col4, $cmmac, $format);
                $worksheet->write($row, $col5, $mtamac, $format);
	}
        $sth4->finish;

##################################Macs on Wrong Account#############################
##################################Macs on Wrong Account#############################
##################################Macs on Wrong Account#############################

	my ($aan,$can,$cstat,$cmmac2,$mtamac2,$dtype,$sth1);

	$sth1=$dbh->prepare(q{select '^' ||a.accountnumber "ALOPA ACCOUNT NUMBER", 
	'^' || b.accountnumber "CSG ACCOUNT NUMBER", 
	b.status "CSG STATUS", a.cmmac, a.mtamac, a.devicetype
	from cust a, account_node_status b
	where upper(b.macaddress)=upper(a.cmmac)
	and a.accountnumber != b.accountnumber
	and (accountnumber like '8313%' or accountnumber like '8029')});
	$sth1->execute();
	$sth1->bind_columns({}, \($aan,$can,$cstat,$cmmac2,$mtamac2,$dtype));

	#$workbook = Spreadsheet::WriteExcel->new($log);

	$row = $col1 = 0;
	$col2 = 1;
	$col3 = 2;
	$col4 = 3;
	$col5 = 4;

	#Create the worksheet
	$worksheet = $workbook->add_worksheet("Mac on Wrong Account in Alopa");
	$worksheet->set_column('A:A',15);
	$worksheet->set_column('B:B',15);
	$worksheet->set_column('C:C',15);
	$worksheet->set_column('D:D',15);
	$worksheet->set_column('E:E',15);
	$worksheet->set_column('F:F',15);
	$worksheet->set_row(0,33.75);

	$worksheet->write($row, $col1, 'Alopa Account Number', $format);
	$worksheet->write($row, $col2, 'CSG Account Number', $format);
	$worksheet->write($row, $col3, 'CSG Status', $format);
	$worksheet->write($row, $col4, 'CMMAC', $format);
	$worksheet->write($row, $col5, 'MTAMAC', $format);
	$worksheet->write($row, $col6, 'Device Type', $format);

		while ($sth1->fetch)
		{
                	$row++;
                        $worksheet->write($row, $col1, $aan, $format);
                        $worksheet->write($row, $col2, $can, $format);
                        $worksheet->write($row, $col3, $cstat, $format);
                        $worksheet->write($row, $col4, $cmmac2, $format);
                        $worksheet->write($row, $col5, $mtamac2, $format);
                        $worksheet->write($row, $col6, $dtype, $format);
                }
                $sth1->finish;

##################################Active in Alopa Not Active in CSG#############################
##################################Active in Alopa Not Active in CSG#############################
##################################Active in Alopa Not Active in CSG#############################

	my ($an2,$cstat2,$cmmac3,$dtype2);

	$sth2=$dbh->prepare(q{select '^' || a.accountnumber "Account Number", b.status "Status", 
	a.cmmac "CM MAC Address", a.devicetype "Device Type"
	from cust a, account_node_status b
	where a.accountnumber=b.accountnumber
	and status != 'Active'});
	$sth2->execute();
	$sth2->bind_columns({}, \($an2,$cstat2,$cmmac3,$dtype2));

	#$workbook = Spreadsheet::WriteExcel->new($log);

	$row = $col1 = 0;
	$col2 = 1;
	$col3 = 2;
	$col4 = 3;
	$col5 = 4;
	
	#Create the worksheet
	$worksheet = $workbook->add_worksheet("Active in Alopa,Not Active CSG");
	$worksheet->set_column('A:A',15);
	$worksheet->set_column('B:B',15);
	$worksheet->set_column('C:C',15);
	$worksheet->set_column('D:D',15.2);
	$worksheet->set_row(0,33.75);

	$worksheet->write($row, $col1, 'Account Number', $format);
	$worksheet->write($row, $col2, 'CSG Status', $format);
	$worksheet->write($row, $col3, 'CMMAC', $format);
	$worksheet->write($row, $col4, 'Device Type', $format);

	while ($sth2->fetch)
	{
		$row++;
		$worksheet->write($row, $col1, $an2, $format);
		$worksheet->write($row, $col2, $cstat2, $format);
		$worksheet->write($row, $col3, $cmmac3, $format);
		$worksheet->write($row, $col4, $dtype2, $format);
	}
	$sth2->finish;

##################################Active Subs Missing from Alopa#############################
##################################Active Subs Missing from Alopa#############################
##################################Active Subs Missing from Alopa#############################


	my ($an3,$cstat3,$cmmac4);

	$sth3=$dbh->prepare(q{select '^' || accountnumber "Account Number", status "Status", macaddress "CM MAC Address"
	from account_node_status
	where accountnumber in (
	select distinct b.accountnumber 
	from account_node_status b
	where b.status = 'Active'
	and b.macaddress is not null
	minus
	select distinct a.accountnumber 
	from cust a)});
	$sth3->execute();
	$sth3->bind_columns({}, \($an3,$cstat3,$cmmac4));

	#$workbook = Spreadsheet::WriteExcel->new($log);

	$row = $col1 = 0;
	$col2 = 1;
	$col3 = 2;
	$col4 = 3;
	
	#Create the worksheet
	$worksheet = $workbook->add_worksheet("Active Subs Missing from Alopa");
	$worksheet->set_column('A:A',15);
	$worksheet->set_column('B:B',15);
	$worksheet->set_column('C:C',15);
	$worksheet->set_row(0,33.75);
	
	$worksheet->write($row, $col1, 'Account Number', $format);
	$worksheet->write($row, $col2, 'CSG Status', $format);
	$worksheet->write($row, $col3, 'CMMAC', $format);

	while ($sth3->fetch)
	{
		$row++;
		$worksheet->write($row, $col1, $an3, $format);
		$worksheet->write($row, $col2, $cstat3, $format);
		$worksheet->write($row, $col3, $cmmac4, $format);
	}
	$sth3->finish;
	$dbh->disconnect;
}


sub mail_undef_rpt
{
	print LOG2 "Mailing Undefined Node Report\n";
	#system("/usr/bin/uuencode /home/jsoria/SCRIPTS/PERL/undef.xls /tmp/undef.xls | mailx -s "Missing Nodes" jsoria\@bresnan.com rbeauto\@bresnan.com kstief\@bresnan.com gwilliams\@bresnan.com bnielsen\@bresnan.com lwirtala\@bresnan.com jadams\@bresnan.com jlapka\@bresnan.com mmckenzie\@bresnan.com rmoore\@bresnan.com kkirchner\@bresnan.com wpeltier\@bresnan.com cdunton\@bresnan.com lstrouf\@bresnan.com");

	#uuencode /home/jsoria/SCRIPTS/PERL/undef.xls /tmp/undef.xls | mailx -s "Missing Nodes" jsoria\@bresnan.com
}
