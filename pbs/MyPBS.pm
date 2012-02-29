
package MyPBS;
use strict;
use Getopt::Long;
use File::Basename;
use Data::Dumper;


sub get_files {

	my ($dir,$p_yes_sfxs,$p_no_sfxs,$max) = @_;

	my @all_sfx = (@{$p_yes_sfxs}, @{$p_no_sfxs});

	my @r_files;
	my $files;

	foreach my $yes_sfx ( @{ $p_yes_sfxs } ) {
		$files = $files . `find $dir -type f -name "*$yes_sfx"`;
	}


	my $seen;

	foreach my $file (split(/\n/,$files)) {
		if ($max < 1) {
			last;
		}
		my ($name,$path,$suffix) = fileparse($file,@{ $p_yes_sfxs });
		foreach my $no_sfx ( @{ $p_no_sfxs } ) {
			#print "find $path -type f -name \"*$no_sfx\"\n";
			if  (not (`find $path -type f -name "*$no_sfx"`)) {
				#print "n\n";
					push(@r_files, "$path/$name$suffix");
					$max--;
			} else {
				#print "y\n";
			}
		}
	}
	return @r_files;
}

1;
