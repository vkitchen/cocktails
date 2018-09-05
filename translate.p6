#!/usr/bin/env perl6

use v6;

use JSON::Fast;

# renderIngredient ingredient =
#   case (ingredient.measure, ingredient.unit) of
#     ("0", "splash") ->
#       ingredient.name
# 
#     ("1", "splash") ->
#       "A splash of " ++ ingredient.name
# 
#     (_, "splash") ->
#       ingredient.measure ++ " splashes " ++ ingredient.name
# 
#     ("0", "dash") ->
#       ingredient.name
# 
#     ("1", "dash") ->
#       "A dash of " ++ ingredient.name
# 
#     (_, "dash") ->
#       ingredient.measure ++ " dashes " ++ ingredient.name
# 
#     ("0", "drop") ->
#       ingredient.name
# 
#     ("1", "drop") ->
#       "A drop of " ++ ingredient.name
# 
#     (_, "drop") ->
#       ingredient.measure ++ " drops " ++ ingredient.name
# 
#     (_, "top") ->
#       "Top with " ++ ingredient.name
# 
#     ("1", "taste") ->
#       ingredient.name ++ " to taste"
# 
#     ("0", "none") ->
#       ingredient.name
# 
#     ("1", "none") ->
#       "A " ++ ingredient.name
# 
#     (_, "none") ->
#       ingredient.measure ++ " " ++ ingredient.name
# 
#     (_, _) ->
#       ingredient.measure ++ " " ++ ingredient.unit ++ " " ++ ingredient.name

sub renderIngredient (%ingredient) {
  my ($measure, $unit, $name) = %ingredient<measure>, %ingredient<unit>, %ingredient<name>;
  if $measure eq '0' {
    return $name
  } elsif $measure eq '1' && $unit eq 'part' {
    return "1 part $name"
  } elsif $unit eq 'part' {
    return "$measure parts $name"
  } elsif $measure eq '1' && $unit eq 'splash' {
    return "A splash of $name"
  } elsif $unit eq 'splash' {
    return "$measure splashes $name"
  } elsif $measure eq '1' && $unit eq 'dash' {
    return "A dash of $name"
  } elsif $unit eq 'dash' {
    return "$measure dashes $name"
  } elsif $measure eq '1' && $unit eq 'drop' {
    return "A drop of $name"
  } elsif $unit eq 'drop' {
    return "$measure drops $name"
  } elsif $unit eq 'top' {
    return "Top with $name"
  } elsif $measure eq '1' && $unit eq 'none' {
    return "A $name"
  } elsif $unit eq 'none' {
    return "$measure $name"
  } else {
    return "$measure $unit $name";
  }
}

sub translate(%json) {
  my $out = "";
  $out ~= "define(`NAME', {%json<name>})";
  $out ~= "\ndefine(`IMG', {%json<img>})" if %json<img>;
  $out ~= "\ndefine(`SERVE', {%json<serve>})" if %json<serve>;
  $out ~= "\ndefine(`GARNISH', {%json<garnish>})" if %json<garnish>;
  $out ~= "\ndefine(`DRINKWARE', {%json<drinkware>})" if %json<drinkware>;
  $out ~= "\ndefine(`INGREDIENTS',";
#  my @ingredients = %json<ingredients>;
  for %json<ingredients> -> @ingredients {
    for @ingredients -> $ingredient {
      my %ingredient = $ingredient;
      $out ~= "\n<li>" ~ renderIngredient(%ingredient) ~ '</li>';
    }
  }
  $out ~= "\n)";
  $out ~= "\ndefine(`METHOD', `{%json<method>}')" if %json<method>;
  $out ~= "\n\ninclude(`views/drink.html')";
  $out ~= "\ninculed(`views/layout.html')";
  return $out
}

sub MAIN($file) {
  my %json = from-json slurp $file;
  say translate %json;
}
