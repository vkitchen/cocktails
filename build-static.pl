#!/usr/bin/env perl

# TODO
# Generate ingredient list correctly using grammar rules from elm version

use strict;
use warnings;

use Data::Dumper;
use File::Basename;
use JSON;
use Text::Xslate;

my $api_dir = 'public/api/v1/drinks/';

my $out_dir = 'drinks/';
mkdir($out_dir) unless(-d $out_dir);

my @template = <DATA>;
my $template = join('', @template);

sub write_file {
    my $file = shift;
    my $data = shift;
    open my $fh, ">", $file or die("Could not open file. $!");
    print $fh $data;
    close $fh;
}

sub read_file {
	my $file = shift;
	local $/ = undef;
	open my $fh, "<", $file or die("Could not open file. $!");
	my $data = <$fh>;
	close $fh;
	return $data;
}

my $tx = Text::Xslate->new();
my @files = glob($api_dir.'*.json');

foreach my $file (@files) {
	my %json = %{decode_json(read_file($file))};
	my $html = $tx->render_string($template, \%json);
	my $out_file = substr(basename($file), 0, -length('.json')).'.html';
	write_file("$out_dir$out_file", $html);
}


__DATA__
<!DOCTYPE HTML>
<html>
<head>
	<meta charset="UTF-8">
	<link href="https://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet">
	<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
	<link rel="stylesheet" type="text/css" href="/cocktails/style.css">
	<title><: $name :> - Vaughan.Kitchen</title>
</head>
<body>
	<div class="page-frame">
		<nav class="masthead-container">
			<div class="logo-container">
				<a class="logo" href="/">VK</a>
			</div>
			<div>
				<form class="masthead-search">
					<button class="search-btn"><span class="material-icons search-btn-icon">search</span></button>
					<div class="masthead-search-terms">
						<input class="masthead-search-term" type="text">
					</div>
				</form>
			</div>
		</nav>
		<div class="content">
			<div class="content-inner">
				<div class="content-title">
					<h3><: $name :></h3>
				</div>
				<div class="drink">
					<div class="drink-img">
					: if $img[0] {
						<img src="/cocktails/img/250x250/<: uri_escape($img[0]) :>">
					: } else {
						<img src="/cocktails/img/Cocktail%20Glass.svg">
					: }
					</div>
					<div class="recipe">
						<p>Drinkware: <: $drinkware :></p>
						<p>Serve: <: $serve :></p>
						<p>Garnish: <: $garnish ? $garnish : 'None' :></p>
						<ul>
						: for $ingredients -> $ingredient {
							<li><: $ingredient.measure~' '~$ingredient.unit~' '~$ingredient.name :></li>
						: }
						</ul>
					<p><: $method :></p>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
</html>
