#!/usr/bin/perl
use warnings;
use strict;

my $first;
foreach my $a (@ARGV) {
	if (! ( $a =~ /chr/ ) ) {
		if (!$first) {
			$first = $a;
		} else {
			my $len = $a - $first;
			print $len . "\n";
		}
	} 
}
