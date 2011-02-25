#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Basename;
use XML::Parser::PerlSAX;

my $prog = basename($0);
my $path_to = dirname($0);



sub print_usage {
    warn <<"EOF";

USAGE
  $prog [options]

DESCRIPTION
	Parse a blastn xml file

OPTIONS
  -h            Print this help message
  --file  name   File we want use

EOF
}

my $file;
my $help = 0;

GetOptions ("file=s"	=> \$file,		# string
			"h"			=> \$help) or print_usage(); 

print_usage() if $help;

print_usage() if not($file);

use lib "/home/rl6sf/src/tools/blast/";


use blast_xml_handler;

my $my_handler = blast_xml_handler->new;
my $parser = XML::Parser::PerlSAX->new( Handler => $my_handler );

$parser->parse(Source => { SystemId => $file });


