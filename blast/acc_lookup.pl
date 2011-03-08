#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Basename;

use Data::Dumper;

use Bio::DB::GenBank;
use Bio::Seq::RichSeq;
use Bio::SeqFeatureI;
 
my $prog = basename($0);

sub print_usage {
    warn <<"EOF";

USAGE
  $prog [options]

DESCRIPTION
  Lookup species etc from a list

OPTIONS
  -h            Print this help message
  --file  name   File we want use
  --gi   col_num Column of the gi number (default 5)
  --sep   pattern Charater seperating fields (defualt <tab>)

EOF
	exit;
}

my $file;
my $gi_col = 5;
my $help = 0;

GetOptions ("file=s"	=> \$file,		# string
			"gi=i"		=> \$gi_col,
			"h"			=> \$help) or print_usage(); 

print_usage() if $help;

print_usage() if not($file);

## adjust cols for zero base
$gi_col--;

open(FILE, $file) or die "Could not open $file.\n$!";

my $gb = Bio::DB::GenBank->new();

my @stream = ();

my %filter = (
	"Homo sapiens" => 1,
	"Gorilla gorilla" => 1,
	"Gorilla gorilla gorilla" => 1,
	"Macaca fuscata fuscata" => 1,
	"Macaca mulatta" => 1,
	"Pan troglodytes" => 1);


while (my $l = <FILE>) {
	chomp($l);

	my @a = split ("\t", $l);


		#my $seq = $gb->get_Seq_by_gi($a[$gi_col]); # GI Number
		push(@stream, $a[$gi_col]);
		my $size = @stream;
		if (@stream >= 10) {
			#print join(",", @stream) . "\n";
			my $seqio = $gb->get_Stream_by_acc(\@stream);
			#print "seqio\t" . $seqio . "\n";
			my $i = 0;
			while( my $seq =  $seqio->next_seq() ) {
				print "\t\t" . $seq->accession_number() . "\n";
				foreach my $feat ($seq->get_SeqFeatures()) {
					#print "feat\t" . $feat . "\n";
					if( $feat->primary_tag eq 'source' ) {
						my @f = $feat->each_tag_value('organism');
						#db_xref,mol_type,clone,tissue_type,lab_host,organism,clone_lib,note
						#if ($f[0] ne "Homo sapiens") {
						#if (not defined ($filter{$f[0]})) {
							print join(",", $feat->each_tag_value('mol_type')) ."\t";
							print join(",", $feat->each_tag_value('tissue_type')) ."\t";
							print join(",", $feat->each_tag_value('organism')) ."\t";
							print $stream[$i] . "\n";;
							#}
					}
				}
				$i++;
			}
			@stream=();
		}
}
