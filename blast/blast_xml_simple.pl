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
  --file     name File we want use
  --length   min  Minium hit length/query length (default 0.9)
  --identity  min Minium hit /identity hit length (default 0.9)
  --verbose       Show allignment

EOF

	exit;
}

my $file;
my $len_min=0.0;
my $id_min=0.0;
my $verbose;
my $help = 0;

GetOptions ("file=s"	=> \$file,		# string
			"length=s"	=> \$len_min,
			"identity=s"	=> \$id_min,
			"verbose"	=> \$verbose,
			"h"			=> \$help) or print_usage(); 

print_usage() if $help;

print_usage() if not($file);

open(FILE, $file) or die "Could not open $file.\n$!";

my $query_name = "";
my $query_id = "";
my $query_len = 0;
my $query_match = "";

my $both_match = "";

my $hit_name = "";
my $hit_num = 0;
my $hit_match = "";
my $hit_len = 0;
my $hit_id = 0;
my $hit_id_gi = 0;

while (my $l = <FILE>) {
	chomp($l);
	if ($l =~ /<Iteration_query-def>(.*)<\/Iteration_query-def>/) {
		$query_name = $1;
	} elsif ($l =~ /<Iteration_iter-num>(.*)<\/Iteration_iter-num>/) {
		$query_id = $1;
	} elsif ($l =~ /<Iteration_query-len>(.*)<\/Iteration_query-len>/) {
		$query_len = $1;
	} elsif ($l =~ /<Hit_id>gi\|([^\|]+)\|.*<\/Hit_id>/) {
		$hit_id_gi = $1;
	} elsif ($l =~ /<Hit_num>(.*)<\/Hit_num>/) {
		$hit_num = $1;
	} elsif ($l =~ /<Hit_def>(.*)<\/Hit_def>/) {
		$hit_name = $1;
	} elsif ($l =~ /<Hsp_align-len>(.*)<\/Hsp_align-len>/) {
		$hit_len = $1;
	} elsif ($l =~ /<Hsp_qseq>(.*)<\/Hsp_qseq>/) {
		$query_match = $1;
	} elsif ($l =~ /<Hsp_hseq>(.*)<\/Hsp_hseq>/) {
		$hit_match = $1;
	} elsif ($l =~ /<Hsp_identity>(.*)<\/Hsp_identity>/) {
		$hit_id = $1;
	} elsif ($l =~ /<Hsp_midline>(.*)<\/Hsp_midline>/) {
		$both_match = $1;
	} elsif ($l =~ /<\/Hit>/) {
		if ( ( ($hit_len / $query_len) >= $len_min) &&
			 ( ($hit_id / $hit_len) >= $id_min) ) {
			 print join("\t", 
							  $query_id,
							  $query_len,
							  $hit_len,
							  $hit_id,
							  $hit_num,
							  $hit_id_gi,
							  $hit_name);
			if ($verbose) {
				print "\t" . join("\t", 
								$query_match,
								$hit_match,
								$both_match);
	
			}

			print "\n";

		 }
	}
}
