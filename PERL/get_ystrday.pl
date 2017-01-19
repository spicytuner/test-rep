#!/usr/bin/perl

######################
#get_yest SUB ROUTINE#
######################

sub get_yest 
{
local($time) = time;

local ($sec,$min,$hour,$tday,$tmon,$tyear,$wday,$yrday,$isdst) = localtime($time);

$tyear="2007";

$tmon++;

$tday = $tday-1;

if ($tday < 10)
{
$tday = "0$tday";
}

#$tday = $tday;

if ($tmon < 10)
{
$tmon = "0$tmon";
}

if (($tday < 01) && ($tmon = '5'))
{
$tday=30;
$tmon=04;
}
if (($tday < 01) && ($tmon = '05'))
{
$tday=30;
$tmon=04;
}

if (($tday < 01) && ($tmon = '06'))
{
$tday=31;
$tmon=05;
}

if (($tday < 01) && ($tmon = '07'))
{
$tday=30;
$tmon=06;
}

if (($tday < 01) && ($tmon = '08'))
{
$tday=31;
$tmon=07;
}

#local ($result) = "$tmon-$tday-$tyear";
local ($result) = "$tyear$tmon$tday";
return ($result);
}
#print STDOUT "$result\n";
1;

