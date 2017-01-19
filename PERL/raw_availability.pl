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

$ENV{'ORACLE_SID'}="remprd";
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
$log='/home/jsoria/SCRIPTS/PERL/rawavailability.xls';
#$log2='/home/jsoria/SCRIPTS/PERL/seopen_tickets.xls';

($usr,$passwd,$sid)=&serv_info($test);

$dbh = DBI->connect('dbi:Oracle:remprd',$usr,$passwd) || die "Cannot establish connection to the database";

$dbh->{RaiseError}=1;
#Define your queries

##################################Raw Availability#############################
##################################Raw Availability#############################
##################################Raw Availability#############################

my ($system,$tothsi,$totbdp,$plhsi,$plbdp,$ashsi,$asbdp);

$sth=$dbh->prepare(q{select distinct "City",sum("TOTCM") "Total HSI Availability", sum("TOTBDP") "Total BDP Availability", 
sum("PLANTCM") "Plant HSI Availability", sum("PLANTBDP") "Plant BDP Availability", 
sum("ASCM") "Advanced Services HSI", sum("ASBDP") "Advanced Service BDP"
from (
select distinct "City","CM" "TOTCM",max("BDP") "TOTBDP", 0 "PLANTCM", 0 "PLANTBDP", 0 "ASCM", 0 "ASBDP"
from 
(
select distinct "City", round(1-(sum(CMDOWN)/SUM(CMMIN)),4) "CM",
round(1-(sum(MTADOWN)/SUM(MTAMIN)),4) "BDP"
from 
     (
     select distinct A "City", sum(B) "CM", sum(C) "MTA", sum(B)*1440*31 "CMMIN",
     sum(C)*1440*31 "MTAMIN",0 "CMDOWN",0 "MTADOWN"
     from (
          select b.cmts_name "A", count(*) "B", 0 "C"
          from cust a, cmts_name b
          where a.cmts=b.cmts
          and a.data=1
          group by b.cmts_name
     union
          select b.cmts_name "A", 0 "B", count(*) "C"
          from cust a, cmts_name b
          where a.cmts=b.cmts
          and a.bdp=1
          group by b.cmts_name
          )
     group by A
union
     select distinct A "City", 0 "CM", 0 "MTA",0 "CMMIN",
     0 "MTAMIN",sum(B)*sum(C) "CMDOWN", sum(B)*sum(D) "MTADOWN"
     from (
          select z.cmts_name "A",
          b.current_total_docsis-b.current_online_docsis "C",
          b.current_total_mtas-b.current_online_mtas "D",
          round((a.techdispatchrepair-a.create_date)/60,0) "B"
          from aradmin.bz_incident a, aradmin.bz_auspice_interface b, cmts_name z
          where NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') >= '09/18/2006 06:00:00'
          and NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') <= '10/17/2006 05:59:59'
          and a.cmts is not null
          and a.cmts=z.cmts
           and (a.firstattempt is not null or a.techdispatchrepair is not null)
          and a.source IN ('Auspice','NMS')
          and substr(a.incident_id,4)=substr(b.related_ticket_id,4)
          and a.resolution_code != 'FA'
          )
     group by A
     )
     group by "City"
     having sum(MTAMIN)>0
union
select distinct "City", round(1-(sum(CMDOWN)/SUM(CMMIN)),4) "CM",
0 "BDP"
from 
     (
     select distinct A "City", sum(B) "CM", sum(C) "MTA", sum(B)*1440*31 "CMMIN",
     sum(C)*1440*31 "MTAMIN",0 "CMDOWN",0 "MTADOWN"
     from (
          select b.cmts_name "A", count(*) "B", 0 "C"
          from cust a, cmts_name b
          where a.cmts=b.cmts
          and a.data=1
          group by b.cmts_name
     union
          select b.cmts_name "A", 0 "B", count(*) "C"
          from cust a, cmts_name b
          where a.cmts=b.cmts
          and a.bdp=1
          group by b.cmts_name
          )
     group by A
union
     select distinct A "City", 0 "CM", 0 "MTA",0 "CMMIN",
     0 "MTAMIN",sum(B)*sum(C) "CMDOWN", sum(B)*sum(D) "MTADOWN"
     from (
          select z.cmts_name "A",
          b.current_total_docsis-b.current_online_docsis "C",
          b.current_total_mtas-b.current_online_mtas "D",
          round((a.techdispatchrepair-a.create_date)/60,0) "B"
          from aradmin.bz_incident a, aradmin.bz_auspice_interface b, cmts_name z
          where NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') >= '09/18/2006 06:00:00'
          and NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') <= '10/17/2006 05:59:59'
          and a.cmts is not null
          and a.cmts=z.cmts
          and (a.firstattempt is not null or a.techdispatchrepair is not null)
          and a.source IN ('Auspice','NMS')
          and substr(a.incident_id,4)=substr(b.related_ticket_id,4)
          and a.resolution_code != 'FA'
          )
     group by A
     )
     group by "City"
)
group by "City","CM"
union    
select distinct "City",0 "TOTCM", 0 "TOTBDP", "CM" "PLANTCM", max("BDP") "PLANTBDP", 0 "ASCM", 0 "ASBDP"
from 
(
select distinct "City", round(1-(sum(CMDOWN)/SUM(CMMIN)),4) "CM",
round(1-(sum(MTADOWN)/SUM(MTAMIN)),4) "BDP"
from 
     (
     select distinct A "City", sum(B) "CM", sum(C) "MTA", sum(B)*1440*31 "CMMIN",
     sum(C)*1440*31 "MTAMIN",0 "CMDOWN",0 "MTADOWN"
     from (
          select b.cmts_name "A", count(*) "B", 0 "C"
          from cust a, cmts_name b
          where a.cmts=b.cmts
          and a.data=1
          group by b.cmts_name
     union
          select b.cmts_name "A", 0 "B", count(*) "C"
          from cust a, cmts_name b
          where a.cmts=b.cmts
          and a.bdp=1
          group by b.cmts_name
          )
     group by A
union
     select distinct A "City", 0 "CM", 0 "MTA",0 "CMMIN",
     0 "MTAMIN",sum(B)*sum(C) "CMDOWN", sum(B)*sum(D) "MTADOWN"
     from (
          select z.cmts_name "A",
          b.current_total_docsis-b.current_online_docsis "C",
          b.current_total_mtas-b.current_online_mtas "D",
          round((a.techdispatchrepair-a.create_date)/60,0) "B"
          from aradmin.bz_incident a, aradmin.bz_auspice_interface b, cmts_name z
          where NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') >= '09/18/2006 06:00:00'
          and NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') <= '10/17/2006 05:59:59'
          and a.cmts is not null
          and a.cmts=z.cmts
          and (a.firstattempt is not null or a.techdispatchrepair is not null)
          and a.source = ('Auspice')
          and a.category ='HFC'
          and substr(a.incident_id,4)=substr(b.related_ticket_id,4)
          and a.resolution_code != 'FA'
          )
     group by A
     )
     group by "City"
     having sum(MTAMIN)>0
union
select distinct "City", round(1-(sum(CMDOWN)/SUM(CMMIN)),4) "CM",
0 "BDP"
from 
     (
     select distinct A "City", sum(B) "CM", sum(C) "MTA", sum(B)*1440*31 "CMMIN",
     sum(C)*1440*31 "MTAMIN",0 "CMDOWN",0 "MTADOWN"
     from (
          select b.cmts_name "A", count(*) "B", 0 "C"
          from cust a, cmts_name b
          where a.cmts=b.cmts
          and a.data=1
          group by b.cmts_name
     union
          select b.cmts_name "A", 0 "B", count(*) "C"
          from cust a, cmts_name b
          where a.cmts=b.cmts
          and a.bdp=1
          group by b.cmts_name
          )
     group by A
union
     select distinct A "City", 0 "CM", 0 "MTA",0 "CMMIN",
     0 "MTAMIN",sum(B)*sum(C) "CMDOWN", sum(B)*sum(D) "MTADOWN"
     from (
          select z.cmts_name "A",
          b.current_total_docsis-b.current_online_docsis "C",
          b.current_total_mtas-b.current_online_mtas "D",
          round((a.techdispatchrepair-a.create_date)/60,0) "B"
          from aradmin.bz_incident a, aradmin.bz_auspice_interface b, cmts_name z
          where NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') >= '09/18/2006 06:00:00'
          and NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') <= '10/17/2006 05:59:59'
          and a.cmts is not null
          and a.cmts=z.cmts
          and (a.firstattempt is not null or a.techdispatchrepair is not null)
          and a.source ='Auspice'
          and a.category = 'HFC'
          and substr(a.incident_id,4)=substr(b.related_ticket_id,4)
          and a.resolution_code != 'FA'
          )
     group by A
     )
     group by "City"
)
group by "City","CM"
union
select distinct "City",0 "TOTCM", 0 "TOTBDP", 0 "PLANTCM", 0 "PLANTBDP", "CM" "ASCM", MAX("BDP") "ASBDP"
from 
(
select distinct "City", round(1-(sum(CMDOWN)/SUM(CMMIN)),4) "CM",
round(1-(sum(MTADOWN)/SUM(MTAMIN)),4) "BDP"
from 
     (
     select distinct A "City", sum(B) "CM", sum(C) "MTA", sum(B)*1440*31 "CMMIN",
     sum(C)*1440*31 "MTAMIN",0 "CMDOWN",0 "MTADOWN"
     from (
          select b.cmts_name "A", count(*) "B", 0 "C"
          from cust a, cmts_name b
          where a.cmts=b.cmts
          and a.data=1
          group by b.cmts_name
     union
          select b.cmts_name "A", 0 "B", count(*) "C"
          from cust a, cmts_name b
          where a.cmts=b.cmts
          and a.bdp=1
          group by b.cmts_name
          )
     group by A
union
     select distinct A "City", 0 "CM", 0 "MTA",0 "CMMIN",
     0 "MTAMIN",sum(B)*sum(C) "CMDOWN", sum(B)*sum(D) "MTADOWN"
     from (
          select z.cmts_name "A",
          b.current_total_docsis-b.current_online_docsis "C",
          b.current_total_mtas-b.current_online_mtas "D",
          round((a.techdispatchrepair-a.create_date)/60,0) "B"
          from aradmin.bz_incident a, aradmin.bz_auspice_interface b, cmts_name z
          where NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') >= '09/18/2006 06:00:00'
          and NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') <= '10/17/2006 05:59:59'
          and a.cmts is not null
          and a.cmts=z.cmts
          and (a.firstattempt is not null or a.techdispatchrepair is not null)
          and a.source = 'NMS'
          and a.category != 'HFC'
          and substr(a.incident_id,4)=substr(b.related_ticket_id,4)
          and a.resolution_code != 'FA'
          )
     group by A
     )
     group by "City"
     having sum(MTAMIN)>0
union
select distinct "City", round(1-(sum(CMDOWN)/SUM(CMMIN)),4) "CM",
0 "BDP"
from 
     (
     select distinct A "City", sum(B) "CM", sum(C) "MTA", sum(B)*1440*31 "CMMIN",
     sum(C)*1440*31 "MTAMIN",0 "CMDOWN",0 "MTADOWN"
     from (
          select b.cmts_name "A", count(*) "B", 0 "C"
          from cust a, cmts_name b
          where a.cmts=b.cmts
          and a.data=1
          group by b.cmts_name
     union
          select b.cmts_name "A", 0 "B", count(*) "C"
          from cust a, cmts_name b
          where a.cmts=b.cmts
          and a.bdp=1
          group by b.cmts_name
          )
     group by A
union
     select distinct A "City", 0 "CM", 0 "MTA",0 "CMMIN",
     0 "MTAMIN",sum(B)*sum(C) "CMDOWN", sum(B)*sum(D) "MTADOWN"
     from (
          select z.cmts_name "A",
          b.current_total_docsis-b.current_online_docsis "C",
          b.current_total_mtas-b.current_online_mtas "D",
          round((a.techdispatchrepair-a.create_date)/60,0) "B"
          from aradmin.bz_incident a, aradmin.bz_auspice_interface b, cmts_name z
          where NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') >= '09/18/2006 06:00:00'
          and NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') <= '10/17/2006 05:59:59'
          and a.cmts is not null
          and a.cmts=z.cmts
          and (a.firstattempt is not null or a.techdispatchrepair is not null)
          and a.source = 'NMS'
          and a.category != 'HFC'
          and substr(a.incident_id,4)=substr(b.related_ticket_id,4)
          and a.resolution_code != 'FA'
          )
     group by A
     )
     group by "City"
)
group by "City","CM"
) 
group by "City"
--order by "City"
});
$sth->execute;
$sth->bind_columns({}, \($system,$tothsi,$totbdp,$plhsi,$plbdp,$ashsi,$asbdp));

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
$worksheet = $workbook->add_worksheet("Availability");
$worksheet->set_column('A:A',15.57);
$worksheet->set_column('B:B',15.57);
$worksheet->set_column('C:C',8.43);
$worksheet->set_column('D:D',8.43);
$worksheet->set_column('E:E',8.43);
$worksheet->set_column('F:F',8.43);
$worksheet->set_column('G:G',8.43);
$worksheet->set_column('H:H',8.43);
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

