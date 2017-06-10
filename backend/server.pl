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

    if (any { index(lc %{$_}{'name'}, lc $query) != -1 } @{$drink{'ingredients'}}
            or index(lc $drink{'name'}, lc $query) != -1) {
        return \%drink;
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

sub index_drinks() {
    my @files = glob("public/drinks/*.json");

    my @drinks;
    foreach my $file (@files) {
        my $contents = read_file $file;
    	my %drink = %{decode_json $contents};
        push @drinks, \%drink;
    }

    return \@drinks;
}

## ROUTES ##

get '/' => sub {
    my $c = shift;
    $c->reply->static('index.html');
};

get '/drinks/*' => sub {
    my $c = shift;
    $c->reply->static('index.html');
};

get '/search/*' => sub {
    my $c = shift;
    $c->reply->static('index.html');
};


## API ##

get '/api/v1/drinks' => sub {
    my $c = shift;
    my $result = index_drinks;

    $c->render(json => $result);
};

get '/api/v1/drinks/:query' => sub {
    my $c = shift;
    my $query = $c->param('query');
    $c->reply->static("drinks/$query.json");
};

get '/api/v1/search' => sub {
    my $c = shift;
    my $result = index_drinks;

    $c->render(json => $result);
};

get '/api/v1/search/:query' => sub {
    my $c = shift;
    my $query = $c->param('query');
    my $result = filter $query;

    $c->render(json => $result);
};


app->start;
