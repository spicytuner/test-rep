#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;
my (@array, $counter);
while (<STDIN>) {
	chomp;
	@array = split(/\s+/);
 	#print "$_\n" if ($array[1] =~ /^.{1,6}$/)  && ++$counter;
 	print "$array[0] $array[1]\n" if ($array[1] =~ /^.{0,6}$/)  && ++$counter;
}	
print "Total count = $counter\n";
