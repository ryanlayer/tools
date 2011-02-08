#!/usr/bin/perl
use Data::Dumper;
my @files;
my @names;

if ($#ARGV < 2) {
	print "usage:\tcluser.pl <BED file 1> <Lable 1> ... <BED file N> " .
		"<Lable N>\n";
	exit;
}

while (my $file_name = shift) {
	push(@files, $file_name);
	push(@names, shift);
}

my %chroms;

for(my $i = 0; $i <= $#files; $i++) {
	open(FILE, $files[$i]);
	while(<FILE>) {
		if (/^(chr[^\t]*)\t(\d+)\t(\d+)\t(\S+).*/) {
			my $s;
			$s->{'n'} = $names[$i];
			$s->{'t'} = 's';
			$s->{'o'} = $2;
			$s->{'c'} = $4;
			my $e;
			$e->{'n'} = $names[$i];
			$e->{'t'} = 'e';
			$e->{'o'} = $3;
			$e->{'c'} = $4;

			#if ( !exists $chroms{$1} ) {
			#my @chrm;
			#$chroms{$1} = @chrm;
			#}

			push(@{$chroms{$1}}, $s);
			push(@{$chroms{$1}}, $e);
		}
	}
	close(FILE);
}

foreach my $chrm (keys %chroms) {
	#my @chrm_array = $chroms{$chrm};
	my @chrm_array = sort {$a->{'o'} <=> $b->{'o'}} @{$chroms{$chrm}};
	my %curr;
	my $last_start = 0;
	my $dir = 0;
	foreach my $a (@chrm_array) {
#		if ($a->{'t'} eq 's') {
#			$last_start = $a->{'o'};
#			$curr{$a->{'n'}} = 1;
#			$dir = 1;
#		} elsif ($a->{'t'} eq 'e') {
#			if ($dir == 1) {
#				my $cluster = join(',', sort keys %curr);
#				print "$chrm\t$last_start\t" . $a->{'o'} . "\t" . $cluster . "\n";
#			}
#			$dir = -1;
#			delete($curr{$a->{'n'}});
#		}

		if ($a->{'t'} eq 's') {
			$last_start = $a->{'o'};
			#$curr{$a->{'n'}} = 1;
			$curr{$a->{'n'}} = $a;
			$dir = 1;
		} elsif ($a->{'t'} eq 'e') {
			if ($dir == 1) {
				my @cluster_a;
				foreach my $c (sort keys %curr) {
					push(@cluster_a, $curr{$c}->{'c'});
				}
				my $cluster = join(';', @cluster_a);

				print "$chrm\t$last_start\t" . $a->{'o'} . "\t" . $cluster . "\n";
			}
			$dir = -1;
			delete($curr{$a->{'n'}});
		}

	}
}
