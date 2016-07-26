#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use Data::Dumper;
use Unicode::Normalize;

my $stats = {};

binmode STDOUT, ':utf8';

sub flat {
	my $decomposed = NFKD( shift );
	$decomposed =~ s/\p{NonspacingMark}//g;
	return $decomposed;
};


sub read_dump {
	my ($filename, $stats) = @_;
	open(my $fh, '<', $filename);
	binmode $fh, ':utf8';

	while (<$fh>) {
		next 
			if /^<doc id=.*>$/ || /^<\/doc>/ || /^\s*$/;
		my $line = flat($_);
		while (/\b([a-z]{3,6})\b/gim) {
			$stats->{lc($1)}++;
		}
	}
	close $fh;
};

opendir(my $dh, '.');
for my $datadir (readdir($dh)) {
	next if $datadir =~ /^\.{1,2}$/ || !-d $datadir;

	# $stats = {};
	opendir(my $ddh, $datadir);
	for my $datafile (readdir($ddh)) {
		next unless $datafile =~ /^wiki_\d\d$/;
		print STDERR "$datadir/$datafile\n";
		read_dump("$datadir/$datafile", $stats);
	}
}

my $i = 8192;
for my $key ( reverse sort { $stats->{$a} <=> $stats->{$b} } keys %$stats) {
	print "$stats->{$key},$key\n";
	last if --$i == 0;
}
