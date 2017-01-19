#!/usr/local/bin/perl -w

# Author: Joe Soria
# Date: November 7, 2006
#
# Script which includes all reports to be called from Remedy
#This script is called from Remedy Form: BZ:ReportingRequests,
#but can also be called manually
#usage: ./rpt.pl -rpt $mailto $startdate $starttime $enddate $endtime 

use diagnostics;
use Spreadsheet::WriteExcel;
use Data::Dumper;


$file="rpt".time().".xls";

$log="/home/jsoria/SCRIPTS/PERL/REPORTS/$file";

$workbook = Spreadsheet::WriteExcel->new($log);

#############################################################
########These are optional, simple formats that I like to use
#############################################################

#Add any special formatting that you want
our $format = $workbook->add_format();
$format->set_align('center');
$format->set_bold();
$format->set_text_wrap();
$format->set_bg_color('yellow');
$format->set_size(8);
$format->set_border();
$format->set_font('Arial');

our $format2 = $workbook->add_format();
$format2->set_align('center');
$format2->set_bold();
$format2->set_text_wrap();
$format2->set_size(8);
$format2->set_border();
$format2->set_font('Arial');

our $format5 = $workbook->add_format();
$format5->set_align('center');
$format5->set_bold();
$format5->set_text_wrap();
$format5->set_bg_color('yellow');
$format5->set_rotation('90');
$format5->set_size(8);
$format5->set_border();
$format5->set_font('Arial');

our $format3 = $workbook->add_format();
$format3->set_align('center');
$format3->set_text_wrap();
$format3->set_bg_color('orange');
$format3->set_size(8);
$format3->set_border();
$format3->set_font('Arial');

our $format4 = $workbook->add_format();
$format4->set_align('center');
$format4->set_text_wrap();
$format4->set_size(8);
$format4->set_border();
$format4->set_font('Arial');

our $format9 = $workbook->add_format();
$format9->set_align('Left');
$format9->set_text_wrap();
$format9->set_bg_color('yellow');
$format9->set_size(8);
$format9->set_border();
$format9->set_font('Arial');

#Secondary format
our $fmt2=$workbook->add_format();
$fmt2->set_text_wrap();

##############################
########end customized formats
##############################



&rpt1($workbook); $title="YOUR TITLE GOES HERE";

#Define your queries
##################################INC's by Category/Type#############################
##################################INC's by Category/Type#############################
##################################INC's by Category/Type#############################

sub rpt1
{

my $workbook=shift;

$sth=$dbh->prepare("PUT YOUR QUERY HERE");
$sth->execute();
$sth->bind_columns({}, \(#BIND YOUR COLUMNS HERE));

#################################################
########ENSURE YOU HAVE ENOUGH COLUMNS DESIGNATED
########$row WILL BE WHERE THE COLUMN NAMES LIVE
#################################################

$row = $col1 = 0;
$col2 = 1;
$col3 = 2;
$col4 = 3;
$col5 = 4;



############################
########CREATE THE WORKSHEET
############################

$worksheet = $workbook->add_worksheet("TicketsbyCategory");
$worksheet->set_column('A:A',15);
$worksheet->set_column('B:B',15);
$worksheet->set_column('C:C',15);
$worksheet->set_column('D:D',15);
$worksheet->set_row(0,85.50);


########################
########NAME THE COLUMNS
########################

#########################################################
########SUBSTITUTE COLUMN NAME FOR THE ACTUAL COLUMN NAME
#########################################################

$worksheet->write($row, $col1, 'COLUMN NAME',$format);
$worksheet->write($row, $col2, 'COLUMN NAME',$format);
$worksheet->write($row, $col3, 'COLUMN NAME',$format);
$worksheet->write($row, $col4, 'COLUMN NAME',$format);

while ($sth->fetch)
        {
        $row++;
	######################################
	########$VAL SHOULD BE THE BIND COLUMN
	######################################

        $worksheet->write($row, $col1, $VAL,$format4);
        $worksheet->write($row, $col2, $VAL,$format4);
        $worksheet->write($row, $col3, $VAL,$format4);
        $worksheet->write($row, $col4, $VAL,$format4);
        }
$sth->finish;
$dbh->disconnect;
}

