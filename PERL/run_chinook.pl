#!/usr/bin/perl

# Author: Joe Soria
# DATE: May 15, 2007
#
# This script builds the creates the necessary table structures used
# to produce the Chinook long distance bill. This script also loads
# the data and generates the bill.
#
##HTTPS://LOGIC.QWEST.COM
##Master
##Account Number: 72419843
##Passcode: 130512
##

push(@INC, "/home/jsoria/SCRIPTS/PERL");
push(@INC,"/home/jsoria/SCRIPTS/DATA");
require 'serv_info.pl';

use DBI;
use strict;
use Getopt::Long;
#use warnings;
use Data::Dumper;

$ENV{'ORACLE_SID'}="remrep";
$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

my($sth,$test,$usr,$passwd,$sid,$host,$runall,$runbill,$runmost);

GetOptions("0" => \$runall,
	   "1" => \$runbill,
	   "2" => \$runmost);

$test='2';
$usr="";
$passwd="";

our ($mo,$qmo,$cmo,$cbmo,$seq,$trig);

$mo=$ARGV[0];
chomp($mo);
$qmo="qwest_$mo";
$cmo="chinook_$mo";
$cbmo="chinook_bill_$mo";
$seq="chi_seq_$mo";
$trig="chi_seq_trig_$mo";

($usr,$passwd,$sid)=&serv_info($test);

open(LOG,">/home/jsoria/SCRIPTS/PERL/run_chinook.log");
open(LOG2,">/home/jsoria/SCRIPTS/PERL/chinook_bill_$mo\.csv");
open(LOG3,">/home/jsoria/SCRIPTS/PERL/bill_summary_$mo\.log");

our ($dbh);
$dbh = DBI->connect('dbi:Oracle:remrep',$usr,$passwd) || 
die "Cannot establish connection to the database";

$dbh->{RaiseError}=1;

if ($runall) 
{
&create_qwest_table;
&load_qwest_data;
&chinook_sequence;
&chinook_table_insert;
&calculate_directory_assistance;
&calculate_international;
&calculate_intrastate;
&calculate_interstate;
&add_summary;
&alter_cbmo;
&build_index1;
&build_index2;
&grant_perms
}

if ($runbill) 
{
&add_summary;
}

if ($runmost) 
{
&chinook_sequence;
&chinook_table_insert;
&calculate_directory_assistance;
&calculate_international;
&calculate_intrastate;
&calculate_interstate;
&add_summary;
&alter_cbmo;
&build_index1;
&build_index2;
&grant_perms
}


sub create_qwest_table
{
	print STDOUT "Creating Qwest Table\n";
	$sth=$dbh->prepare("create table $qmo as select * from qwest_july_2009 where rownum < 1");
	$sth->execute();
}

sub load_qwest_data
{
system("/home/oracle/OraHome1/bin/sqlldr $usr\/$passwd\@remrep silent=feedback control=/home/jsoria/SCRIPTS/PERL/chinook.ctl errors=50000");
}

