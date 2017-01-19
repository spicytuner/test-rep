#!/usr/bin/perl

push(@INC, "/export/home/jsoria/SCRIPTS/PERL");
require("get_date.pl");
require("serv_info.pl");

$test='1';
$usr='';
$passwd='';

($usr,$passwd)=&serv_info($test);
$date=&get_date;
$dba=`jsoria`;
$domain=`bresnan.com`;
#@database=qw(samprd primal01 remprd remrep);
$database=$ARGV[0];

$backloc='/opt/oracle/oradata/backup';

$expfile = "$backloc\/$database\/EXPORTS\/$date\.dmp";


print "$expfile\n";
print "$usr $passwd\n";

#system("/opt/oracle/OraHome2/bin/exp $usr/$passwd\@$database file=$expfile compress=n full=y log=/opt/oracle/oradata/backup/export.log");

#system("tar -cvf /opt/oracle/oradata/backup/$date\.tar /opt/oracle/oradata/backup/export\*");
#system("compress /opt/oracle/oradata/backup/$date\.tar");

