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
  Extract infromation from each of the cnvs identified by cnv-seq

OPTIONS
  -h       Print this help message
  --id     Column number for the cnv id (default 9)  
  --value  Column number for the value of interest (default 7, log2)
  --chr    Column number for the chromosomve (default 1)  
  --start  Column number for the interval start (default 2)  
  --end    Column number for the interval end (default 3)  
  --file   *.cnv file from cnv-seq

EOF
}

my $help = 0;
my $file;
my $value=7;
my $cnv_id_col = 9;
my $value_col = 7;
my $chr_col = 1;
my $start_col = 2;
my $end_col = 3;

GetOptions ( "file=s"	=> \$file,		# string
			 "id=i"		=> \$cnv_id_col, 
			 "value=i"	=> \$value_col, 
			 "chr=i"	=> \$chr_col, 
			 "start=i"	=> \$start_col, 
			 "end=i"	=> \$end_col, 
			 "h"		=> \$help) or print_usage(); 

print_usage() if $help;
print_usage() if not($file);

# adjust col ids to be zero based
$cnv_id_col--;
$value_col--;
$chr_col--;
$start_col--;
$end_col--;

open(FILE, $file) or die "Could not open $file.\n$!";

my $curr_cnv_id = 0;
my $stat;
my $chr;
my $start;
my $end;

while (my $l = <FILE>) {
	chomp($l);
	my @a = split (/\t/, $l);

	if ($a[$cnv_id_col] =~ /[0-9]/) {

		if ($a[$cnv_id_col] == 0) {

			if ($curr_cnv_id != 0) { # cnv over
				print join( "\t",
							$chr,
							$start,
							$end,
							$stat->min(),
							$stat->max(),
							$stat->median() ) . "\n";
							#$stat->get_data() ) . "\n";
			}

			$curr_cnv_id = $a[$cnv_id_col];

		} elsif ($a[$cnv_id_col] == $curr_cnv_id) { # in cnv
			$stat->add_data( $a[$value_col] );
			$end = $a[$end_col];

		} else { # cnv starting

			if ($curr_cnv_id != 0) { # cnv over
				print join( "\t",
							$chr,
							$start,
							$end,
							$stat->min(),
							$stat->max(),
							$stat->median() ) . "\n";
							#$stat->get_data() ) . "\n";
			}

			$curr_cnv_id = $a[$cnv_id_col];
			$stat = Statistics::Descriptive::Full->new();
			$stat->add_data( $a[$value_col] );
			$chr = $a[$chr_col];
			$start = $a[$start_col];
		}

	}
}

close(FILE);