$worksheet->write($row, $col1, 'System', $format);
$worksheet->write($row, $col2, 'Total HSI availability', $format);
$worksheet->write($row, $col3, 'Total BDP availability', $format);
$worksheet->write($row, $col4, 'Plant HSI availability', $format);
$worksheet->write($row, $col5, 'Plant BDP availability', $format);
$worksheet->write($row, $col6, 'Adv Svc HSI availability', $format);
$worksheet->write($row, $col7, 'Adv Svc BDP availability', $format);

while ($sth->fetch)
        {
        $row++;
        $worksheet->write($row, $col1, $system, $format);
        $worksheet->write($row, $col2, $tothsi, $format2);
        $worksheet->write($row, $col3, $totbdp, $format2);
        $worksheet->write($row, $col4, $plhsi, $format2);
        $worksheet->write($row, $col5, $plbdp, $format2);
        $worksheet->write($row, $col6, $ashsi, $format2);
        $worksheet->write($row, $col7, $asbdp, $format2);
        }
$sth->finish;

##############################END Raw Availability#############################
##############################END Raw Availability#############################
##############################END Raw Availability#############################


##############################Summary#############################
##############################Summary#############################
##############################Summary#############################
my($system,$countcm,$countmta,$cmmin,$mtamin,$cmdown,$mtadown,$sth1,
$plcmdown,$plbdpdown,$ascmdown,$asbdpdown,$junk);

