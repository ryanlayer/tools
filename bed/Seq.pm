package Seq;
use Data::Dumper;

sub min {
	my ($a, $b) = @_;
	if ($a < $b) {
		return $a;
	} else {
		return $b;
	}
}

sub max {
	my ($a, $b) = @_;
	if ($a > $b) {
		return $a;
	} else {
		return $b;
	}
}

sub s {
	my ($I) = @_;
	return "<$I->{'s'}, $I->{'e'}, $I->{'n'}>";
}

sub seq_intersection {
	my ($_A, $_B, $s, $e) = @_;

	my @A = sort {$a->{$s} <=> $b->{$s}} @{$_A};
	my @B = sort {$a->{$s} <=> $b->{$s}} @{$_B};

	my @c_A;
	my @c_B;

	my $a_c = 0;
	my $b_c = 0;

	my $R;

	if ( ($#A == -1) || ($#B == -1) ) {
		return $R;
	}
	
	my $r = 0;
	# at each step we will either add something, or remove something from the
	# current set
	
	while( ($a_c <= $#A) || ($b_c < $#B) ) {
		my $c_val;

		if ($a_c > $#A) {
			#print "pick B\t";
			$c_val = $B[$b_c]->{$s};
		} elsif ($b_c > $#B) {
			#print "pick A\t";
			$c_val = $A[$a_c]->{$s};
		} else {
			#print "pick min\t";
			$c_val = min($A[$a_c]->{$s}, $B[$b_c]->{$s});
		}

		if (!($A[$#A]->{$s}) || !($B[$#B]->{$s})) {
			die "Something bad just happened:  array size extended\n";
		}
		#print Dumper(@c_A);
		#print Dumper(@c_B);

		#see who needs leave 
		#@c_A = sort {$b->{$e} <=> $a->{$e}} @c_A;
		while ( ($#c_A > -1) && ($c_A[$#c_A]->{$e} < $c_val) )  { 
			my $p = pop(@c_A); 
			#print "out A : \n" . Dumper($p);
		}

		#@c_B = sort {$b->{$e} <=> $a->{$e}} @c_B;

		while ( ($#c_B > -1) && ($c_B[$#c_B]->{$e} < $c_val) ) {
			my $p = pop(@c_B);
			#print "out B : \n" . Dumper($p);
		}

		#see who needs to be added
		if( ($a_c <= $#A) && ($A[$a_c]->{$s} == $c_val) ) {
		#if( ($A[$a_c]->{$s} == $c_val) && $c_val) {
			#print "in A : \n" . Dumper($A[$a_c]);
			push (@c_A, $A[$a_c]);
			foreach $b (@c_B) {
				$R->{$r}{0} = $A[$a_c]; 
				$R->{$r}{1} = $b;
				$r++;
				#push(@R,  ($A[$a_c], $b));
			}
			@c_A = sort {$b->{$e} <=> $a->{$e}} @c_A;
			$a_c++;
		}

		if( ($b_c <= $#B) && ($B[$b_c]->{$s} == $c_val) ) {
		#if( ($B[$b_c]->{$s} == $c_val) && $c_val) {
			#print "in B : \n" . Dumper($B[$b_c]);
			push (@c_B, $B[$b_c]);
			foreach $a (@c_A) {
				$R->{$r}{0} = $a;
				$R->{$r}{1} = $B[$b_c];
				$r++;
				#push(@R,  ($a, $B[$b_c]));
			}
			@c_B = sort {$b->{$e} <=> $a->{$e}} @c_B;
			$b_c++;
		}
	}

	return $R;
}
1;
