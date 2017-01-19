#!/usr/bin/perl

push(@INC,"/home/jsoria/SCRIPTS/DATA");

use warnings;
use strict;
use Data::Dumper;

my %props;
my $cmd_template;

open PROPS,"<.properties";
while (<PROPS>) {
  s/#.*$//;
  chomp;
  my ($name,$val) = split;
  if (defined $val) {
    $props{$name} = $val;
  }
}
close PROPS;

open MAP,"<vsm_map-mclauson.csv";
while (<MAP>) {
  s/#.*$//;
  chomp;
  my ($host,$file,$instance) = split /,/;
  if (defined $host && defined $file && defined $instance) {
    $cmd_template = 'cat update.sql | ./replace.pl _~_FILE_~_  | mysql -h_~_HOST_~_ -u_~_USER_~_ -p_~_PASS_~_ _~_INSTANCE_~_';
    $cmd_template =~ s/_~_HOST_~_/$host/;
    $cmd_template =~ s/_~_FILE_~_/$file/;
    $cmd_template =~ s/_~_INSTANCE_~_/$instance/;
    $cmd_template =~ s/_~_PASS_~_/$props{"vsm.dbpassword"}/;
    $cmd_template =~ s/_~_USER_~_/$props{"vsm.dbuser"}/;
    my @args = ($cmd_template);
    system(@args) == 0 or warn "Could not run: $cmd_template\n";
  }
}
