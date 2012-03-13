#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Basename;
my $prog = basename($0);

sub print_usage {
    warn <<"EOF";

USAGE
  $prog [options]

DESCRIPTION
  Filter out seuqnces less that a given amount

OPTIONS
  -h                 Print this help message
  --file    name     File we want use
  --minlen  length   Minimum sequence length

EOF
	exit;
}

my $file;
my $min_length;
my $help = 0;

GetOptions ("file=s"	=> \$file,		# string
			"minlen=i"		=> \$min_length,
			"h"			=> \$help) or print_usage(); 

print_usage() if $help;

print_usage("No file") if not($file);
print_usage("No minlen") if not($min_length);

open(FILE, $file) or die "Could not open $file.\n$!";

my $seq;
my $name;
while (my $l = <FILE>) {
	chomp($l);

	if ($l =~ /^>/) {
		if ($name) {
			if (length($seq) >= $min_length) {
				print $name. "\n";
				print $seq . "\n";
			}
			$seq = "";
		}
		$name = $l;
	} else {
		$seq = $seq . $l;
	}
}
close(FILE);
