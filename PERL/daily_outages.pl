#!/usr/bin/perl -w

# Author: Joe Soria
# Date: August 23, 2006
#
#

push(@INC, "/home/jsoria/SCRIPTS/PERL");
require 'serv_info.pl';
require 'get_date.pl';
require 'get_ystrday.pl';

use DBI;
use strict;
use Spreadsheet::WriteExcel;

$ENV{'ORACLE_SID'}="remprd";
$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

#Define your variables
my($date, @database,$contact,$domain,$test,$usr,$passwd,$sid,
$dbh,$sth,$host,$row,
$col1,$col2,$col3,$col4,$col5,$col6,$col7,$col8,$col9,$col10,
$col11,$col12,$col13,$col14,$col15,$col16,$col17,$col18,$col19,$col20,$col21,
$worksheet,$dd,
$qname,$workbook,$log,$log2,$sth4,
$name,$status,$id,$owner,$timew,$timee,$timel,$lastu,$workbook2,
@data,$data,$sth2,$counts,$dcounts,$dname,$sth3,$subj,$fmt2);

$date=&get_date;
$dd=&get_yest;
$contact='jsoria';
$domain='bresnan.com';
$test='2';
$usr="";
$passwd="";

#$log="/home/jsoria/SCRIPTS/PERL/$date.xls";
#$log="/home/jsoria/SCRIPTS/PERL/daily_outages_$dd.xls";
$log="/home/jsoria/SCRIPTS/PERL/daily_outages.xls";


($usr,$passwd,$sid)=&serv_info($test);

$dbh = DBI->connect('dbi:Oracle:remprd',$usr,$passwd) || die "Cannot establish connection to the database";

$dbh->{RaiseError}=1;
#Define your queries

##################################Outages#############################
##################################Outages#############################
##################################Outages#############################

my($repair,$market,$source,$impdesc,$stdate,$sttime,$fatt,$technot,$resdate,
$elapsed,$durnot,$durst,$cm,$mta,$video,$res,$inc);

$sth=$dbh->prepare(q{select nvl(a.city,substr(a.description,0,10)) "Market", a.source "Reported by",
a.description "Impact Description", trunc(to_date('01/01/1970')+a.create_date/86400) "Start Date",
to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+a.create_date/86400,'GMT','MST'),'hh24:mi:ss') "Time Created",
to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+a.firstattempt/86400,'GMT','MST'),'hh24:mi:ss') "First Attempt",
to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+a.techdispatchcontact/86400,'GMT','MST'),'hh24:mi:ss') "Tech Notified",
to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+a.techdispatchrepair/86400,'GMT','MST'),'hh24:mi:ss') "Repaired",
to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST'),'hh24:mi:ss') "Repaired",
(a.resolution_date-a.techdispatchcontact)/60 "Duration from Notification",
round((a.resolution_date-a.create_date)/60,0) "Duration from Start Time",
(a.techdispatchcontact-a.firstattempt)/60 "Time Elapsed",
b.current_total_docsis-b.current_online_docsis "CM",
b.current_total_mtas-b.current_online_mtas "MTA",
round((b.current_total_docsis-b.current_online_docsis)+(b.current_total_mtas-b.current_online_mtas)*2.738,0) "Video",
a.resolution_description, a.incident_id
from aradmin.bz_incident a, aradmin.bz_auspice_interface b
where NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') >= trunc(sysdate) -1.75
and NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') <= trunc(sysdate) -.75
--and a.firstattempt is not null
and a.source='Auspice'
and substr(a.incident_id,4)=substr(b.related_ticket_id,4)
and a.resolution_code != 'FA'
});

$sth->execute;
$sth->bind_columns({}, \($market,$source,$impdesc,$stdate,
$sttime,$fatt,$technot,$repair,$resdate,
$durnot,$durst,$elapsed,$cm,
$mta,$video,$res,$inc));

my $junk=' ';

$workbook = Spreadsheet::WriteExcel->new($log);

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
$col17= 16;
$col18= 17;
$col19= 18;
$col20= 19;
$col21= 20;

