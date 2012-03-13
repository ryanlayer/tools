#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;
use File::Basename;
use LWP::Simple;
my $prog = basename($0);

sub print_usage {
	my ($msg) = @_;
    warn <<"EOF";

$msg

USAGE
  $prog [options]

DESCRIPTION

OPTIONS
  -h              Print this help message
  --file  name    File we want use
  --col   col_num Column (default 1)
  --sep   pattern Charater seperating fields (defualt <tab>)

EOF
	exit;
}

my $file;
my $col = 1;
my $sep = "\t";
my $help = 0;

GetOptions ("file=s"	=> \$file,		# string
			"col=i"		=> \$col,
			"sep=s"		=> \$sep,
			"h"			=> \$help) or print_usage(); 

print_usage() if $help;
print_usage("No file") if not($file);

# zero-base the col
$col--;

open(FILE, $file) or die "Could not open $file.\n$!";

while (my $l = <FILE>) {
	chomp($l);
	print $l;
	my @a = split ($sep, $l);

	my $gene = $a[$col];

	my $url = "http://www.ncbi.nlm.nih.gov/nuccore/" . $gene;
	#my @content = split(/\n/, get $url);
	my $content = get $url;

	#refid=mKIAA1889&species=mouse" 
	if ($content =~ /.*title.*\((\w+)\).*/) {
		print "\t$1";
	}
	print "\n";

	##BGCOLOR='#000C00'>
	#if ($content =~ /(.*Ratios)/) {
	#my $temp = $1;
	#my @matches = $temp =~ /BGCOLOR='#(\w+)'/g;
	#print Dumper(@matches);
	#print "\n";
	#}
}
