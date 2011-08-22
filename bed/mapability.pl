#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Basename;
use Statistics::Descriptive;
my $prog = basename($0);

sub print_usage {
    warn <<"EOF";

USAGE
  $prog [options]

DESCRIPTION
  Give the distances between regions in a bed file.

OPTIONS
  -h            Print this help message
  --bed  file   Target bed file
  --path path   Path to bigWigToBedGraph
  --cover  file   Mapability file

EOF
	exit;
}

my $bed_file;
my $help = 0;
my $wig_to_bed_path;
my $cover_file;

GetOptions ("bed=s"	=> \$bed_file,		# string
			"path=s"	=> \$wig_to_bed_path,		# string
			"cover=s"	=> \$cover_file,		# string
			"h"			=> \$help) or print_usage(); 

print_usage() if $help;

print_usage() if (not($bed_file) and
				  not($wig_to_bed_path) and
				  not($cover_file));

open(MAP_FILE, $bed_file) or die "Could not open $bed_file.\n$!";

my $tmp = ".tmp";

my $header = <MAP_FILE>;

while (my $l = <MAP_FILE>) {
	chomp($l);

	my @a = split ("\t", $l);

	system("$wig_to_bed_path $cover_file $tmp " .
			"-chrom=" . $a[0] . " " .
			"-start=" . $a[1] . " " .
		    "-end=" . $a[2]);
	
	my @V;
	my @L;
	open(TMP_FILE, $tmp);	
	while (my $l_t = <TMP_FILE>) {
		chomp($l_t);
		my @a = split ("\t", $l_t);
		my $r = abs($a[2] - $a[1]);

		push(@L,  $r);
		push(@V, $a[3]);
	}
	close(TMP_FILE);

	my $sum = 0;
	my $len = 0;

	for(my $i = 0; $i < @V; $i++) {
		$sum += $V[$i] * $L[$i];
		$len += $L[$i];
	}

	my $mean = $sum/$len;
	print $l . "\t" . $mean . "\n";
}

close(MAP_FILE);
