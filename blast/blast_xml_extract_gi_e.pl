#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Data::Dumper;
use File::Basename;
use MyBioPerl;
my $prog = basename($0);

our $debug;
our %state = ();


sub print_usage {
    warn <<"EOF";

USAGE
  $prog [options]

DESCRIPTION
  Give the distances between regions in a bed file.

OPTIONS
  -h               Print this help message
  --file     name  File we want use
  --evalue   value Max evalue (default 0.001)
  --debug          Show parsing state
EOF

	exit;
}

sub assert_state {
	my ($curr, $val) = @_;

	if (not defined $state{$curr}) {
		set_state($curr, 0);
	} 

	warn "ASSERT $curr $val\t$state{$curr}\n" if $debug;

	if ( $state{$curr} != $val ) {
		warn "PARSING ERROR\n";
		exit;
	}
}

sub check_state {
	my ($curr, $val) = @_;

	if (not defined $state{$curr}) {
		set_state($curr, 0);
	} 

	warn "CHECK $curr $val\t$state{$curr}\n" if $debug;

	return $state{$curr} == $val; 
}

sub set_state {
	my ($curr, $val) = @_;

	warn "SET $curr $val\n" if $debug;

	$state{$curr} = $val;
}

my $file;
my $min_e = 0.001;
my $help = 0;

GetOptions ("file=s"	=> \$file,		# string
			"evalue=i"  => \$min_e,
			"debug"  => \$debug,
			"h"			=> \$help) or print_usage(); 

print_usage() if $help;

print_usage() if not($file);

open(FILE, $file) or die "Could not open $file.\n$!";

my $hits;
my $query_def = "";
my $hit_acc;

#set_state($state, 'in_q', 0);

# Each query starts with <Iteration>
# The name of each query is <Iteration_query-def>
# Each hit starts with <Hit> and has an accession number <Hit_accession>
# Within a hit, there can be a number of HSPs that start with <Hsp>, but each
# HSP has the same accession number, so we can just take the information from
# the first one.
# An HSP has three pieces of informaiton:
#   1) evalue <Hsp_evalue>
#   2) alignment length <Hsp_align-len>
#   3) identity <Hsp_identity>
# For each seqeunce, we want the set of hits where a hit is the accession,
# evalue, alighment lenght, and identity 
while (my $l = <FILE>) {
	chomp($l);

	# A new sequence query is starting, we want to get the length and id
	if ( $l =~ /<Iteration>/ ) {
		assert_state('in_q', 0);
		set_state('in_q', 1);

	# Query definition
	} elsif ($l =~ /<Iteration_query-def>(.*)<\/Iteration_query-def>/) {

		assert_state('in_q', 1);
		$query_def = $1;

	# Query length
	} elsif ($l =~ /<Iteration_query-len>(.*)<\/Iteration_query-len>/)  {

		assert_state('in_q', 1);
		$hits->{$query_def}{'len'} = $1;

	# Another hit. Pick up the accession number, then look for the first HSP,
	# and skip the rest
	} elsif ( $l =~ /<Hit>/ ) {
		assert_state('in_q', 1);
		assert_state('in_hit', 0);
		set_state('in_hit', 1);
		set_state('hit_acc', 0);

	# get the Accession number
	} elsif ( $l =~ /<Hit_accession>(.*)<\/Hit_accession>/ ) {
		assert_state('in_q', 1);
		assert_state('in_hit', 1);
		assert_state('hit_acc', 0);
		set_state('hit_acc', 1);

		$hit_acc = $1;

		#$hits->{$query_def}{'hits'}{$hit_acc}{'acc'} = $1;

	# enter the hsps, we only want the first one, once we see the end of the
	# first hsp </Hsp>, we set the 'seen_hsp' state to 1
	} elsif ( $l =~ /<Hit_hsps>/ ) {
		assert_state('in_q', 1);
		assert_state('in_hit', 1);
		assert_state('in_hsp', 0);
		set_state('in_hsp', 1);
		set_state('seen_hsp', 0);

	} elsif ($l =~ /<Hsp_identity>(.*)<\/Hsp_identity>/) {

		assert_state('in_q', 1);
		assert_state('in_hit', 1);
		assert_state('in_hsp', 1);
		assert_state('hit_acc', 1);
		if ( check_state('seen_hsp', 0) ) {
			$hits->{$query_def}{'hits'}{$hit_acc}{'id'} = $1;
		}

	} elsif ($l =~ /<Hsp_evalue>(.*)<\/Hsp_evalue>/) {

		assert_state('in_q', 1);
		assert_state('in_hit', 1);
		assert_state('in_hsp', 1);
		assert_state('hit_acc', 1);
		if ( check_state('seen_hsp', 0) ) {
			$hits->{$query_def}{'hits'}{$hit_acc}{'e'} = $1;
		}

	} elsif ($l =~ /<Hsp_align-len>(.*)<\/Hsp_align-len>/) {

		assert_state('in_q', 1);
		assert_state('in_hit', 1);
		assert_state('in_hsp', 1);
		assert_state('hit_acc', 1);
		if ( check_state('seen_hsp', 0) ) {
			$hits->{$query_def}{'hits'}{$hit_acc}{'len'} = $1;
		}

	} elsif ( $l =~ /<\/Hsp>/ ) {
		assert_state('in_q', 1);
		assert_state('in_hit', 1);
		assert_state('in_hsp', 1);
		set_state('seen_hsp', 1);

	# out of HSP
	} elsif ( $l =~ /<\/Hit_hsps>/ ) {
		assert_state('in_q', 1);
		assert_state('in_hit', 1);
		assert_state('in_hsp', 1);
		set_state('in_hsp', 0);

	# out of HIT
	} elsif ( $l =~ /<\/Hit>/ ) {
		assert_state('in_q', 1);
		assert_state('in_hit', 1);
		assert_state('hit_acc', 1);
		set_state('in_hit', 0);
		set_state('hit_acc', 0);

	# Done with the query
	} elsif ( $l =~ /<\/Iteration>/ ) {
		assert_state('in_q', 1);
		assert_state('in_hit', 0);
		set_state('in_q', 0);


		print "$query_def\t$hits->{$query_def}{'len'}\t";
		my @accs;
		
		foreach my $hit_acc ( keys %{ $hits->{$query_def}{'hits'} } ) {
			if ($hits->{$query_def}{'hits'}{$hit_acc}{'e'} < $min_e) {
				push(@accs, $hit_acc);
			}
		}

		print @accs . "\n";

		if (@accs > 0 ) {
			my %acc_org = MyBioPerl::get_organism_by_acc(@accs);
			foreach my $acc (keys %acc_org) {
				print "-\t" . join("\t", $acc,
								 $acc_org{$acc},
								 $hits->{$query_def}{'hits'}{$acc}{'e'},
								 $hits->{$query_def}{'hits'}{$acc}{'len'},
								 $hits->{$query_def}{'hits'}{$acc}{'id'}
							 )
					. "\n";
			}
		}
	}
}
