#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;
use File::Basename;
my $prog = basename($0);

sub print_usage {
    warn <<"EOF";

USAGE
  $prog [options]

DESCRIPTION
  Whatever this program should do.

OPTIONS
  -h                Print this help message
  --universe       Universe considered
  --num-intervals  Number of intervals to create
  --seed           Random seed
  --size           Interval size (default 250)

EOF
}

my $universe_file;
my $N;
my $help = 0;
my $size = 250;
my $rand_seed = time ^ $$ ^ unpack "%L*", `ps axww | gzip -f`;

GetOptions ("num-intervals=i"	=> \$N,	
			"universe=s"		=> \$universe_file,
			"seed=i"			=> \$rand_seed,
			"size=i"			=> \$size,
			"h"					=> \$help) or print_usage(); 

print_usage() if $help;

print_usage() if (not($universe_file) or not($N));

open(FILE, $universe_file) or die "Could not open $universe_file.\n$!";

my $U;
my $U_size = 0;
my $next = 0;

while(my $l = <FILE>) {
	if ($l =~ /^(chr[^\t]+)\t(\d+)\t(\d+)/) {
		$U->{$next}{'c'} = $1;
		$U->{$next}{'s'} = $2;
		$U->{$next}{'e'} = $3;
		$next += $U->{$next}{'e'} - $U->{$next}{'s'};
	}
}

srand($rand_seed);

my @keys = sort {$a <=> $b} keys %{$U};

for (my $i = 0; $i < $N; $i++) {

	my $R = int( rand($next) );
	my $hit = 0;

	for (my $j = 0; $j < $#keys; $j++) {
		if ($R < $keys[$j + 1]) {
			$hit = $j;
			last;
		}
	}

	my $key = $keys[$hit];
	my $offset = $R - $key;

	print join("\t", $U->{$key}{'c'},
					 $U->{$key}{'s'} + $offset,
					 $U->{$key}{'e'} + $offset + $size) . "\n";
}
