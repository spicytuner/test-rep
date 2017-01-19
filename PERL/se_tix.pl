#!/usr/bin/perl -w

push(@INC, "/export/home/jsoria/SCRIPTS/PERL");
require 'serv_info.pl';

use DBI;
use strict;
use diagnostics;
use Spreadsheet::WriteExcel;
use Getopt::Long;
use Data::Dumper;
use MIME::Lite;
use POSIX qw(strftime);

$ENV{'ORACLE_SID'}="remrep";
$ENV{'ORACLE_HOME'}="/opt/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/opt/oracle";

my($title,$dbh,$sth,$sth1,$sth2,$sth3,$sth8,$tblcount,$usr,$passwd,$sid,$test,$cnt,
$strikelistdate,$log,$file,$format,$format4,$workbook);

$log="/export/home/jsoria/SCRIPTS/PERL/REPORTS/se_tix.xls";

$workbook = Spreadsheet::WriteExcel->new($log);

#Add any special formatting that you want
our $format = $workbook->add_format();
$format->set_align('center');
$format->set_bold();
$format->set_text_wrap();
$format->set_bg_color('yellow');
$format->set_size(8);
$format->set_border();
$format->set_font('Arial');

our $format4 = $workbook->add_format();
$format4->set_align('center');
$format4->set_text_wrap();
$format4->set_size(8);
$format4->set_border();
$format4->set_font('Arial');

$test='2';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);

$dbh = DBI->connect('dbi:Oracle:remrep',$usr,$passwd) || die "Cannot establish connection to the database";
$dbh->{RaiseError}=1;

my($flag);
$flag=1;

if ($flag==1)
        {&get_seclosed($workbook); $title="SE TICKET REPORT";}

sub get_seclosed 
{
my $workbook=shift;
my($worksheet,$row,$col1,$col2,$col3,$col4,$col5,$col6,$col7,$col8,$col9,$col10,$col11,$col12,$col13,
	$ateam,$cat,$type,$item,$cnt);

$row = $col1 = 0;
$col2 = 1;
$col3 = 2;
$col4 = 3;
$col5 = 4;
$col6 = 5;

local $dbh->{LongReadLen} = 1_000_000;
$sth=$dbh->prepare(q{select assigned_team, category, type, item, count(*)
        from bz_incident_dat
        where create_date >= trunc(sysdate-7)
        and assigned_team='Tier4-System'
        group by assigned_team, category, type, item
        order by category
});
$sth->execute();
$sth->bind_columns({}, \($ateam,$cat,$type,$item,$cnt));

##Create the worksheet
$worksheet = $workbook->add_worksheet("SE Ticket Report");
$worksheet->set_column('A:A',20);
$worksheet->set_column('B:B',20);
$worksheet->set_column('C:C',20);
$worksheet->set_column('D:D',20);
$worksheet->set_column('E:E',20);
$worksheet->set_row(0,100);
#$worksheet->set_row(0,85.50);

#enter the date information
#$worksheet->write($row++, $col1, 'Reporting 07/01/2011 to present'. $sd . '-' . $ed,$format4);
#$worksheet->write($row++, $col1, 'Reporting 07/01/2011 to present',$format4);

#Name the Columns
$worksheet->write($row, $col1, 'Assigned Team',$format);
$worksheet->write($row, $col2, 'Category',$format);
$worksheet->write($row, $col3, 'Type',$format);
$worksheet->write($row, $col4, 'Item',$format);
$worksheet->write($row, $col5, 'Count',$format);

#logger(10,"Performing Report Query");

while ($sth->fetch)
        {

        #logger(10,"Fetching Query Results and writing them to Excel");
        $row++;
        $worksheet->write($row, $col1, $ateam,$format4);
        $worksheet->write($row, $col2, $cat,$format4);
        $worksheet->write($row, $col3, $type,$format4);
        $worksheet->write($row, $col4, $item,$format4);
        $worksheet->write($row, $col5, $cnt,$format4);
        }

$sth->finish;
}
$workbook->close();

system("/usr/bin/uuencode se_tix.xls /tmp/se_tix.xls | /usr/bin/mailx -s \"SE Ticket Report\" jsoria\@cablevision.com");
