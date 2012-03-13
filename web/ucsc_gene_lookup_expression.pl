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
	print $l . "\t";
	my @a = split ($sep, $l);

	my $gene = $a[$col];

	my $url = "http://genome.ucsc.edu/cgi-bin/hgGene?db=mm9&hgg_gene=" . $gene;
	my $x = get $url;
	my @content = split(/\n/, $x);

	my $flag = 0;

	for my $c (@content) {
		if ($c =~ /refid=(\w+)/) {
			print "$1\t";
		} elsif ($flag == 1) {
			if ($c =~ /Ratios/) {
				my @matches = $c =~ /BGCOLOR='#(\w+)'/g;
				my @levels;
				foreach my $match (@matches) {
					my $red = hex(substr $match, 0, 2);
					my $blue = hex(substr $match, 2, 2);
					push(@levels, "$red,$blue");
				}
				print join("\t", @levels);
				last;
			}
		} elsif ($c =~ /Affymetrix All Exon Microarrays/) {
			$flag = 1;
		}

	}
	print "\n";
}
