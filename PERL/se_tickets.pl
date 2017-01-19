#!/usr/bin/perl

# Author: Joe Soria
# Date: July 23, 2007
#
# This script will alert when the freespace threashold is met.

push(@INC, "/home/jsoria/SCRIPTS/PERL");
require 'serv_info.pl';

use DBI;
use strict;
use Spreadsheet::WriteExcel;

$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

#Define your variables
my(@database,$contact,$domain,$test,$usr,$passwd,$sid,
$test,$dbh,$sth,$host,$row,$col1,$col2,
$col3,$col4,$col5,$col6,$col7,$col8,$col9,$col10,$col11,$col12,$col13,$worksheet,
$qname,$workbook,$log,$log2,$sth4,
$name,$status,$id,$owner,$timew,$timee,$timel,$lastu,$workbook,$workbook2,
$worksheet,@data,$data,$sth2,$counts,$dcounts,$dname,$sth3,$subj,$fmt2,$flag,$title);

@database=qw(samprd,remprd,remrep);
$contact='jsoria';
$domain='bresnan.com';
$test='2';
$usr="";
$passwd="";

$log='/home/jsoria/SCRIPTS/PERL/se_closed_tix.xls';

($usr,$passwd,$sid)=&serv_info($test);

$dbh = DBI->connect('dbi:Oracle:remrep',$usr,$passwd) || die "Cannot establish connection to the database";

$workbook = Spreadsheet::WriteExcel->new($log);

$dbh->{RaiseError}=1;
#Define your queries

if ($flag==1)
        {&get_se_tix($workbook); $title="Closed Ticket Report";}

sub get_se_tix
{

my($c,$t,$i,$assteam,$cnt);

$sth=$dbh->prepare(q{select assigned_team, category, type, item, count(*)
	from bz_incident_dat
	where create_date >= trunc(sysdate-7)
	and assigned_team='Tier4-System'
	group by assigned_team, category, type, item
	order by category
	});

$sth->execute;
$sth->bind_columns({}, \($assteam,$c,$t,$i,$cnt));

$row = $col1 = 0;
$col2 = 1;
$col3 = 2;
$col4 = 3;
$col5 = 4;

#Create the worksheet
$worksheet = $workbook->add_worksheet("SE CLOSED TICKETS");
$worksheet->set_column('A:A',15);
$worksheet->set_column('B:B',15);
$worksheet->set_column('C:C',20);
$worksheet->set_column('D:D',10);
$worksheet->set_column('E:E',15);

#Add any special formatting that you want
my $format = $workbook->add_format();
$format->set_align('center');
$format->set_bold();
$format->set_bg_color('yellow');
#Secondary format
$fmt2=$workbook->add_format();
$fmt2->set_text_wrap();
#Name the Columns
$worksheet->write($row, $col1, 'Assigned Team',$format);
$worksheet->write($row, $col2, 'Category',$format);
$worksheet->write($row, $col3, 'Type',$format);
$worksheet->write($row, $col4, 'Item',$format);
$worksheet->write($row, $col5, 'Count',$format);

#Write to the spreadsheet
while ($sth->fetch)
        {
        $row++;
        $worksheet->write($row, $col1, $assteam);
        $worksheet->write($row, $col2, $c);
        $worksheet->write($row, $col3, $t);
        $worksheet->write($row, $col4, $i);
        $worksheet->write($row, $col5, $cnt);
        }
$sth->finish;
}
close($log);

system("/usr/bin/uuencode se_closed_tix.xls /tmp/se_closed_tix.xls | /usr/bin/mailx -s \"SE Closed Tickets Report\" jsoria\@cablevision.com");

