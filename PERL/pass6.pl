#!/usr/bin/perl
use strict;
my($count, $file, $pass, $junk, $junk2);
open(FILE, "/home/cgpro/backup/accounts.2005-9-25_23_0_1.txt")|| die "not able to open file: $!\n";
while ($file=<FILE>)
{
#($junk,$pass,$junk2)=split(/\s+/,$file);
($junk,$pass,$junk2)=split(/\s+/,$file);
chomp($junk,$pass);
	if (length($pass) < 7)
	{
	print STDOUT "$junk $pass\n";
	++$count;
	}
}
print "$count\n";
close(FILE);
