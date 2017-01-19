#!/usr/bin/perl

use warnings;
use strict;

while (<STDIN>) {
  s/_~_.*_~_/$ARGV[0]/;
  print;
}
