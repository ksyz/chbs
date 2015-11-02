#!/usr/bin/perl
# 2015, Michal Ingeli <mi@v3.sk>, WTF-PL
package Acme::CHBS;

use strict;
use warnings;
use Data::Dumper;

use Math::Random::Secure qw(irand);
use File::Slurp;

sub check_word;
sub check_passphrase;
sub check_if_we_can;
sub mangle;
sub dice;
sub jar;
sub throw;
sub shuffle;
sub help;

sub new {
	my $class = shift;
	my $self = {
		words => 6,
		symbols => 0,
		min_length => 4,
		max_length => 8,
		dict => '/usr/share/dict/words',
		capitalize_first => 0,
		passphrase_min_length => 1,
		passphrase_max_length => 32,
		@_ 
	};

	$self = bless $self, $class;

	die("Impossible min/max barrier combination")
		unless ($self->check_if_we_can);

	my @lines = read_file($self->{dict});
	$self->{_lines} = [@lines];
	return $self;
};

sub jar {
	my $self = shift;
	my @parts;
	for (my $i = $self->{words}; $i; $i--) {
		push @parts, $self->dice;
	};
	return @parts;
};

sub dice {
	my $self = shift;
	my $word;
	while (1) {
		$word = $self->mangle($self->{_lines}[irand($#{$self->{_lines}})]);
		next 
			unless $self->check_word($word);
		return $word;
	}
};

sub mangle {
	my ($self, $word) = @_;
	$word = lc $word;
	chomp $word;
	$word = ucfirst $word
		if ($self->{capitalize_first});
	return $word;
};
	
sub check_word {
	my ($self, $word) = @_;
	return undef
		if (length $word < $self->{min_length});
	return undef
		if (length $word > $self->{max_length});
	return undef
		if (!$self->{symbols} && $word !~ /^[a-z]+$/i);
	return 1;
};

sub check_passphrase {
	my ($self, $passphrase) = @_;
	return undef
		if (defined $self->{passphrase_min_length} && length $passphrase < $self->{passphrase_min_length});
	return undef
		if (defined $self->{passphrase_max_length} && length $passphrase > $self->{passphrase_max_length});
	return 1;
};

sub check_if_we_can {
	my ($self) = @_;
	# separators
	my $sep_chars = $self->{words} - 1;
	# min length
	my $min_chars = $sep_chars + (defined $self->{min_length} ? $self->{words} * $self->{min_length} : 0);
	my $max_chars = $sep_chars + (defined $self->{max_length} ? $self->{words} * $self->{max_length} : 0);

	return undef
		if (defined $self->{passphrase_min_length} && $max_chars < $self->{passphrase_min_length});
	return undef
		if (defined $self->{passphrase_max_length} && $min_chars > $self->{passphrase_max_length});
	return 1;

};
sub shuffle {
	my ($self) = @_;
	while (1) {
		my $try = $self->throw($self->jar);
		next 
			unless $self->check_passphrase($try);
		return $try;
	}
};

sub throw {
	my ($self, @parts) = @_;
	return join(' ', @parts);
};

1;
