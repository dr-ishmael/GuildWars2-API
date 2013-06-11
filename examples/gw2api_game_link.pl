#!perl -w

use strict;

use GW2API;

my $api = GW2API->new;

my $output;
my @output;

print "\nEncode\n";

$output = $api->encode_game_link(1, 10203);
print "$output - 1g 2s 3c\n";

$output = $api->encode_game_link(2, 23029);
print "$output - Copper Harvesting Sickle\n";

my %item = $api->item_details(23029);
$output = $api->encode_game_link(\%item);
print "$output - Copper Harvesting Sickle (item_details)\n";

$output = $api->encode_game_link(3, 10016);
print "$output - Do you need assistance?\n";

$output = $api->encode_game_link(4, 72);
print "$output - Desider Atum Waypoint\n";

$output = $api->encode_game_link(6, 5491);
print "$output - Fireball\n";

$output = $api->encode_game_link('skill', 5491);
print "$output - Fireball ('skill')\n";

$output = $api->encode_game_link(8, 1010);
print "$output - Opening Strike\n";

$output = $api->encode_game_link(9, 7);
print "$output - Bolt of Cotton\n";

my %recipe = $api->recipe_details(7);
$output = $api->encode_game_link(\%recipe);
print "$output - Bolt of Cotton (recipe_details)\n";



print "\nDecode\n";

@output = $api->decode_game_link('[&AdsnAAA=]');
print "$output[0] $output[1] - 1g 2s 3c\n";

@output = $api->decode_game_link('[&AgH1WQAA]');
print "$output[0] $output[1] $output[2] - Copper Harvesting Sickle\n";

@output = $api->decode_game_link('[&AyAnAAA=]');
print "$output[0] $output[1] - Do you need assistance?\n";

@output = $api->decode_game_link('[&BEgAAAA=]');
print "$output[0] $output[1] - Desider Atum Waypoint\n";

@output = $api->decode_game_link('[&BnMVAAA=]');
print "$output[0] $output[1] - Fireball\n";

@output = $api->decode_game_link('[&CPIDAAA=]');
print "$output[0] $output[1] - Opening Strike\n";

@output = $api->decode_game_link('[&CQcAAAA=]');
print "$output[0] $output[1] - Bolt of Cotton\n";


exit;


