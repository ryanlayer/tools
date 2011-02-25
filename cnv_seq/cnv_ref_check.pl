#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;
use File::Basename;
use Statistics::Descriptive;

my $prog = basename($0);

sub print_usage {
    warn <<"EOF";

USAGE
  $prog [options]

DESCRIPTION
  Extract infromation from each of the cnvs identified by cnv-seq

OPTIONS
  -h            Print this help message
  --id          Column number for the cnv id (default 9)  
  --chr         Column number for the chromosomve (default 1)  
  --start       Column number for the interval start (default 2)  
  --end         Column number for the interval end (default 3)  
  --test        Column number for the test count (default 4)
  --ref         Column number for the refence count (default 5)
  --file        *.cnv file from cnv-seq
  --size        size of the area around a cnv to consider (default 3)
  --no-header   Flag that says there is no header in the file

EOF
	exit;
}

my $help = 0;
my $file;
my $value=7;
my $cnv_id_col = 9;
my $value_col = 7;
my $chr_col = 1;
my $start_col = 2;
my $end_col = 3;
my $test_col = 4;
my $ref_col = 5;
my $size = 3;
my $no_header = 0;

GetOptions ( "file=s"	=> \$file,		# string
			 "id=i"		=> \$cnv_id_col, 
			 "value=i"	=> \$value_col, 
			 "chr=i"	=> \$chr_col, 
			 "start=i"	=> \$start_col, 
			 "end=i"	=> \$end_col, 
			 "test=i"	=> \$test_col, 
			 "ref=i"	=> \$ref_col, 
			 "size=i"	=> \$size, 
			 "no-header"=> \$no_header, 
			 "h"		=> \$help) or print_usage(); 

print_usage() if $help;
print_usage() if not($file);

# adjust col ids to be zero based
$cnv_id_col--;
$value_col--;
$chr_col--;
$start_col--;
$end_col--;
$test_col--;
$ref_col--;

open(FILE, $file) or die "Could not open $file.\n$!";

my $curr_cnv_id = 0;
my $stat;
my $chr;
my $start;
my $end;

my @pre_test = ();
my @post_test = ();
my @in_test = ();

my @pre_ref = ();
my @post_ref = ();
my @in_ref = ();

my $header;
if (not $no_header) {
	$header = <FILE>;
}

my $cnvs;
my $last_cnv_id = 1;
my $seen_first;

# We want to scan the data for a cnv, collect some amount of information before
# and after the cnv to determine if there is a deletion in the reference that
# is comming across as an amplification in the test.  To do this we will
# collect data from the surounding regions and test what the difference is

while (my $l = <FILE>) {
	chomp($l);
	my @a = split (/\t/, $l);

	if ($a[$cnv_id_col] =~ /[0-9]/) { # this is a valid line

		if ($a[$cnv_id_col] == 0) {

			# we want to keep a buffer of values before the next CNV
			unshift(@pre_test, $a[$test_col]);
			unshift(@pre_ref, $a[$ref_col]);

			if (@pre_test > $size) {
				pop(@pre_test);
			}

			if (@pre_ref > $size) {
				pop(@pre_ref);
			}

			#print join(",", @pre_test) . "\t" . join(",",@pre_ref) . "\n";

			if ($curr_cnv_id != 0) { # cnv just ended
				# Attach the data from in that cnv to the current cnv
				@{$cnvs->{$curr_cnv_id}{'ir'}} = @in_ref;
				@{$cnvs->{$curr_cnv_id}{'it'}} = @in_test;

				# reset in values for the next cnv
				@in_ref=();
				@in_test=();

				# reset the value of post dat and push the first values
				@post_test = ();
				@post_ref = ();
				unshift(@post_test, $a[$test_col]);
				unshift(@post_ref, $a[$ref_col]);

				$last_cnv_id = $curr_cnv_id;

				#print join( "\t",
				#$chr,
				#$start,
				#$end,
				#$stat->min(),
				#$stat->max(),
				#$stat->median() ) . "\n";
				##$stat->get_data() ) . "\n";

			} elsif ($seen_first) { # cnv ended some time ago

				# we either need to add more onto the post data,
				# attach the post data to the cnv
				# or ignore the data

				if (( @post_test < $size ) and ( @post_ref < $size)) {
					# need to collect more data after the last CNV
					unshift(@post_test, $a[$test_col]);
					unshift(@post_ref, $a[$ref_col]);
				} 
				
				#elsif ( (not ( defined( $cnv->{$last_cnv_id}{'pr'} ))) and
				#(not ( defined( $cnv->{$last_cnv_id}{'pt'} )))) {
				## need to collect more data after the last CNV
				#@{$cnv->{$last_cnv_id}{'pr'}} = @post_ref;
				#@{$cnv->{$last_cnv_id}{'pt'}} = @post_test;
				#}

			}


		} elsif ($a[$cnv_id_col] == $curr_cnv_id) { # in cnv
			unshift(@in_test, $a[$test_col]);
			unshift(@in_ref, $a[$ref_col]);
			#$stat->add_data( $a[$value_col] );
			#$end = $a[$end_col];

		} else { # cnv starting

			@{$cnvs->{$last_cnv_id}{'br'}} = @pre_ref;
			@{$cnvs->{$last_cnv_id}{'bt'}} = @pre_test;

			if ($seen_first) {
				#attach data to the previous cnv
				@{$cnvs->{$last_cnv_id}{'ar'}} = @post_ref;
				@{$cnvs->{$last_cnv_id}{'at'}} = @post_test;

				@post_ref = ();
				@post_test = ();
			}

			$seen_first = 1;

			#if ($curr_cnv_id != 0) { # cnv over
			#print join( "\t",
			#$chr,
			#$start,
			#$end,
			#$stat->min(),
			#$stat->max(),
			#$stat->median() ) . "\n";
			##$stat->get_data() ) . "\n";
			#}

			@in_test = ();
			@in_ref = ();

			unshift(@in_test, $a[$test_col]);
			unshift(@in_ref, $a[$ref_col]);

			#$curr_cnv_id = $a[$cnv_id_col];
			#$stat = Statistics::Descriptive::Full->new();
			#$stat->add_data( $a[$value_col] );
			#$chr = $a[$chr_col];
			#$start = $a[$start_col];
		}

		$curr_cnv_id = $a[$cnv_id_col];
	}
}

print Dumper($cnv);

close(FILE);