##This query provides the System, Count of CM's, Count of CM Minutes, 
##Count of MTA's, Count of MTA Minutes

$sth=$dbh->prepare(q{

select distinct "City", sum("TOTCM"), sum("TOTBDP"), sum("TOTCMMIN"), sum("TOTBDPMIN"), 
sum("TOTCMDOWN"), sum("TOTBDPDOWN"), sum("PLCMDOWN"),sum("PLBDPDOWN"),sum("ASCMDOWN"),sum("ASBDPDOWN")
from
(

select distinct "City", sum(CM) "TOTCM", sum(MTA) "TOTBDP", SUM(CMMIN) "TOTCMMIN", SUM(MTAMIN) "TOTBDPMIN", 
SUM(CMDOWN) "TOTCMDOWN", SUM(MTADOWN) "TOTBDPDOWN", 0 "PLCMDOWN", 0 "PLBDPDOWN", 0 "ASCMDOWN", 0 "ASBDPDOWN"
from (
     select distinct A "City", sum(B) "CM", sum(C) "MTA", sum(B)*1440*31 "CMMIN",
     sum(C)*1440*31 "MTAMIN",0 "CMDOWN",0 "MTADOWN"
     from (
          select b.cmts_name "A", count(*) "B", 0 "C"
          from cust a, cmts_name b
          where a.cmts=b.cmts
          and a.data=1
          group by b.cmts_name
     union
          select b.cmts_name "A", 0 "B", count(*) "C"
          from cust a, cmts_name b
          where a.cmts=b.cmts
          and a.bdp=1
          group by b.cmts_name
          )
     group by A

union

     select distinct A "City", 0 "CM", 0 "MTA",0 "CMMIN", 0 "MTAMIN",sum(B)*sum(C) "CMDOWN", sum(B)*sum(D) "MTADOWN"
     from (
          select z.cmts_name "A",
          b.current_total_docsis-b.current_online_docsis "C",
          b.current_total_mtas-b.current_online_mtas "D",
          round((a.techdispatchrepair-a.create_date)/60,0) "B"
          from aradmin.bz_incident a, aradmin.bz_auspice_interface b, cmts_name z
          where NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') >= '09/18/2006 06:00:00'
          and NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') <= '10/17/2006 05:59:59'
          and a.cmts is not null
          and a.cmts=z.cmts
          and a.firstattempt is not null
          and a.source IN ('Auspice','NMS')
          and substr(a.incident_id,4)=substr(b.related_ticket_id,4)
          and a.resolution_code != 'FA'
          )
     group by A
     )
group by "City"

union
-------------plant

select distinct "City", 0 "TOTCM",0 "TOTBDP",0 "TOTCMMIN",0 "TOTBDPMIN",0 "TOTCMDOWN",0 "TOTBDPDOWN",
SUM(CMDOWN) "PLCMDOWN", SUM(MTADOWN) "PLBDPDOWN",0 "ASCMDOWN",0 "ASBDPDOWN"
from (
     select distinct A "City", sum(B) "CM", sum(C) "MTA", sum(B)*1440*31 "CMMIN",
     sum(C)*1440*31 "MTAMIN",0 "CMDOWN",0 "MTADOWN"
     from (
          select b.cmts_name "A", count(*) "B", 0 "C"
          from cust a, cmts_name b
          where a.cmts=b.cmts
          and a.data=1
          group by b.cmts_name
     union
          select b.cmts_name "A", 0 "B", count(*) "C"
          from cust a, cmts_name b
          where a.cmts=b.cmts
          and a.bdp=1
          group by b.cmts_name
          )
     group by A

union

     select distinct A "City", 0 "CM", 0 "MTA",0 "CMMIN", 0 "MTAMIN",sum(B)*sum(C) "CMDOWN", sum(B)*sum(D) "MTADOWN"
     from (
          select z.cmts_name "A",
          b.current_total_docsis-b.current_online_docsis "C",
          b.current_total_mtas-b.current_online_mtas "D",
          round((a.techdispatchrepair-a.create_date)/60,0) "B"
          from aradmin.bz_incident a, aradmin.bz_auspice_interface b, cmts_name z
          where NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') >= '09/18/2006 06:00:00'
          and NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') <= '10/17/2006 05:59:59'
          and a.cmts is not null
          and a.cmts=z.cmts
          and a.firstattempt is not null
          and a.source = 'Auspice'
          and substr(a.incident_id,4)=substr(b.related_ticket_id,4)
          and a.resolution_code != 'FA'
          )
     group by A
     )
group by "City"

union
-------------advserv

select distinct "City", 0 "TOTCM",0 "TOTBDP",0 "TOTCMMIN",0 "TOTBDPMIN",0 "TOTCMDOWN",0 "TOTBDPDOWN",
0 "PLCMDOWN",0 "PLBDPDOWN", SUM(CMDOWN) "ASCMDOWN", SUM(MTADOWN) "ASBDPDOWN"
from (
     select distinct A "City", sum(B) "CM", sum(C) "MTA", sum(B)*1440*31 "CMMIN",
     sum(C)*1440*31 "MTAMIN",0 "CMDOWN",0 "MTADOWN"
     from (
          select b.cmts_name "A", count(*) "B", 0 "C"
          from cust a, cmts_name b
          where a.cmts=b.cmts
          and a.data=1
          group by b.cmts_name
     union
          select b.cmts_name "A", 0 "B", count(*) "C"
          from cust a, cmts_name b
          where a.cmts=b.cmts
          and a.bdp=1
          group by b.cmts_name
          )
     group by A

union

     select distinct A "City", 0 "CM", 0 "MTA",0 "CMMIN", 0 "MTAMIN",sum(B)*sum(C) "CMDOWN", sum(B)*sum(D) "MTADOWN"
     from (
          select z.cmts_name "A",
          b.current_total_docsis-b.current_online_docsis "C",
          b.current_total_mtas-b.current_online_mtas "D",
          round((a.techdispatchrepair-a.create_date)/60,0) "B"
          from aradmin.bz_incident a, aradmin.bz_auspice_interface b, cmts_name z
          where NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') >= '09/18/2006 06:00:00'
          and NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') <= '10/17/2006 05:59:59'
          and a.cmts is not null
          and a.cmts=z.cmts
          and a.firstattempt is not null
          and a.source = 'NMS'
          and a.category != 'HFC'
          and substr(a.incident_id,4)=substr(b.related_ticket_id,4)
          and a.resolution_code != 'FA'
          )
     group by A
     )
group by "City"
)
group by "City"
});
$sth->execute;
$sth->bind_columns({}, \($system,$countcm,$countmta,$cmmin,$mtamin,$cmdown,$mtadown,$plcmdown,$plbdpdown,$ascmdown,$asbdpdown));

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
$worksheet = $workbook->add_worksheet("Summary");
$worksheet->set_column('A:A',15.57);
$worksheet->set_column('B:B',8.43);
$worksheet->set_column('C:C',8.43);
$worksheet->set_column('D:D',11);
$worksheet->set_column('E:E',12.14);
$worksheet->set_column('F:F',2.43);
$worksheet->set_column('G:G',9.57);
$worksheet->set_column('H:H',8.43);
$worksheet->set_column('I:I',2.43);
$worksheet->set_column('J:J',9.57);
$worksheet->set_column('K:K',8.43);
$worksheet->set_column('L:L',2.43);
$worksheet->set_column('M:M',9.57);
$worksheet->set_column('N:N',8.43);
$worksheet->set_column('O:O',2.43);
$worksheet->set_row(0,33.75);

