#!/usr/bin/perl -w
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
	-host => 'ensembldb.ensembl.org',
	-user => 'anonymous'
);

my $variation_adaptor = $registry->get_adaptor(
	'human',	# species
	'variation',	# database
	'variation'	# object type
);

my $variation = $variation_adaptor->fetch_by_name('rs1333049');
