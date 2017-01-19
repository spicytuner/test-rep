#!/usr/bin/perl

use Getopt::Long;

my($h,$d,$w,$s,$heights,$downtown,$westend,$ss,@heights,@downtown,@westend,@ss,@lines,$array,@array,$i,$j);

%lunchplaces = (
	"heights" => ["montanajacks", "tinys", "surferjoes", "mckinzieriver"],
	"downtown" => ["hooligans", "brewpub", "sweetginger","guadalajara","sweetgrass", "pugs", "mccormicks", "luckylils", "Rockets","Los Mayos","the Rex","Jakes","don luis"],
	"westend" => ["guadalajara", "toa", "redlobster", "olivegarden", "fuddruckers","samthai","golden phoenix", "applebees", "huhot", "mongolian grill", "famous daves","johnny carinos"],
	"ss" => ["hogwild",],
);

if ($lunchplaces{$ARGV[0]} && $ARGV[0] ne "all") {
	if ($ARGV[0]) {
		fisher_yates_shuffle(\@{$lunchplaces{$ARGV[0]}});
		my $value = int(rand($#{$lunchplaces{$ARGV[0]}}));
		print "@{$lunchplaces{$ARGV[0]}} ::::::::::: @{$lunchplaces{$ARGV[0]}}->[$value]\n";
	}
}
elsif ($ARGV[0] eq 'all') {
	my @array1;
	foreach (keys (%lunchplaces)) {
		push @array1,@{$lunchplaces{$_}};
	}
	fisher_yates_shuffle(\@array1);
	my $value = int(rand($#array1));
	print "@array1 ::::::::::: $array1[$value]\n"
}
else {
	warn "please use a proper location\n";
}
sub fisher_yates_shuffle {
        my $array = shift;
        my $i;
        for ($i = @$array; --$i;) {
                my $j = int rand ($i +1);
                next if $i == $j;
                @$array[$i,$j] = @$array[$j,$i];
        }
 }
