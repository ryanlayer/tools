#!/usr/bin/perl
use Data::Dumper;
use strict;
use warnings;
my @files;
my @names;

if ( @ARGV != 4 ) {
	print "usage:\tbed_to_gff.pl <BED file> <source> <feature> <score col>\n".
		"\t\t<score col> is col number, 1 based, starting after the 3rd col\n";
		"\t\tif 0 then score = 0\n";
	exit;
}

my $file_name = $ARGV[0];
my $source = $ARGV[1];
my $feature = $ARGV[2];
my $score_col = $ARGV[3];

open(FILE, $file_name);
my $group = 0;
while(<FILE>) {
	if (/^(chr[^\t]*)\t(\d+)\t(\d+)(.*)/) {
		my $chr = $1;
		my $start = $2;
		my $end = $3;
		my @rest = split(/\t/, $4);

		
		my $score;
		if ($score_col == 0) {
			$score = 0;
		} else {
			$score = $rest[$score_col - 1];
		}

		print join("\t", 
				   $chr,
				   $source,
				   $feature, 
				   $start,
				   $end,
				   $score,
				   ".",
				   ".",
				   $group) . "\n";

		$group++;
	}
	else {
		print ":(\n";
	}
}
close(FILE);
