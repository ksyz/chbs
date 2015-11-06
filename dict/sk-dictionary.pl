#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Unicode::Normalize;

my $limit = 8192;
my $min = 3;
my $max = 6;
my %words = ();

for (@ARGV) {
	next 
		unless -f $_;
	open(my $fh, "<:encoding(UTF-8)", $_);

	while (<$fh>) {
		last 
			if $limit < 0;

		my @line = split /\s+/, $_;

		next if (length($line[0]) < $min || length($line[0]) > $max);
		my $word = lc($line[0]);
		my $decomposed = NFKD( $word );
		$decomposed =~ s/\p{NonspacingMark}//g;

		# unaccented dupes
		next
			if exists $words{$decomposed};
		$words{$decomposed} = 1;
		$limit--;
	}
}

print join("\n", sort keys %words);