#Format Header
#Add any special formatting that you want
my $format = $workbook->add_format();
$format->set_align('center');
$format->set_bold();
$format->set_text_wrap();
#$format->set_bg_color('yellow');
$format->set_size(8);
$format->set_border();
$format->set_font('Arial');

my $format2 = $workbook->add_format();
$format2->set_align('center');
$format2->set_bold();
$format2->set_text_wrap();
#$format2->set_bg_color('yellow');
$format2->set_rotation('90');
$format2->set_size(8);
$format2->set_border();
$format2->set_font('Arial');

my $format3 = $workbook->add_format();
$format3->set_align('center');
$format3->set_text_wrap();
$format3->set_bg_color('orange');
$format3->set_size(8);
$format3->set_border();
$format3->set_font('Arial');

my $format4 = $workbook->add_format();
$format4->set_align('center');
$format4->set_text_wrap();
$format4->set_size(8);
$format4->set_border();
$format4->set_font('Arial');


#Secondary format
$fmt2=$workbook->add_format();
$fmt2->set_text_wrap();
#Name the Columns
$worksheet->write($row, $col1, 'System',$format);
$worksheet->write($row, $col2, 'Total CM',$format);
$worksheet->write($row, $col3, 'Total BDP',$format);
$worksheet->write($row, $col4, 'total possible cm minutes',$format);
$worksheet->write($row, $col5, 'total possible bdp minutes',$format);
$worksheet->write($row, $col6, ' ',$format3);
$worksheet->write($row, $col7, 'total cm affected minutes', ,$format);
$worksheet->write($row, $col8, 'total mta affected minutes', ,$format);
$worksheet->write($row, $col9, ' ',$format3);
$worksheet->write($row, $col10, 'plant cm affected minutes', ,$format);
$worksheet->write($row, $col11, 'plant mta affected minutes', ,$format);
$worksheet->write($row, $col12, ' ',$format3);
$worksheet->write($row, $col13, 'Adv Svc affected minutes', ,$format);
$worksheet->write($row, $col14, 'Adv Svc affected minutes', ,$format);
$worksheet->write($row, $col15, ' ',$format3);

