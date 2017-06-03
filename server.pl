#!/usr/bin/env perl
use v5.20;
use strict;
use warnings;
use feature qw(signatures);

use Mojolicious::Lite;
use Mojo::Log;
use Data::Dumper;
use File::Slurp;
use JSON;
use List::Util qw(any);

no warnings qw(experimental::signatures);


my $log = Mojo::Log->new;

sub parse_file($file, $query) {
    my $contents = read_file $file;
    my %drink = %{decode_json $contents};

    if (any { index(lc %{$_}{'name'}, lc $query) != -1 } @{$drink{'ingredients'}}) {
        return { file => $file, name => $drink{'name'} }
    }
    return undef;
}

sub filter($query) {
    my @files = glob("public/drinks/*.json");

    my @drinks;
    foreach my $file (@files) {
        my $result = parse_file($file, $query);
        if (defined $result) {
    	   push @drinks, $result;
       }
    }

    return \@drinks;
}

get '/' => sub {
    my $c = shift;
    $c->reply->static('index.html');
};

get '/filter/:query' => sub {
    my $c = shift;
    my $query = $c->param('query');
    my $result = filter $query;

    $c->render(json => $result);
};


app->start;
