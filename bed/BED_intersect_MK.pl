#!/usr/bin/perl
use strict;
use Seq;

my $version = 0.2;
sub usage1 {
	die qq(
Program: BED_intersect_MK.pl
Version: $version
Contact: Ryan Layer <rl6sf\@virginia.edu>

Usage:\tBED_intersect.pl <BED file a> <BED file b> <return cols> <unique key> <tie col>

BED_intersect findes intervals that instersect between  <BED file a> and <BED
file b>.  It is possible that intervals within a BED file interesect, in which
case one interval may intersect with several other intervals, each of these
intersections is found.  Intersections within a file are ignored.

<return cols> is used to display coloums from intersecting sequences.  A
comma-separated list of file/column indicates which columns of which file to
return.  For example "a1,a2,a3,b3" will return the first, second, and third
columns of <BED file a> and the third first column of  <BED file b>.

<unique key> is the BED file, a or b, that serves as the unique key.  Consider the
scenario where file a contains the intervals a1,a2,a3 and file b contains the
intervals b1,b2,b3. And the full set of intersections is \{\(a1,b1\), \(a1,b2\), 
\(a2,b3\), \(a3,b3\)\}.  If a is the unique key, then then one of the
intersections \{\(a1,b1\), \(a1,b2\)\} must be discarded.  If b is the unique
key, then of the the intersections \{\(a2,b3\), \(a3,b3\)\} must be discarded.
To decide which pair is discarded the following rules are applied.  If two
intersections have the same value for a particular rule, we move to the next
rule.

Let overlap be the size of the the intersecting region between to intervals.

1.  Keep the pair that maximizes the ratio of overlap to length of interval a.
2.  Keep the pair that maximizes the ratio of overlap to length of interval b.
3.  Keep the pair that maximizes the value defined by <tie col>.

<tie col> is used to break ties between pairs. The same format of file/column
used in <return cols> is used.  For example "b6" indicates that the 6th column
in BED file b contains the tie breaker value\n);
}

sub usage2 {
	die qq(Usage:\tBED_intersect.pl <BED file a> <BED file b> <return cols> <unique key> <tie col>
e.g.:\tBED_intersect.pl a.bed b.bed a1,a2,a3,b6 a b6\n);
}


&usage2 if (@ARGV < 1);
&usage1 if (@ARGV < 2);

my $file_a = shift;
my $file_b = shift;
my $cols = shift;
my $unique_key = shift;
my $tie = shift;

my $tie_col = -1;
my $tie_pair = -1;

if ($tie =~ /^a(\d+)/) {
	$tie_pair = 0;
	$tie_col = $1;
} elsif ($tie =~ /^b(\d+)/) {
	$tie_pair = 1;
	$tie_col = $1;
}

if ($unique_key =~ /a/) {
	$unique_key = 0;
} elsif ($unique_key =~ /b/) {
	$unique_key = 1;
}


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
		my $chrm = $1;
		my $start = $2;
		my $end = $3;

		my $detail_string = "";
		if ($#detail > -1) {
			$detail_string = join("\t",@detail);
		}

		my $tie_val = -1;
		if ($tie_pair = 0) {
			$tie_val = $detail_cols[$tie_col];
		}

		push(@{$A->{$1}}, {'c' => $chrm, 's' => $start, 'e' => $end, 
			't' => $tie_val, 'd' =>  $detail_string});
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

		my $chrm = $1;
		my $start = $2;
		my $end = $3;
		
		my $detail_string = "";
		if ($#detail > -1) {
			$detail_string = join("\t",@detail);
		}

		my $tie_val = -1;
		if ($tie_pair = 1) {
			$tie_val = $detail_cols[$tie_col];
		}

		push(@{$B->{$1}}, {'c' => $chrm, 's' => $start, 'e' => $end, 
			't' => $tie_val, 'd' =>  $detail_string});
	}
}
close(FILE);


foreach my $a (keys %{$A}) {
	my $R = Seq::seq_intersection($A->{$a}, $B->{$a}, 's', 'e');
	my $U;
	foreach my $r (keys %{$R}) {

		#my $k = $R->{$r}{0}{'s'} . "," . $R->{$r}{0}{'e'} . ":" .
		#$R->{$r}{1}{'s'} . "," . $R->{$r}{1}{'e'};

		my $k = $R->{$r}{$unique_key}{'s'} . "," . $R->{$r}{$unique_key}{'e'};

		if ( !(defined($U->{$k})) ) {
			$U->{$k} = $R->{$r};
		} else {
			my $old_diff = Seq::min($U->{$k}{0}{'e'},$U->{$k}{1}{'e'}) -
					Seq::max($U->{$k}{0}{'s'},$U->{$k}{1}{'s'});
			my $old_ratio = $old_diff/($U->{$k}{0}{'e'} - $U->{$k}{0}{'s'});

			my $new_diff = Seq::min($R->{$r}{0}{'e'},$R->{$r}{1}{'e'}) -
					Seq::max($R->{$r}{0}{'s'},$R->{$r}{1}{'s'});
			my $new_ratio = $new_diff/($R->{$r}{0}{'e'} - $R->{$r}{0}{'s'});

			if ($old_ratio < $new_ratio) {
				$U->{$k} = $R->{$r};
			} elsif ($old_ratio == $new_ratio) {
				my $r_old_ratio = $old_diff/($U->{$k}{1}{'e'} - $U->{$k}{1}{'s'});
				my $r_new_ratio = $new_diff/($R->{$r}{1}{'e'} - $R->{$r}{1}{'s'});

				if ($r_old_ratio < $r_new_ratio) {
					$U->{$k} = $R->{$r};
				} elsif (($r_old_ratio == $r_new_ratio) &&
						($U->{$k}{$tie_pair}{'t'} < $R->{$r}{$tie_pair}{'t'}) ) {
					$U->{$k} = $R->{$r};
				}
			}
		}
	}

	foreach my $r (keys %{$U}) {

		my @detail;
		my @a_detail = split(/\t/, $U->{$r}{0}{'d'});
		my @b_detail = split(/\t/, $U->{$r}{1}{'d'});

		my $a_col_index = 0;
		my $b_col_index = 0;

		foreach my $col (@t_cols) {
			if ($col =~/^a/) {
				push(@detail, $a_detail[$a_col_index++]);
			} elsif ($col =~ /^b/) {
				push(@detail, $b_detail[$b_col_index++]);
			}
		}

		my $diff = Seq::min($U->{$r}{0}{'e'},$U->{$r}{1}{'e'}) -
				Seq::max($U->{$r}{0}{'s'},$U->{$r}{1}{'s'});
		my $ratio = $diff/($U->{$r}{0}{'e'} - $U->{$r}{0}{'s'});

		print join("\t", @detail) . "\t" . $ratio . "\n";
	}
}