#$sth->bind_columns({}, \($system,$countcm,$countmta,$cmmin,$mtamin,$cmdown,$mtadown));

while ($sth->fetch)
        {
        $row++;
        $worksheet->write($row, $col1, $system,$format4);
        $worksheet->write($row, $col2, $countcm,$format4);
        $worksheet->write($row, $col3, $countmta,$format4);
        $worksheet->write($row, $col4, $cmmin,$format4);
        $worksheet->write($row, $col5, $mtamin,$format4);
        $worksheet->write($row, $col6, $junk,$format3);
        $worksheet->write($row, $col7, $cmdown,$format4);
        $worksheet->write($row, $col8, $mtadown,$format4);
        $worksheet->write($row, $col9, $junk,$format3);
        $worksheet->write($row, $col10, $plcmdown,$format4);
        $worksheet->write($row, $col11, $plbdpdown,$format4);
        $worksheet->write($row, $col12, $junk,$format3);
        $worksheet->write($row, $col13, $ascmdown,$format4);
        $worksheet->write($row, $col14, $asbdpdown,$format4);
        $worksheet->write($row, $col15, $junk,$format3);
        }
$sth->finish;
##############################END Summary#############################
##############################END Summary#############################
##############################END Summary#############################


##############################Plant Outages#############################
##############################Plant Outages#############################
##############################Plant Outages#############################
my($repair,$market,$source,$impdesc,$stdate,$sttime,$fatt,$technot,$elapsed,$durnot,$durst,$cm,$mta,$video,$res,$inc);

