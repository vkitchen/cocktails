#!/usr/bin/env perl

use v5.20;
use strict;
use warnings;
use feature qw(signatures);
no warnings qw(experimental::signatures);

use Data::Dumper;
use File::Slurp;
use JSON;

my @files = glob("drinks/*.json");

sub parse_file($file) {
	my $contents = read_file $file;
	print "Processing: $file\n";
	my %drink = %{decode_json $contents};

	return { file => $file, name => $drink{'name'} }
}

my @drinks;
foreach my $file (@files) {
	push @drinks, parse_file $file;
	write_file 'index.json', encode_json \@drinks;
}
