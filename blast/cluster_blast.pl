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
  Cluster the results of blast_xml_simple.pl

OPTIONS
  -h            Print this help message
  --file  name   File we want use

EOF
	exit;
}

my $file;
my $sep = "/\t/";
my $help = 0;

GetOptions ("file=s"	=> \$file,		# string
			"h"			=> \$help) or print_usage(); 

print_usage() if $help;

print_usage() if not($file);

open(FILE, $file) or die "Could not open $file.\n$!";

#  query id, query len, hit len, hit id, hit num, hit gi, hit name
my %col = (
	q_id => 0,
	q_len => 1,
	hit_len => 2,
	hit_id => 3,
	hit_num => 4,
	hit_gi => 5,
	hit_name => 6
);

my $name_stats;
my $hit_graph;

while (my $l = <FILE>) {
	chomp($l);

	my @a = split (/\t/, $l);

	my @name = split(/ /, $a[$col{hit_name}]);

	my $rep_name = "$name[0] $name[1]";
	my $q_len = $a[$col{q_len}];
	my $q_id = $a[$col{q_id}];

	if (not defined($hit_graph->{$q_id})) {
		$hit_graph->{$q_id}{l} = $q_len;
		my @V;
		$hit_graph->{$q_id}{V} = \@V;
	}

	my @v = ($a[$col{hit_id}], $a[$col{hit_name}]);
	push( @{ $hit_graph->{$q_id}{V} }, \@v);

	if (not defined($name_stats->{$rep_name})) {
		$name_stats->{$rep_name}{n} = 0;
		$name_stats->{$rep_name}{m} = 0;
		$name_stats->{$rep_name}{id} = 0;
	} 

	$name_stats->{$rep_name}{n} = $name_stats->{$rep_name}{n} + 1;

	if ($name_stats->{$rep_name}{m} < $q_len) {
		$name_stats->{$rep_name}{m} = $q_len;
		$name_stats->{$rep_name}{id} = $q_id;
	}
}

my $cluster;

foreach my $N (keys %{ $hit_graph }) {
	my $max_n;
	my $max_rep = 0;
	my $max_rep_name;
	foreach my $n ( @{ $hit_graph->{$N}{V} }) {
		my @name = split(/ /, $n->[1]);
		my $rep_name = "$name[0] $name[1]";

		if ($name_stats->{$rep_name} > $max_rep) {
			$max_n = $n;
			$max_rep = $name_stats->{$rep_name};
			$max_rep_name = $rep_name;
		}
	}

	my %e = (
		q_id => $N,
		q_len => $hit_graph->{$N}{l},
		hit_len =>$max_n->[0],
		hit_name =>$max_n->[1]
	);

	if (not defined( $cluster->{$max_rep_name} ) ) {
		my @E;
		$cluster->{$max_rep_name}{E} = \@E;
		$cluster->{$max_rep_name}{N} = 0;
	}

	push ( @{ $cluster->{$max_rep_name}{E} }, \%e);
	$cluster->{$max_rep_name}{N} = $cluster->{$max_rep_name}{N} + 1;
}

foreach my $c_name (
		sort { $cluster->{$a}{N} <=> $cluster->{$b}{N} }
		keys %{ $cluster }) {
	
	my $max_e;
	my $max_hit_len = 0;
	foreach my $e ( @{ $cluster->{$c_name}{E} } ) {
		if ($e->{hit_len} > $max_hit_len) {
			$max_hit_len = $e->{hit_len};
			$max_e = $e;
		}
	}

	print join("\t", $cluster->{$c_name}{N},
					 $max_e->{q_len},
					 $max_e->{hit_len},
					 #$c_name,
					 $max_e->{hit_name}
			) . "\n";
}
