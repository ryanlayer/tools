#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Basename;
use Text::WagnerFischer qw(distance);
my $prog = basename($0);

sub print_usage {
    warn <<"EOF";

USAGE
  $prog [options] <string A> <string B>

DESCRIPTION
  Give the Wagner-Fischer edit distance between two strings

OPTIONS
  -h            Print this help message

EOF
	exit;
}

my $help;

GetOptions ( "h" => \$help) or print_usage(); 

print_usage() if $help;

print_usage() if (@ARGV != 2);

print distance($ARGV[0], $ARGV[1]) . "\n";
