#!/usr/bin/perl -w
use strict;
use MyPBS;
use Getopt::Long;
use File::Basename;
use Data::Dumper;
my $prog = basename($0);

sub print_usage {
    warn <<"EOF";

USAGE
  $prog [options]

DESCRIPTION

OPTIONS
  -h             Print this help message
  --dir  dir	 Target directory
  --max  max	 Max number of jobs (Default 20)
  --ysfx suffix  Yes suffix list (e.g., .fastq)
  --nsfx suffix  Do not extract if a file with matching name
				 any of the suffixes in the list sfx are in the same directory
                 (e.g., .bam,.sam)
  --sim			 Print what would be queued

EOF
	exit;
}

my $dir;
my $no_sfx_list="_1.fastq,_2.fastq,.fastq";
my $yes_sfx_list=".sra";
my $max=20;
my $help = 0;
my $sim = 0;

GetOptions ("dir=s"	=> \$dir,		# string
			"nsfx=s" => \$no_sfx_list,
			"ysfx=s" => \$yes_sfx_list,
			"max=i" => \$max,
			"sim"		=> \$sim,
			"h"			=> \$help) or print_usage(); 

print_usage() if $help;

print_usage() if (not($dir) or 
				  not($max) or 
				  not($no_sfx_list) or 
				  not($yes_sfx_list));

my $novo_one = "/net/dutta_tumor/bin/novo_align_one.sh";

my @no_sfx=split(/,/, $no_sfx_list);
my @yes_sfx=split(/,/, $yes_sfx_list);

my @files = MyPBS::get_files($dir, \@yes_sfx, \@no_sfx, $max);

foreach my $file (@files) {
	my $cmd = "$novo_one -t $file -p $yes_sfx_list";
	if ($sim) {
		print "$cmd\n";
	} else {
		system("$cmd");
	}
}
