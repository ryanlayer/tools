#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Basename;
use Statistics::Descriptive;
my $prog = basename($0);

sub comp {
	my ($a, $b) = @_;

	if ( ($a->[0] <= $b->[1]) and ($a->[1] >= $b->[0]) ) {
		return 0;
	} elsif ( ($a->[1] < $b->[0])  ) {
		return -1;
	} else {
		return 1;
	}
}

sub print_usage {
    warn <<"EOF";

USAGE
  $prog [options]

DESCRIPTION

OPTIONS
  -h            Print this help message
  --bed  file   Target bed file
  --con  file   Conservation bed file

EOF
	exit;
}

my $bed_file;
my $help = 0;
my $con_file;

GetOptions ("bed=s"	=> \$bed_file,		# string
			"con=s"	=> \$con_file,		# string
			"h"			=> \$help) or print_usage(); 

print_usage() if $help;

print_usage() if (not($bed_file) and
				  not($con_file));

open(FILE, $bed_file) or die "Could not open $bed_file.\n$!";

my $bed;

while (my $l = <FILE>) {
	chomp($l);
	if ($l =~ /^chr/) {
		my @a = split(/\t/, $l);
		my @i = ($a[1], $a[2], $a[3]);

		if (not defined($bed->{$a[0]})) {
			my @b;
			$bed->{$a[0]} = \@b;
		}

		push(@{$bed->{$a[0]}}, \@i);
	}
}

my %chr_ptr;

foreach my $chr (keys %{$bed}) {
	my @t = sort {$a->[0]<=>$b->[0]} @{$bed->{$chr}};
	$bed->{$chr} = \@t;
	$chr_ptr{$chr} = 0;
}

#foreach my $chr (keys %{$bed}) {
#	foreach my $i (@{$bed->{$chr}}) {
#		print "$chr\t" . $i->[0] . "\t" . $i->[1] . "\n";
#	}
#}

close(FILE);

open(FILE, $con_file) or die "Could not open $con_file.\n$!";

while (my $l = <FILE>) {
	chomp($l);
	if ($l =~ /^chr/) {
		my @a = split(/\t/, $l);
		my $chr = $a[0];
		my @i = ($a[1], $a[2]);

		while ( ( ($chr_ptr{$chr} + 1) < @{$bed->{$chr}} ) and
				( comp($bed->{$chr}[$chr_ptr{$chr}], \@i) == -1) ) {
			$chr_ptr{$chr} = $chr_ptr{$chr} + 1;
		}

		if (comp($bed->{$chr}[$chr_ptr{$chr}], \@i) == 0) {
			print
				$chr . "\t" .
				#$bed->{$chr}[$chr_ptr{$chr}]->[0] . "," .
				#$bed->{$chr}[$chr_ptr{$chr}]->[1] . "\t" .
				$a[1] . "\t" .
				$a[2] .  "\t" . 
				$bed->{$chr}[$chr_ptr{$chr}]->[2] . ";" .
				$a[3] .  "\n" ;
		} 
	}
}
