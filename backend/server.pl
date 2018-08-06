#!/usr/bin/env perl
use v5.16;
use strict;
use warnings;

use Mojolicious::Lite;
use Mojo::Log;
use Data::Dumper;
use File::Slurp;
use JSON;

my $log = Mojo::Log->new;

sub parse_file {
    my $file = shift;
    my $query = shift;
    my $contents = read_file $file;
    my %drink = %{decode_json $contents};

    if (index(lc $drink{'name'}, lc $query) != -1) {
        return \%drink;
    }

    for my $ingredient (@{$drink{'ingredients'}}) {
        my %ingredient = %{$ingredient};
        if (index(lc $ingredient{'name'}, lc $query) != -1) {
            return \%drink;
        }
    }

    return undef;
}

sub filter {
    my $query = shift;
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

sub index_drinks {
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