sub chinook_sequence
{

	$sth=$dbh->do("create table $cmo as select * from chinook_july_2009 where rownum < 1");

	$sth=$dbh->prepare("create sequence $seq start with 1000 increment by 1");
	$sth->execute();


	$sth=$dbh->prepare("create or replace trigger $trig
	before insert on $cmo
	for each row
	begin
	if :old.chinook_id is null
	then select $seq.nextval into :new.chinook_id from dual;
	end if\;
	end\;");
	$sth->execute();

}




sub chinook_table_insert
{
	#print STDOUT "Grabbing what we need from the Qwest Data\n";
	#$sth=$dbh->prepare("insert into $cmo
		#select *
		#from $qmo
		#where substr(dialedno, 1, 3) not in ('800', '866', '877')
   		#and (authorization_code_full like '%2137' or
        	#authorization_code_full like '%2214' or
        	#authorization_code_full like '%418')
       		#and (orig_ocn not like '008E%' or orig_ocn is null)");

	$sth=$dbh->prepare("insert into $cmo
		select * 
		from $qmo
		where ani='4068303002'
		and (dialedno not like '800%'
		or dialedno not like '866%'
		or dialedno not like '877%')
		or
		authorization_code_full=2214
		and (dialedno not like '800%'
		or dialedno not like '866%'
		or dialedno not like '877%')
		");
	$sth->execute();

}


sub calculate_directory_assistance
{

	print STDOUT "Calculating Directory Assistance Calls\n";
	$sth=$dbh->prepare("create table $cbmo as 
		select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  \"DATE\",
		substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  \"TIME\",
		substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  \"CALLED NUMBER\",
		city_called ||', '|| state_called \"LOCATION\", substr(call_duration_minutes,3,3) ||':'|| 
		call_duration_seconds \"MINSECS\",
		to_number(.75) \"CHARGE\", 1 \"BILL_FLAG\"
		from $cmo a
		where call_area=4");
	$sth->execute();

}

sub calculate_international
{

	print STDOUT "Calculating International Calls\n";
	$sth=$dbh->prepare("insert into $cbmo
		select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| 
		substr(orig_dt,1,4)  \"DATE\",
		substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  \"TIME\",
		substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  \"CALLED NUMBER\",
		city_called ||', '|| state_called \"LOCATION\", substr(call_duration_minutes,3,3) ||':'|| 
		call_duration_seconds \"MINSECS\",
		round(to_number(1.35) * to_number(substr(unrounded_price,1,4)||'.'||
		substr(unrounded_price,5,6)),2) \"CHARGE\", 2 \"BILL_FLAG\"
		from $cmo
		where call_area=3
		or state_called = 'IT'
		or prcmp_id=1");
	$sth->execute();

}

sub calculate_intrastate
{

        print STDOUT "Calculating Intrastate Calls\n";
        $sth=$dbh->prepare("insert into $cbmo
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  \"DATE\",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  \"TIME\",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  \"CALLED NUMBER\",
city_called ||', '|| state_called \"LOCATION\", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds \"MINSECS\",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class1),2) \"CHARGE\", 3 
\"BILL_FLAG\"
from $cmo a, intrastate_billing_rates b
where class_type=1
and state_called='MT'
and call_area=1 
or
(call_area=2 and state_called='MT' and class_type=1)
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class1
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  \"DATE\",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  \"TIME\",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  \"CALLED NUMBER\",
city_called ||', '|| state_called \"LOCATION\", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds \"MINSECS\",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class2),2) \"CHARGE\", 3 
\"BILL_FLAG\"
from $cmo a, intrastate_billing_rates b
where class_type=2
and state_called='MT'
and call_area=1
or
(call_area=2 and state_called='MT' and class_type=2)
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class2
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  \"DATE\",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  \"TIME\",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  \"CALLED NUMBER\",
city_called ||', '|| state_called \"LOCATION\", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds \"MINSECS\",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class3),2) \"CHARGE\", 3 
\"BILL_FLAG\"
from $cmo a, intrastate_billing_rates b
where class_type=3
and state_called='MT'
and call_area=1
or
(call_area=2 and state_called='MT' and class_type=3)
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds,b.class3
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  \"DATE\",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  \"TIME\",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  \"CALLED NUMBER\",
city_called ||', '|| state_called \"LOCATION\", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds \"MINSECS\",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class4),2) \"CHARGE\", 3 
\"BILL_FLAG\"
from $cmo a, intrastate_billing_rates b
where class_type=4
and state_called='MT'
and call_area=1
or
(call_area=2 and state_called='MT' and class_type=4)
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class4
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  \"DATE\",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  \"TIME\",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  \"CALLED NUMBER\",
city_called ||', '|| state_called \"LOCATION\", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds \"MINSECS\",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class5),2) \"CHARGE\", 3 
\"BILL_FLAG\"
from $cmo a, intrastate_billing_rates b
where class_type=5
and state_called='MT'
and call_area=1
or
(call_area=2 and state_called='MT' and class_type=5)
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class5
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  \"DATE\",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  \"TIME\",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  \"CALLED NUMBER\",
city_called ||', '|| state_called \"LOCATION\", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds \"MINSECS\",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class6),2) \"CHARGE\", 3 
\"BILL_FLAG\"
from $cmo a, intrastate_billing_rates b
where class_type=6
and state_called='MT'
and call_area=1
or
(call_area=2 and state_called='MT' and class_type=6)
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class6
");
        $sth->execute();

}

sub calculate_interstate
{

        print STDOUT "Calculating Interstate Calls\n";
        $sth=$dbh->prepare("insert into $cbmo
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  \"DATE\",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  \"TIME\",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  \"CALLED NUMBER\",
city_called ||', '|| state_called \"LOCATION\", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds \"MINSECS\",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class1),2) \"CHARGE\", 4 
\"BILL_FLAG\"
from $cmo a, interstate_billing_rates b
where class_type=1
and call_area in (2,1)
and state_called != 'MT'
and state_called != 'IT'
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class1
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  \"DATE\",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  \"TIME\",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  \"CALLED NUMBER\",
city_called ||', '|| state_called \"LOCATION\", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds \"MINSECS\",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class2),2) \"CHARGE\", 4 
\"BILL_FLAG\"
from $cmo a, interstate_billing_rates b
where class_type=2
and call_area in (2,1)
and state_called != 'MT'
and state_called != 'IT'
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class2
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  \"DATE\",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  \"TIME\",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  \"CALLED NUMBER\",
city_called ||', '|| state_called \"LOCATION\", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds \"MINSECS\",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class3),2) \"CHARGE\", 4 
\"BILL_FLAG\"
from $cmo a, interstate_billing_rates b
where class_type=3
and call_area in (2,1)
and state_called != 'MT'
and state_called != 'IT'
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds,b.class3
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  \"DATE\",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  \"TIME\",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  \"CALLED NUMBER\",
city_called ||', '|| state_called \"LOCATION\", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds \"MINSECS\",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class4),2) \"CHARGE\", 4 
\"BILL_FLAG\"
from $cmo a, interstate_billing_rates b
where class_type=4
and call_area in (2,1)
and state_called != 'MT'
and state_called != 'IT'
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class4
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  \"DATE\",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  \"TIME\",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  \"CALLED NUMBER\",
city_called ||', '|| state_called \"LOCATION\", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds \"MINSECS\",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class5),2) \"CHARGE\", 4 
\"BILL_FLAG\"
from $cmo a, interstate_billing_rates b
where class_type=5
and call_area in (2,1)
and state_called != 'MT'
and state_called != 'IT'
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class5
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  \"DATE\",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  \"TIME\",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  \"CALLED NUMBER\",
city_called ||', '|| state_called \"LOCATION\", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds \"MINSECS\",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class6),2) \"CHARGE\", 4 
\"BILL_FLAG\"
from $cmo a, interstate_billing_rates b
where class_type=6
and call_area in (2,1)
and state_called != 'MT'
and state_called != 'IT'
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class6
");
        $sth->execute();

}



{
my ($call_service_type,$component_group_cd,$component_grp_val,$product_acct_id,$customer_number,     
$orig_dt,$discn_dt,$orig_time,$discn_time,$call_duration_minutes,$call_duration_seconds,     
$dialedno,$calledno,$ani,$anstype,$pindigs,$infodig,$surcharge,$compcode,$predig,$trtmtcd,         
$orig_trunk_group_name,$origmem,$term_trunk_group_name,$termmem,$intra_lata_ind,$call_area,     
$city_calling,$state_calling,$city_called,$state_called,$rate_period,$terminating_country_code,     
$originating_country_code,$pac_codes,$orig_pricing_npa,$orig_pricing_nxx,$term_pricing_npa,    
$term_pricing_nxx,$authorization_code_full,$univacc,$prcmp_id,$carrsel,$cic,$origlrn,$portedno,       
$lnpcheck,$originating_iddd_city_code,$terminating_iddd_city_code,$originating_lata,   
$terminating_lata,$class_type,$mexico_rate_step,$estimated_charge,$billing_ocn,$orig_term_code,     
$clgptyno,$clgptyno_identifier,$orig_ocn,$term_ocn,$unrounded_price,$rate_per_minute,$finsid,      
$final_trunk_group_name,$carriage_return,$chargea,$chinook_id,$charge,$bill_flag);

	$sth=$dbh->prepare("select a.call_service_type, a.component_group_cd, 
	a.component_grp_val, a.product_acct_id, 
	a.customer_number, a.orig_dt, a.discn_dt, a.orig_time, 
	a.discn_time, a.call_duration_minutes, 
	a.call_duration_seconds, a.dialedno, a.calledno, a.ani, 
	a.anstype, a.pindigs, a.infodig, a.surcharge, 
	a.compcode, a.predig, a.trtmtcd, a.orig_trunk_group_name, 
	a.origmem, a.term_trunk_group_name, 
	a.termmem, a.intra_lata_ind, a.call_area, a.city_calling, a.state_calling, a.city_called, 
	a.state_called, a.rate_period, a.terminating_country_code, 
	a.originating_country_code, a.pac_codes, 
	a.orig_pricing_npa, a.orig_pricing_nxx, a.term_pricing_npa, 
	a.term_pricing_nxx, a.authorization_code_full, 
	a.univacc, a.prcmp_id, a.carrsel, a.cic, a.origlrn, a.portedno, 
	a.lnpcheck, a.originating_iddd_city_code, 
	a.terminating_iddd_city_code, a.originating_lata, a.terminating_lata, 
	a.class_type, a.mexico_rate_step, 
	a.estimated_charge, a.billing_ocn, a.orig_term_code, a.clgptyno, 
	a.clgptyno_identifier, a.orig_ocn, 
	a.term_ocn, null, null, a.finsid, 
	a.final_trunk_group_name, a.carriage_return, 
	null,a.chinook_id, b.\"CHARGE\", b.\"BILL_FLAG\"
	from $cmo a, $cbmo b
	where a.chinook_id=b.chinook_id");
        $sth->execute();
	$sth->bind_columns({}, \($call_service_type,$component_group_cd,
	$component_grp_val,$product_acct_id,
        $customer_number,
        $orig_dt,$discn_dt,$orig_time,$discn_time,$call_duration_minutes,$call_duration_seconds,
        $dialedno,$calledno,$ani,$anstype,$pindigs,$infodig,$surcharge,$compcode,$predig,$trtmtcd,
        $orig_trunk_group_name,$origmem,$term_trunk_group_name,$termmem,$intra_lata_ind,$call_area,
        $city_calling,$state_calling,$city_called,$state_called,$rate_period,$terminating_country_code,
        $originating_country_code,$pac_codes,$orig_pricing_npa,$orig_pricing_nxx,$term_pricing_npa,
        $term_pricing_nxx,$authorization_code_full,$univacc,$prcmp_id,$carrsel,$cic,$origlrn,$portedno,
        $lnpcheck,$originating_iddd_city_code,$terminating_iddd_city_code,$originating_lata,
        $terminating_lata,$class_type,$mexico_rate_step,$estimated_charge,$billing_ocn,$orig_term_code,
        $clgptyno,$clgptyno_identifier,$orig_ocn,$term_ocn,$unrounded_price,$rate_per_minute,$finsid,
        $final_trunk_group_name,$carriage_return,$chargea,$chinook_id,$charge,$bill_flag));

while ($sth->fetch)
	{
	print LOG2 "$call_service_type,$component_group_cd,$component_grp_val,$product_acct_id,$customer_number,$orig_dt,$discn_dt,$orig_time,$discn_time,$call_duration_minutes,$call_duration_seconds,$dialedno,$calledno,$ani,$anstype,$pindigs,$infodig,$surcharge,$compcode,$predig,$trtmtcd,$orig_trunk_group_name,$origmem,$term_trunk_group_name,$termmem,$intra_lata_ind,$call_area,$city_calling,$state_calling,$city_called,$state_called,$rate_period,$terminating_country_code,$originating_country_code,$pac_codes,$orig_pricing_npa,$orig_pricing_nxx,$term_pricing_npa,$term_pricing_nxx,$authorization_code_full,$univacc,$prcmp_id,$carrsel,$cic,$origlrn,$portedno,$lnpcheck,$originating_iddd_city_code,$terminating_iddd_city_code,$originating_lata,$terminating_lata,$class_type,$mexico_rate_step,$estimated_charge,$billing_ocn,$orig_term_code,$clgptyno,$clgptyno_identifier,$orig_ocn,$term_ocn,$unrounded_price,$rate_per_minute,$finsid,$final_trunk_group_name,$carriage_return,$chinook_id,$charge,$bill_flag\n";
	}
}



sub add_summary
{
my($i,$j);

$sth=$dbh->prepare("select authorization_code_full, sum(estimated_charge)
		from $cmo a, $cbmo b
		where a.chinook_id=b.chinook_id
		and (authorization_code_full like '%2137'
		or authorization_code_full like '%2214'
		or authorization_code_full like '%418')
		group by authorization_code_full");
        	$sth->execute();
		$sth->bind_columns({}, \($i,$j));

while ($sth->fetch)
	{
	print LOG3 "$i,$j\n";
	}
}

sub alter_cbmo
{
$sth=$dbh->do("alter table $cbmo add rate_plan_entry_id number");
}

sub build_index1
{
$sth=$dbh->do("create index ix_$cbmo on $cbmo(chinook_id) compute statistics");
}

sub build_index2
{
$sth=$dbh->do("create index ix_$cmo on $cmo(chinook_id) compute statistics");
}

sub grant_perms
{
$sth=$dbh->do("grant select on $cbmo to public");
$sth=$dbh->do("grant select on $cmo to public");
$sth=$dbh->do("grant select on $qmo to public");
}
close(LOG);
close(LOG2);
close(LOG3);

