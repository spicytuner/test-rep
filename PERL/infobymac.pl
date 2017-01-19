#!/usr/bin/perl
#
# Author: Joe Soria
# Date: January 17, 2007
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
my($mac,$format,@database,$contact,$domain,$test,$usr,$passwd,$sid,
$test,$dbh,$sth,$host,$row,
$col1,$col2,$col3,$col4,$col5,$col6,$col7,$col8,$col9,$col10,
$col11,$col12,$col13,$col14,$col15,$col16,$col17,$col18,$col19,$col20,$col21,
$worksheet,$qname,$workbook,$log,$log2,$sth4,
$name,$status,$id,$owner,$timew,$timee,$timel,$lastu,$workbook2,
$worksheet,@data,$data,$sth2,$counts,$dcounts,$dname,$sth3,$subj,$fmt2);

$contact='jsoria';
$domain='bresnan.com';
$test='2';
$usr="";
$passwd="";
$log='/home/jsoria/SCRIPTS/PERL/infobymac.xls';
open(FILE,"/tmp/maclist.txt");

($usr,$passwd,$sid)=&serv_info($test);

$dbh = DBI->connect('dbi:Oracle:remrep',$usr,$passwd) || die "Cannot establish connection to the database";

$dbh->{RaiseError}=1;
#Define your queries

##################################Raw Availability#############################
##################################Raw Availability#############################
##################################Raw Availability#############################

$workbook = Spreadsheet::WriteExcel->new($log);

$row = $col1 = 0;
$col2 = 1;
$col3 = 2;
$col4 = 3;
$col5 = 4;
$col6 = 5;

#Create the worksheet
$worksheet = $workbook->add_worksheet("AccountInfobyMac");
$worksheet->set_column('A:A',20);
$worksheet->set_column('B:B',15);
$worksheet->set_column('C:C',15);
$worksheet->set_column('D:D',15);
$worksheet->set_column('E:E',40);
$worksheet->set_row(0,33.75);

my $format = $workbook->add_format();
$format->set_align('center');
$format->set_text_wrap();
$format->set_size(8);
$format->set_border();
$format->set_font('Arial');

$worksheet->write($row, $col1, 'Account Number', $format);
$worksheet->write($row, $col2, 'CMTS', $format);
$worksheet->write($row, $col3, 'CMMAC', $format);
$worksheet->write($row, $col4, 'MTAMAC', $format);
$worksheet->write($row, $col5, 'Imagefile', $format);

my ($acct,$cmts,$cmmac,$mtamac,$ifile);

while ($mac=<FILE>)
{
chomp($mac);
$sth=$dbh->prepare(q{select accountnumber, cmts, cmmac, mtamac, imagefile 
from cust where lower(cmmac) = ? });
$sth->execute($mac);
$sth->bind_columns({}, \($acct,$cmts,$cmmac,$mtamac,$ifile));


while ($sth->fetch)
        {
	print STDOUT "$acct,$cmts,$cmmac,$mtamac,$ifile\n";
        $row++;
        $worksheet->write($row, $col1, $acct, $format);
        $worksheet->write($row, $col2, $cmts, $format);
        $worksheet->write($row, $col3, $cmmac, $format);
        $worksheet->write($row, $col4, $mtamac, $format);
        $worksheet->write($row, $col5, $ifile, $format);
        }
}
$sth->finish;

$dbh->disconnect;