#Create the worksheet
$worksheet = $workbook->add_worksheet("Outages");
$worksheet->set_column('A:A',15);
$worksheet->set_column('B:B',15);
$worksheet->set_column('C:C',15);
$worksheet->set_column('D:D',15);
$worksheet->set_column('E:E',15);
$worksheet->set_column('F:F',15);
$worksheet->set_column('G:G',8);
$worksheet->set_column('H:H',8);
$worksheet->set_column('I:I',8);
$worksheet->set_column('J:J',8);
$worksheet->set_column('K:K',8);
$worksheet->set_column('L:L',8);
$worksheet->set_column('M:M',8);
$worksheet->set_column('N:N',8);
$worksheet->set_column('O:O',8);
$worksheet->set_column('P:P',8);
$worksheet->set_column('Q:Q',40);
$worksheet->set_column('R:R',40);
$worksheet->set_column('S:S',3);
$worksheet->set_column('T:T',3);
$worksheet->set_column('U:U',15);
$worksheet->set_row(0,85.50);

#Format Header
#Add any special formatting that you want
my $format = $workbook->add_format();
$format->set_align('center');
$format->set_bold();
$format->set_text_wrap();
$format->set_bg_color('yellow');
$format->set_size(8);
$format->set_border();
$format->set_font('Arial');

my $format2 = $workbook->add_format();
$format2->set_align('center');
$format2->set_bold();
$format2->set_text_wrap();
$format2->set_bg_color('yellow');
$format2->set_rotation('90');
$format2->set_size(8);
$format2->set_border();
$format2->set_font('Arial');

my $format3 = $workbook->add_format();
$format3->set_align('center');
$format3->set_text_wrap();
$format3->set_size(8);
$format3->set_border();
$format3->set_font('Arial');

#Secondary format
$fmt2=$workbook->add_format();
$fmt2->set_text_wrap();
#Name the Columns
$worksheet->write($row, $col1, 'Market',$format);
$worksheet->write($row, $col2, 'Reported By',$format);
$worksheet->write($row, $col3, 'Device',$format);
$worksheet->write($row, $col4, 'Impact Description',$format);
$worksheet->write($row, $col5, 'Start Date',$format);
$worksheet->write($row, $col6, 'Start Time (Original Detection Time)',$format2);
$worksheet->write($row, $col7, 'First Attempt at System Notification',$format2);
$worksheet->write($row, $col8, 'Tech or Dispatch Notified Time',$format2);
$worksheet->write($row, $col9, 'Time elapsed 1st call to contact (system)',$format2);
$worksheet->write($row, $col10, 'Resolve Time',$format2);
$worksheet->write($row, $col11, 'System Notification of Repair Time',$format2);
$worksheet->write($row, $col12, 'Duration from Notification to Repair (online)',$format2);
$worksheet->write($row, $col13, 'Duration Start Time-Repair (online) time',$format2);
$worksheet->write($row, $col14, 'CM',$format);
$worksheet->write($row, $col15, 'MTA',$format);
$worksheet->write($row, $col16, 'Video',$format);
$worksheet->write($row, $col17, 'Cause',$format);
$worksheet->write($row, $col18, 'Resolution',$format);
$worksheet->write($row, $col19, 'Preventable/Nonpreventable',$format2);
$worksheet->write($row, $col20, 'System remained on during',$format2);
$worksheet->write($row, $col21, 'INC',$format);

while ($sth->fetch)
        {
        $row++;
        $worksheet->write($row, $col1, $market,$format3);
        $worksheet->write($row, $col2, $source,$format3);
        $worksheet->write($row, $col3, $junk,$format3);
        $worksheet->write($row, $col4, $impdesc,$format3);
        $worksheet->write($row, $col5, $stdate,$format3);
        $worksheet->write($row, $col6, $sttime,$format3);
        $worksheet->write($row, $col7, $fatt,$format3);
        $worksheet->write($row, $col8, $technot,$format3);
        $worksheet->write($row, $col9, $elapsed,$format3);
        $worksheet->write($row, $col10, $resdate,$format3);
        $worksheet->write($row, $col11, $junk,$format3);
        $worksheet->write($row, $col12, $durnot,$format3);
        $worksheet->write($row, $col13, $durst,$format3);
        $worksheet->write($row, $col14, $cm,$format3);
        $worksheet->write($row, $col15, $mta,$format3);
        $worksheet->write($row, $col16, $video,$format3);
        $worksheet->write($row, $col17, $junk,$format3);
        $worksheet->write($row, $col18, $res,$format3);
        $worksheet->write($row, $col19, $junk,$format3);
        $worksheet->write($row, $col20, $junk,$format3);
        $worksheet->write($row, $col21, $inc,$format3);
        }
$sth->finish;

##############################END Outages#############################
##############################END Outages#############################
##############################END Outages#############################