$sth=$dbh->prepare(q{select nvl(a.city,substr(a.description,0,10)) "Market", a.source "Reported by",
a.description "Impact Description", trunc(to_date('01/01/1970')+a.create_date/86400) "Start Date",
to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+a.create_date/86400,'GMT','MST'),'hh24:mi:ss') "Time Created",
to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+a.firstattempt/86400,'GMT','MST'),'hh24:mi:ss') "First Attempt",
to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+a.techdispatchcontact/86400,'GMT','MST'),'hh24:mi:ss') "Tech Notified",
to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+a.techdispatchrepair/86400,'GMT','MST'),'hh24:mi:ss') "Repaired",
(a.techdispatchrepair-a.techdispatchcontact)/60 "Duration from Notification",
round((a.techdispatchrepair-a.create_date)/60,0) "Duration from Start Time",
(a.techdispatchcontact-a.firstattempt)/60 "Time Elapsed",
b.current_total_docsis-b.current_online_docsis "CM",
b.current_total_mtas-b.current_online_mtas "MTA",
round((b.current_total_docsis-b.current_online_docsis)+(b.current_total_mtas-b.current_online_mtas)*2.738,0) "Video",
a.resolution_description, a.incident_id
from aradmin.bz_incident a, aradmin.bz_auspice_interface b
where NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') >= '09/18/2006 06:00:00'
and NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') <= '10/17/2006 05:59:59'
and a.firstattempt is not null
and a.source='Auspice'
and substr(a.incident_id,4)=substr(b.related_ticket_id,4)
and a.resolution_code != 'FA'
});

