#!/usr/bin/perl

######################
#get_date SUB ROUTINE#
######################

sub get_date 
{
local($time) = time;

local ($sec,$min,$hour,$tday,$tmon,$tyear,$wday,$yrday,$isdst) = localtime($time);

$tyear="2012";

$tmon++;

if ($tday < 10)
{
$tday = "0$tday";
}
if ($tmon < 12)
{
$tmon = "0$tmon";
}
local ($result) = "$tmon$tday$tyear";
return ($result);
}
1;
