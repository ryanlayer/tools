#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
my $prog = basename($0);

sub print_usage {
	my ($msg) = @_;
    warn <<"EOF";

$msg

USAGE
  $prog [options]

DESCRIPTION
  Split a fasta file into a number of different files

OPTIONS
  -h                 Print this help message
  --file  name       File we want use
  --num   number     Number of entries per file
  --dir   directory  Output dir (default .)
  --suffix suffix    Custom suffix (default fa, fasta, txt)

EOF
	exit;
}

my $file;
my $num;
my $dir = ".";
my $c_sfx;
my $help = 0;

GetOptions ("file=s"	=> \$file,		# string
			"dir=s"		=> \$dir,
			"num=i"		=> \$num,
			"sfx=s"		=> \$c_sfx,
			"h"			=> \$help) or print_usage(); 

print_usage() if $help;
print_usage("No file") if not($file);
print_usage("No num") if not($num);

my @sfx = (".fa", ".fasta", ".txt");

if ($c_sfx) {
	push(@sfx, $c_sfx);
}


my($filename, $directories, $suffix) = fileparse($file, @sfx);

print "$filename\t$directories\t$suffix\n";

open(IN_FILE, $file) or die "Could not open $file.\n$!";


my $in = 0;
my $curr_num = 0;
my $num_files=0;

if (not (-d $dir) ) {
	`mkdir $dir`;
}

open(OUT_FILE, "> $directories$filename.$num_files$suffix");

while (my $l = <IN_FILE>) {
	if ($l =~ /^>/) {
		if ($curr_num >= $num) { #new file
			close(OUT_FILE);
			$num_files++;
			open(OUT_FILE, "> $dir/$filename.$num_files$suffix");
			print "> $dir/$filename.$num_files$suffix\n";
			$curr_num = 0;
		} 
		$curr_num++;
	} 

	print OUT_FILE $l;
}

close(IN_FILE);
