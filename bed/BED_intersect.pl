#!/usr/bin/perl
use strict;
use Seq;

my $version = 0.2;
sub usage {
	die qq(
Program: BED_intersect.pl
Version: $version
Contact: Ryan Layer <rl6sf\@virginia.edu>

Usage:\tBED_intersect.pl <BED file a> <BED file b> <return columns>

BED_intersect findes intervals that instersect between  <BED file a> and <BED
file b>.  It is possible that intervals within a BED file interesect, in which
case one interval may intersect with several other intervals, each of these
intersections is found.  Intersections within a file are ignored.

<return columns> is used to display coloums from intersecting sequences.  A
comma-separated list of file/column indicates which columns of which file to
return.  For example "a1,a2,a3,b3" will return the first, second, and third
columns of <BED file a> and the third first column of  <BED file b>.\n);
}


&usage if (@ARGV < 1);

my $file_a = shift;
my $file_b = shift;
my $cols = shift;

my @a_cols;
my @b_cols;
my @t_cols = split(/,/, $cols);

foreach my $col (@t_cols) {
	if ($col =~ /^a(\d+)/) {
		push(@a_cols, $1);
	} elsif ($col =~ /^b(\d+)/) {
		push(@b_cols, $1);
	}
}

my $A;

open(FILE, $file_a);
while (<FILE>) {
	my $line_s = $_;
	chomp($line_s);
	if ($line_s =~ /(chr.*)\t(\d+)\t(\d+)/) {
		my @detail_cols = split(/\t/, $line_s);
		my @detail;
		foreach my $a_col (@a_cols) {
			push(@detail, $detail_cols[$a_col - 1]);
		}

		my $detail_string = "";
		if ($#detail > -1) {
			$detail_string = join("\t",@detail);
		}

		push(@{$A->{$1}}, {'c' => $1, 's' => $2, 'e' => $3, 
			'd' =>  $detail_string});
	}
}
close(FILE);

my $B;

open(FILE, $file_b);
while (<FILE>) {
	my $line_s = $_;
	chomp($line_s);
	if ($line_s =~ /(chr.*)\t(\d+)\t(\d+)/) {
		#my @detail_cols = split(/\t/, $4);
		my @detail_cols = split(/\t/, $line_s);
		my @detail;
		foreach my $b_col (@b_cols) {
			push(@detail, $detail_cols[$b_col - 1]);
		}
		my $detail_string = "";
		if ($#detail > -1) {
			$detail_string = join("\t",@detail);
		}
		push(@{$B->{$1}}, {'c' => $1, 's' => $2, 'e' => $3, 
				'd' => $detail_string});
	}
}
close(FILE);

foreach my $a (keys %{$A}) {
	my $R = Seq::seq_intersection($A->{$a}, $B->{$a}, 's', 'e');
	foreach my $r (keys %{$R}) {
		my $diff = Seq::min($R->{$r}{0}{'e'},$R->{$r}{1}{'e'}) -
				Seq::max($R->{$r}{0}{'s'},$R->{$r}{1}{'s'});
		my $ratio = $diff/($R->{$r}{0}{'e'} - $R->{$r}{0}{'s'});


		my @detail;
		my @a_detail = split(/\t/, $R->{$r}{0}{'d'});
		my @b_detail = split(/\t/, $R->{$r}{1}{'d'});

		my $a_col_index = 0;
		my $b_col_index = 0;

		foreach my $col (@t_cols) {
			if ($col =~/^a/) {
				push(@detail, $a_detail[$a_col_index++]);
			} elsif ($col =~ /^b/) {
				push(@detail, $b_detail[$b_col_index++]);
			}
		}

		print join("\t", @detail) . "\t" . $ratio . "\n";
	}
}
