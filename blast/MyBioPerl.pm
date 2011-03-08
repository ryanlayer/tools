#!/usr/bin/perl -w
use strict;
use Bio::DB::GenBank;
use Bio::Seq::RichSeq;
use Bio::SeqFeatureI;

package MyBioPerl;
 
sub get_organism_by_acc {
	my @stream = @_;

	my %r;

	my $gb = Bio::DB::GenBank->new();
	my $size = @stream;
	# $sequi is type Bio::SeqIO::genbank
	my $seqio = $gb->get_Stream_by_acc(\@stream);

	# $seq is type Bio::Seq::RichSeq
	while( my $seq =  $seqio->next_seq() ) {
		
		# $feat is type Bio::SeqFeature::Generic
		foreach my $feat ($seq->get_SeqFeatures()) {
			if( $feat->primary_tag eq 'source' ) {
				#print $seq->accession_number() . "\t" .
				#join(",", $feat->each_tag_value('organism'))
				#. "\n";

				$r{ $seq->accession_number() } =
						join(",", $feat->each_tag_value('organism'));
			}
		}
	}

	return %r;
}

1;
