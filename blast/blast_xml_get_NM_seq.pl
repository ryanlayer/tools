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
  Extract hits from blast XML that have that mean the min hit length and 
  identity.  Each line containsthe following columns:

  query id, query len, hit len, hit id, hit num, hit gi, hit name

OPTIONS
  -h              Print this help message
  --xml     name  blast xml file
  --fasta   name  fasta file

EOF

	exit;
}

my $xml_file;
my $fasta_file;
my $help = 0;

GetOptions ("xml=s"	=> \$xml_file,		# string
			"fasta=s"	=> \$fasta_file,		# string
			"h"			=> \$help) or print_usage(); 

print_usage() if $help;

print_usage() if (not($xml_file) and not($fasta_file));

open(XML_FILE, $xml_file) or die "Could not open $xml_file\n$!";
open(FASTA_FILE, $fasta_file) or die "Could not open $fasta_file\n$!";

my $query_name = "";

my %nodes;

while (my $l = <XML_FILE>) {
	chomp($l);
	if ($l =~ /<Iteration_query-def>(.*)<\/Iteration_query-def>/) {
		$query_name = $1;
	} elsif ($l =~ /<Iteration_message>No hits found<\/Iteration_message>/) {
		$nodes{">" . $query_name} = 1;
	}
}
close(XML_FILE);

while (my $l = <FASTA_FILE>) {
	chomp($l);
	if (defined $nodes{$l}) {
		print <FASTA_FILE>;
	}
}

close(FASTA_FILE);
