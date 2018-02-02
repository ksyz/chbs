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
sub char_to_leet;

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
		leet_speak => 0,
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

	my $retval = '';

	if ($self->{random_separator} && length $self->{separator} > 1) {
		my @sep = split('', $self->{separator});

		for my $w (@parts) {
			$retval .= $w.$sep[int(rand($#sep + 1))];
		}
		$retval = substr($retval, 0, (length($retval) - 1));
	}
	else {
		$_sep = substr($self->{separator}, 0, 1)
			if length $self->{separator} >= 1;

		$retval = join($_sep, @parts);
	}

	if (defined $self->{leet_speak} && $self->{leet_speak} > 0 && $self->check_valit_for_leet($retval)) {
		my @indexes = ();
		my $i;
		for (my $i = length $retval; $i > 0; $i--) {
			my $char = substr($retval, $i, 1);
			push @indexes, $i
				if (index($self->{_leet_valid_r}, $char) != -1);
		}
		for (my $i = 0; $i < $self->{leet_speak} && 0 < scalar(@indexes); $i++) {
			my $index = int(rand(scalar(@indexes)));
			my $replace = $indexes[$index];
			my $new_val = substr($retval, 0, $replace);

			$new_val .= $self->char_to_leet(substr($retval, $replace, 1));
			$new_val .= substr($retval, $replace+1, length($retval) - ( $replace + 1))
				if ($replace + 1 < length($retval));
			splice @indexes, $index, 1;
			$retval = $new_val;
		}
	}

	return $retval;
};

my $leet_table = {
	0 => 'OQDo',
	1 => 'ILil',
	2 => 'Zz',
	3 => 'Ee',
	4 => 'HAa',
	5 => 'Ss',
	6 => 'Ggb',
	7 => 'TtjJ',
	8 => 'B',
	9 => 'Pq',
};

sub check_valit_for_leet {
	my ($self, $passphrase) = @_;
	unless ($self->{_leet_valid_qr}) {
		my $_leet_valid_r = join('', values %$leet_table);
		$self->{_leet_valid_r} = $_leet_valid_r;
		$self->{_leet_valid_qr} = qr/[$_leet_valid_r]/;
	}

	return 1
		if $passphrase =~ $self->{_leet_valid_qr};

	return undef;
};

sub char_to_leet {
	my ($self, $char) = @_;

	my $valid_chars = join('', values %$leet_table);

	return undef
		if (index($valid_chars, $char) == -1);

	for (keys %$leet_table) {
		next 
			if (index($leet_table->{$_}, $char) == -1);

		return $_;
	}

	return undef;
}

1;
