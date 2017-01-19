#!/usr/bin/perl

# Author: Joe Soria
# Date: July 8, 2004
#
#

push(@INC, "/home/jsoria/SCRIPTS/PERL");
require 'serv_info.pl';

use DBI;
use strict;
use Spreadsheet::WriteExcel;

$ENV{'ORACLE_SID'}="remrep";
$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

#Define your variables
my($format,@database,$contact,$domain,$test,$usr,$passwd,$sid,
$test,$dbh,$sth,$host,$row,
$col1,$col2,$col3,$col4,$col5,$col6,$col7,$col8,$col9,$col10,
$col11,$col12,$col13,$col14,$col15,$col16,$col17,$col18,$col19,$col20,$col21,
$worksheet,$qname,$workbook,$log,$log2,$sth4,$sth1,
$name,$status,$id,$owner,$timew,$timee,$timel,$lastu,$workbook2,
$worksheet,@data,$data,$sth2,$counts,$dcounts,$dname,$sth3,$subj,$fmt2);

$contact='jsoria';
$domain='bresnan.com';
$test='2';
$usr="";
$passwd="";
$log='/home/jsoria/SCRIPTS/PERL/undef.xls';

($usr,$passwd,$sid)=&serv_info($test);

$dbh = DBI->connect('dbi:Oracle:remrep',$usr,$passwd) || die "Cannot establish connection to the database";

$dbh->{RaiseError}=1;
#Define your queries

##################################Nodes#############################
##################################Nodes#############################
##################################Nodes#############################

my ($cmts,$cms,$node,$pnode);

$sth=$dbh->prepare(q{select cmts, sum(cms) "CM's", sum(node) "UNDEF's", (sum(node)/sum(cms))  "% of UNDEF's"
from (
select distinct cmts, count(cmmac) as cms,0 as node
from cust
where cmmac is not null
and accountnumber like '8313%'
group by cmts
union
select distinct cmts,0 as cms,count(node) as node
from cust
where node='undef'
and accountnumber like '8313%'
group by cmts
)
group by cmts
});
$sth->execute;
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
and accountnumber like '8313%'
});
$sth4->execute;
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

my $format = $workbook->add_format();
$format->set_align('center');
#$format->set_bold();
$format->set_text_wrap();
$format->set_size(8);
$format->set_border();
$format->set_font('Arial');

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

my ($aan,$can,$cstat,$cmmac,$mtamac,$dtype);

$sth1=$dbh->prepare(q{select '^' ||a.accountnumber "ALOPA ACCOUNT NUMBER", 
'^' || b.accountnumber "CSG ACCOUNT NUMBER", 
b.status "CSG STATUS", a.cmmac, a.mtamac, a.devicetype
from cust a, account_node_status b
where upper(b.macaddress)=upper(a.cmmac)
and a.accountnumber != b.accountnumber
and a.accountnumber like '8313%'
});
$sth1->execute;
$sth1->bind_columns({}, \($aan,$can,$cstat,$cmmac,$mtamac,$dtype));

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

my $format = $workbook->add_format();
$format->set_align('center');
#$format->set_bold();
$format->set_text_wrap();
$format->set_size(8);
$format->set_border();
$format->set_font('Arial');

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
        $worksheet->write($row, $col4, $cmmac, $format);
        $worksheet->write($row, $col5, $mtamac, $format);
        $worksheet->write($row, $col6, $dtype, $format);
        }
$sth1->finish;

##################################Active in Alopa Not Active in CSG#############################
##################################Active in Alopa Not Active in CSG#############################
##################################Active in Alopa Not Active in CSG#############################

my ($an,$cstat,$cmmac,$dtype);

$sth2=$dbh->prepare(q{select '^' || a.accountnumber "Account Number", b.status "Status", 
a.cmmac "CM MAC Address", a.devicetype "Device Type"
from cust a, account_node_status b
where a.accountnumber=b.accountnumber
and status != 'Active'
});
$sth2->execute;
$sth2->bind_columns({}, \($an,$cstat,$cmmac,$dtype));

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

my $format = $workbook->add_format();
$format->set_align('center');
#$format->set_bold();
$format->set_text_wrap();
$format->set_size(8);
$format->set_border();
$format->set_font('Arial');

$worksheet->write($row, $col1, 'Account Number', $format);
$worksheet->write($row, $col2, 'CSG Status', $format);
$worksheet->write($row, $col3, 'CMMAC', $format);
$worksheet->write($row, $col4, 'Device Type', $format);

while ($sth2->fetch)
        {
        $row++;
        $worksheet->write($row, $col1, $an, $format);
        $worksheet->write($row, $col2, $cstat, $format);
        $worksheet->write($row, $col3, $cmmac, $format);
        $worksheet->write($row, $col4, $dtype, $format);
        }
$sth2->finish;

##################################Active Subs Missing from Alopa#############################
##################################Active Subs Missing from Alopa#############################
##################################Active Subs Missing from Alopa#############################

my ($an,$cstat,$cmmac);

$sth3=$dbh->prepare(q{select '^' || accountnumber "Account Number", status "Status", macaddress "CM MAC Address"
from account_node_status
where accountnumber in (
select distinct b.accountnumber 
from account_node_status b
where b.status = 'Active'
and b.macaddress is not null
minus
select distinct a.accountnumber 
from cust a)
});
$sth3->execute;
$sth3->bind_columns({}, \($an,$cstat,$cmmac));

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

my $format = $workbook->add_format();
$format->set_align('center');
#$format->set_bold();
$format->set_text_wrap();
$format->set_size(8);
$format->set_border();
$format->set_font('Arial');

$worksheet->write($row, $col1, 'Account Number', $format);
$worksheet->write($row, $col2, 'CSG Status', $format);
$worksheet->write($row, $col3, 'CMMAC', $format);

while ($sth3->fetch)
        {
        $row++;
        $worksheet->write($row, $col1, $an, $format);
        $worksheet->write($row, $col2, $cstat, $format);
        $worksheet->write($row, $col3, $cmmac, $format);
        }
$sth3->finish;
$dbh->disconnect;
