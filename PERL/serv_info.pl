#!/usr/bin/perl

#This is a subroutine script. It is the liaison between
#database scripts and the usr/passwd file.
#
#

sub serv_info

{
my($input)=@_;

my($list, $test, $usr, $passwd, $host, $sid);

open (LIST, "/home/jsoria/SCRIPTS/LOG/.serv_info.txt");

while($list = <LIST>) {

chomp($list);

($test, $usr, $passwd, $host, $sid) = split(/\,/, $list);

if ($input eq $test) {
@return_list=($usr, $passwd, $host, $sid);
last;
}
}
close(LIST);
return(@return_list);
}
1;



