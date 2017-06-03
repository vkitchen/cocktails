#!/usr/bin/env perl
use Mojolicious::Lite;
use Mojo::Log;

my $log = Mojo::Log->new;

get '/' => sub {
    my $c = shift;
    $c->reply->static('index.html');
};

app->start;
