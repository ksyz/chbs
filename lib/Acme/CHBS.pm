#!/usr/bin/perl
# 2015, Michal Ingeli <mi@v3.sk>, WTF-PL
#
# main part of _rand() and _to_float taken from Math::Random::Secure 
# (which is unavalable in enterprise linux 7), copying under terms 
# of Artistic license 2.0

package Acme::CHBS;

use strict;
use warnings;
use Data::Dumper;

use Crypt::Random::TESHA2 qw(irand);
use File::Slurp;

use constant DIVIDE_BY => 2**32;

sub check_word;
sub check_passphrase;
sub check_if_we_can;
sub mangle;
sub dice;
sub jar;
sub throw;
sub shuffle;
sub help;
sub _rand;
sub _to_float;

sub new {
	my $class = shift;
	my $self = {
		words => 5,
		symbols => 0,
		min_length => 2,
		max_length => 7,
		dict => '/usr/share/dict/words',
		capitalize_first => 0,
		passphrase_min_length => 1,
		passphrase_max_length => 32,
		separator => ' ',
		random_separator => 0,
		@_ 
	};

	$self = bless $self, $class;

	die("Impossible min/max barrier combination")
		unless ($self->check_if_we_can);

	my @lines = read_file($self->{dict});
	$self->{_lines} = [@lines];
	$self->{_n_lines} = $#lines;
	return $self;
};

sub _to_float {
	my ($integer, $limit) = @_;
	$limit = 1 if !$limit;
	return ($integer / DIVIDE_BY) * $limit;
}

sub _rand {
	my ($self) = @_;
	my $rand = irand();
	# as noted in Math::Random::Secure
	# We can't just use the mod operator because it will bias
	# our output. Search for "modulo bias" on the Internet for
	# details. This is slower than mod(), but does not have a bias,
	# as demonstrated by our uniform.t test.
	return int(_to_float($rand, $self->{_n_lines}));
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
		$word = $self->mangle($self->{_lines}[$self->_rand]);
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
	my $_sep = '';

	if ($self->{random_separator} && length $self->{separator} > 1) {
		my $retval = '';
		my @sep = split('', $self->{separator});

		for my $w (@parts) {
			$retval .= $w.$sep[rand $#sep];
		}
		return substr($retval, 0, (length($retval) - 1));
	}
	else {
		$_sep = substr($self->{separator}, 0, 1)
			if length $self->{separator} >= 1;

		return join($_sep, @parts);
	}
};

1;
