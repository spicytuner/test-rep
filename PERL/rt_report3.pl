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
$worksheet,@data,$data,$sth2,$counts,$dcounts,$dname,$sth3,$subj,$fmt2);

@database=qw(samprd,remprd,remrep);
$contact='jsoria';
$domain='bresnan.com';
$test='2';
$usr="";
$passwd="";

$log='/home/jsoria/SCRIPTS/PERL/open_tickets.xls';
$log2='/home/jsoria/SCRIPTS/PERL/seopen_tickets.xls';

($usr,$passwd,$sid)=&serv_info($test);

$dbh = DBI->connect('dbi:Oracle:samprd',$usr,$passwd) || die "Cannot establish connection to the database";

$dbh->{RaiseError}=1;
#Define your queries

foreach ($database) {
$sth=$dbh->prepare(q{SELECT TABLESPACE_NAME NAME, TOTAL, FREE,
       ROUND((FREE/TOTAL)*100,1) PCT_FREE,
       FRAGMENTS, BIGGEST_FRAGMENT
FROM(SELECT TABLESPACE_NAME, SUM(BYTES) TOTAL
       FROM SYS.DBA_DATA_FILES
     GROUP BY TABLESPACE_NAME),
    (SELECT TABLESPACE_NAME TS_NAME,
     SUM(BYTES) FREE, MAX(BYTES) BIGGEST_FRAGMENT, 
     COUNT(TABLESPACE_NAME) FRAGMENTS
       FROM SYS.DBA_FREE_SPACE
     GROUP BY TABLESPACE_NAME)
WHERE TABLESPACE_NAME = TS_NAME
});
}

$sth2=$dbh->prepare(q{select submitter, incident_id, assigned_team, status, assigned_to,
category, type, item,
TO_CHAR(create_date, 'YYYY-MM-DD HH24:MI:SS') AS create_date, 
TO_CHAR(modified_date, 'YYYY-MM-DD HH24:MI:SS') AS modified_date, last_modified_by, description
from masterm.se_open_tickets@remrep
});


$workbook = Spreadsheet::WriteExcel->new($log);
$workbook2 = Spreadsheet::WriteExcel->new($log2);



##################################Network#############################
##################################Network#############################
##################################Network#############################
################DETAIL BY ENGINEER####################################

my($c,$t,$i,$creator,$ticketnumber,$qname,$status,$owner,$created,$lastupdated,$lastupdatedby,$subject);

$sth->execute;
$sth->bind_columns({}, \($creator,$ticketnumber,$qname,$status,$owner,$c,$t,$i,$created,$lastupdated,$lastupdatedby,$subject));

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

#Create the worksheet
$worksheet = $workbook->add_worksheet("OPEN TICKETS");
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
#Add any special formatting that you want
my $format = $workbook->add_format();
$format->set_align('center');
$format->set_bold();
$format->set_bg_color('yellow');
#Secondary format
$fmt2=$workbook->add_format();
$fmt2->set_text_wrap();
#Name the Columns
$worksheet->write($row, $col1, 'Creator',$format);
$worksheet->write($row, $col2, 'Ticket Number',$format);
$worksheet->write($row, $col3, 'Queue',$format);
$worksheet->write($row, $col4, 'Status',$format);
$worksheet->write($row, $col5, 'Owner',$format);
$worksheet->write($row, $col6, 'Category',$format);
$worksheet->write($row, $col7, 'Type',$format);
$worksheet->write($row, $col8, 'Item',$format);
$worksheet->write($row, $col9, 'Created',$format);
$worksheet->write($row, $col10, 'Last Updated',$format);
$worksheet->write($row, $col11, 'Last Updated By',$format);
$worksheet->write($row, $col12, 'Subject',$format);
#Write to the spreadsheet
while ($sth->fetch)
        {
        $row++;
        $worksheet->write($row, $col1, $creator);
        $worksheet->write($row, $col2, $ticketnumber);
        $worksheet->write($row, $col3, $qname);
        $worksheet->write($row, $col4, $status);
        $worksheet->write($row, $col5, $owner);
        $worksheet->write($row, $col6, $c);
        $worksheet->write($row, $col7, $t);
        $worksheet->write($row, $col8, $i);
        $worksheet->write($row, $col9, $created);
        $worksheet->write($row, $col10, $lastupdated);
        $worksheet->write($row, $col11, $lastupdatedby);
        $worksheet->write($row, $col12, $subject);
        }
$sth->finish;

##############################END Network#############################
##############################END Network#############################
##############################END Network#############################

##################################Systems#############################
##################################Systems#############################
##################################Systems#############################
################DETAIL BY ENGINEER####################################

my($c,$t,$i,$creator,$ticketnumber,$qname,$status,$owner,$created,$lastupdated,$lastupdatedby,$subject);

$sth2->execute;
$sth2->bind_columns({}, \($creator,$ticketnumber,$qname,$status,$owner,$c,$t,$i,$created,$lastupdated,$lastupdatedby,$subject));

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

#Create the worksheet
$worksheet = $workbook2->add_worksheet("OPEN TICKETS");
$worksheet->set_column('A:A',15);
$worksheet->set_column('B:B',15);
$worksheet->set_column('C:C',20);
$worksheet->set_column('D:D',10);
$worksheet->set_column('E:E',20);
$worksheet->set_column('F:F',20);
$worksheet->set_column('G:G',20);
$worksheet->set_column('H:H',20);
$worksheet->set_column('I:I',20);
$worksheet->set_column('J:J',20);
$worksheet->set_column('K:K',15);
$worksheet->set_column('L:L',200);

#Add any special formatting that you want
my $format = $workbook2->add_format();
$format->set_align('center');
$format->set_bold();
$format->set_bg_color('yellow');
#Secondary format
$fmt2=$workbook2->add_format();
$fmt2->set_text_wrap();
#Name the Columns
$worksheet->write($row, $col1, 'Creator',$format);
$worksheet->write($row, $col2, 'Ticket Number',$format);
$worksheet->write($row, $col3, 'Queue',$format);
$worksheet->write($row, $col4, 'Status',$format);
$worksheet->write($row, $col5, 'Owner',$format);
$worksheet->write($row, $col6, 'Category',$format);
$worksheet->write($row, $col7, 'Type',$format);
$worksheet->write($row, $col8, 'Item',$format);
$worksheet->write($row, $col9, 'Created',$format);
$worksheet->write($row, $col10, 'Last Updated',$format);
$worksheet->write($row, $col11, 'Last Updated By',$format);
$worksheet->write($row, $col12, 'Subject',$format);
#Write to the spreadsheet
while ($sth2->fetch)
        {
        $row++;
        $worksheet->write($row, $col1, $creator);
        $worksheet->write($row, $col2, $ticketnumber);
        $worksheet->write($row, $col3, $qname);
        $worksheet->write($row, $col4, $status);
        $worksheet->write($row, $col5, $owner);
        $worksheet->write($row, $col6, $c);
        $worksheet->write($row, $col7, $t);
        $worksheet->write($row, $col8, $i);
        $worksheet->write($row, $col9, $created);
        $worksheet->write($row, $col10, $lastupdated);
        $worksheet->write($row, $col11, $lastupdatedby);
        $worksheet->write($row, $col12, $subject);
        }
$sth2->finish;

##############################END Systems#############################
##############################END Systems#############################
##############################END Systems#############################