$sth->execute;
$sth->bind_columns({}, \($market,$source,$impdesc,$stdate,
$sttime,$fatt,$technot,$repair,
$durnot,$durst,$elapsed,$cm,
$mta,$video,$res,$inc));


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
        $worksheet->write($row, $col10, $junk,$format3);
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

##############################END Plant Outages#############################
##############################END Plant Outages#############################
##############################END Plant Outages#############################

my($repair,$market,$source,$impdesc,$stdate,$sttime,$fatt,$technot,$elapsed,$durnot,$durst,$cm,$mta,$video,$res,$inc);

$sth=$dbh->prepare(q{select nvl(a.city,substr(a.description,0,10)) "Market", a.source "Reported by",
a.description "Impact Description", trunc(to_date('01/01/1970')+a.create_date/86400) "Start Date",
to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+a.create_date/86400,'GMT','MST'),'hh24:mi:ss') "Time Created",
to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+a.firstattempt/86400,'GMT','MST'),'hh24:mi:ss') "First Attempt",
to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+a.techdispatchcontact/86400,'GMT','MST'),'hh24:mi:ss') "Tech Notified",
to_char(NEW_TIME(to_date('01/01/1970 00:00:00')+a.techdispatchrepair/86400,'GMT','MST'),'hh24:mi:ss') "Repaired",
(a.techdispatchrepair-a.techdispatchcontact)/60 "Duration from Notification",
round((a.techdispatchrepair-a.create_date)/60,0) "Duration from Start Time",
(a.techdispatchcontact-a.firstattempt)/60 "Time Elapsed",
b.current_total_docsis-b.current_online_docsis "CM",
b.current_total_mtas-b.current_online_mtas "MTA",
round((b.current_total_docsis-b.current_online_docsis)+(b.current_total_mtas-b.current_online_mtas)*2.738,0) "Video",
a.resolution_description, a.incident_id
from aradmin.bz_incident a, aradmin.bz_auspice_interface b
where NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') >= '09/18/2006 06:00:00'
and NEW_TIME(to_date('01/01/1970 00:00:00')+a.resolution_date/86400,'GMT','MST') <= '10/17/2006 05:59:59'
and a.firstattempt is not null
and a.source='NMS'
and substr(a.outage_id,4)=substr(b.related_ticket_id,4)
and a.resolution_code != 'FA'
});

$sth->execute;
$sth->bind_columns({}, \($market,$source,$impdesc,$stdate,
$sttime,$fatt,$technot,$repair,
$durnot,$durst,$elapsed,$cm,
$mta,$video,$res,$inc));


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
$worksheet = $workbook->add_worksheet("Adv Svc Outages");
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
        $worksheet->write($row, $col10, $junk,$format3);
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
