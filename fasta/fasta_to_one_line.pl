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
  Make sequences one line

OPTIONS
  -h            Print this help message
  --file  name   File we want use

EOF
	exit;
}

my $file;
my $help = 0;

GetOptions ("file=s"	=> \$file,		# string
			"h"			=> \$help) or print_usage(); 

print_usage() if $help;

print_usage() if not($file);

open(FILE, $file) or die "Could not open $file.\n$!";

my $name = <FILE>;
chomp($name);
my $seq;
while (my $l = <FILE>) {
	chomp($l);
	if ($l =~ /^>/) {
		print "$name\n$seq\n";
		$name = $l;
		$seq="";
	} else {
		$seq = $seq . $l;
	}
}
close(FILE);
