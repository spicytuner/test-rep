#!/usr/bin/perl
# Author: Joe Soria
# DATE: Sep 09, 2010
#
# This script grabs all of the active email address for bresnan.net out of alopa
# and writes them to a file. The file is then sent to CVC

push(@INC, "/home/jsoria/SCRIPTS/PERL");
push(@INC,"/home/jsoria/SCRIPTS/DATA");
require 'serv_info.pl';

use DBI;
use strict;
use Data::Dumper;
use Spreadsheet::WriteExcel;


$ENV{'ORACLE_SID'}="remrep";
$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

my($sth,$sth2,$test,$usr,$cm,$passwd,$sid,$host,$mdate,$acct,$astatus,$fname,$lname,$tn,$s1,$s2,$city,$state,$zip,$cmmac,$servtype,$mtamac,$vendor,$mta_fqdn,$csgstatus,$log,$workbook);
our ($dbh);

$test='2';
$usr="";
$passwd="";
($usr,$passwd,$sid)=&serv_info($test);

##################EDIT THESE
##################EDIT THESE
##################EDIT THESE
#open(FILE,"<full path of file you want to query against");
#open(LOG,">><full path of file you want to write to");
############################
############################
############################

open(FILE,"/home/jsoria/SCRIPTS/PERL/mac2.lst");
print STDOUT "Opened mac file\n";

#open(LOG,">/home/jsoria/SCRIPTS/PERL/results.csv");
#print STDOUT "Opened results file for write\n";

#gonna create this file:
$log='/home/jsoria/SCRIPTS/PERL/requested_info.xls';
$workbook = Spreadsheet::WriteExcel->new($log);


$dbh = DBI->connect('dbi:Oracle:remrep',$usr,$passwd) || die "Cannot establish connection to the database";
$dbh->{RaiseError}=1;

print STDOUT "Reading file\n";
while ($cm=<FILE>) {
	print STDOUT "$cm\n";

	$sth=$dbh->prepare(q{select a.csg_act,b.status, a.act_status,a.firstname,a.lastname,
    	a.telephone_number, a.street1, a.street2, a.city, a.state, a.zip, a.cmmac, a.service_type,
	a.mtamac,a.vendor,a.mta_fqdn 
	from vw_cust a, account_node_status b
	where lower(a.cmmac) = ?
	and a.csg_act=b.accountnumber});
	$sth->execute($cm);
	$sth->bind_columns({}, \($acct,$csgstatus,$astatus,$fname,$lname,$tn,$s1,$s2,$city,$state,$zip,$cmmac,$servtype,$mtamac,$vendor,$mta_fqdn));

my($row,$col1,$col2,$col3,$col4,$col5,$col6,$col7,$col8,$col9,$col10,$col11,$col12,$col13,$col14,$col15,$col16,$worksheet,$fmt2);
$row = $col1 = 0;
$col2 = 1;
$col3 = 2;
$col4 = 3;
$col5 = 4;
$col6 = 5;
$col7 = 6;
$col8 = 7;
$col9 = 8;
$col10= 9;
$col11= 10;
$col12= 11;
$col13= 12;
$col14= 13;
$col15= 14;
$col16= 15;

#Create the worksheet
$worksheet = $workbook->add_worksheet("awesome data");
$worksheet->set_column('A:A',15);
$worksheet->set_column('B:B',15);
$worksheet->set_column('C:C',20);
$worksheet->set_column('D:D',10);
$worksheet->set_column('E:E',15);
$worksheet->set_column('F:F',15);
$worksheet->set_column('G:G',15);
$worksheet->set_column('H:H',15);
$worksheet->set_column('I:I',20);
$worksheet->set_column('J:J',20);
$worksheet->set_column('K:K',15);
$worksheet->set_column('L:L',200);
$worksheet->set_column('M:M',200);
$worksheet->set_column('N:N',200);
$worksheet->set_column('O:O',200);
$worksheet->set_column('P:P',200);
$worksheet->set_column('Q:Q',200);

#Add any special formatting that you want
my $format = $workbook->add_format();
$format->set_align('center');
$format->set_bold();
$format->set_bg_color('yellow');
#Secondary format
$fmt2=$workbook->add_format();
$fmt2->set_text_wrap();


Name the Columns
$worksheet->write($row, $col1, 'Account Number',$format);
$worksheet->write($row, $col2, 'CSG STATUS',$format);
$worksheet->write($row, $col3, 'SPM STATUS',$format);
$worksheet->write($row, $col4, 'First Name',$format);
$worksheet->write($row, $col5, 'Last Name',$format);
$worksheet->write($row, $col6, 'Telephone Number',$format);
$worksheet->write($row, $col7, 'Street 1',$format);
$worksheet->write($row, $col8, 'Street2',$format);
$worksheet->write($row, $col9, 'City',$format);
$worksheet->write($row, $col10, 'State',$format);
$worksheet->write($row, $col11, 'Zip',$format);
$worksheet->write($row, $col12, 'CMMAC',$format);
$worksheet->write($row, $col13, 'Service Type',$format);
$worksheet->write($row, $col14, 'MTAMAC',$format);
$worksheet->write($row, $col15, 'Vendor',$format);
$worksheet->write($row, $col16, 'MTA_FQDN',$format);
#Write to the spreadsheet
while ($sth->fetch)
       {
       $row++;
        $worksheet->write($row, $col1, $acct);
        $worksheet->write($row, $col2, $csgstatus);
        $worksheet->write($row, $col3, $astatus);
        $worksheet->write($row, $col4, $fname);
        $worksheet->write($row, $col5, $lname);
        $worksheet->write($row, $col6, $tn);
        $worksheet->write($row, $col7, $s1);
        $worksheet->write($row, $col8, $s2);
        $worksheet->write($row, $col9, $city);
        $worksheet->write($row, $col10, $state);
        $worksheet->write($row, $col11, $zip);
        $worksheet->write($row, $col12, $cmmac);
        $worksheet->write($row, $col13, $servtype);
        $worksheet->write($row, $col14, $mtamac);
        $worksheet->write($row, $col15, $vendor);
        $worksheet->write($row, $col16, $mta_fqdn);
        }
}

$dbh->disconnect;
close(LOG);
system("/usr/bin/uuencode requested_info.xls /tmp/rinfo.xls | /usr/bin/mailx -s \"Query Results\" jsoria\@cablevision.com")
