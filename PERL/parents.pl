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
$worksheet,
$qname,$workbook,$log,$log2,$sth4,
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

##################################Raw Availability#############################
##################################Raw Availability#############################
##################################Raw Availability#############################

my ();

$sth=$dbh->prepare(q{
});
$sth->execute;
$sth->bind_columns({}, \());

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


system("uuencode /home/jsoria/SCRIPTS/PERL/undef.xls /tmp/undef.xls \| mailx -s \"Undef Report\" jrobey\@bresnan.com jsoria\@bresnan.com");
