#!perl -w

use Modern::Perl '2012';

use GuildWars2::API;
use GuildWars2::GameLink qw/decode_gl encode_gl/;

my $api = GuildWars2::API->new;

my @output;

say "\nDecode";

@output = decode_gl('[&AdsnAAA=]');
say "$output[0] $output[1] - 1g 2s 3c";

@output = decode_gl('[&AgH1WQAA]');
say "$output[0] $output[1] $output[2] - Copper Harvesting Sickle";

@output = decode_gl('[&AyAnAAA=]');
say "$output[0] $output[1] - Do you need assistance?";

@output = decode_gl('[&BEgAAAA=]');
say "$output[0] $output[1] - Desider Atum Waypoint";

@output = decode_gl('[&BnMVAAA=]');
say "$output[0] $output[1] - Fireball";

@output = decode_gl('[&CPIDAAA=]');
say "$output[0] $output[1] - Opening Strike";

@output = decode_gl('[&CQcAAAA=]');
say "$output[0] $output[1] - Bolt of Cotton";

say "Build: " . $api->build;

__END__

my $output;

say "\nEncode";

$output = encode_gl(1, 10203);
say "$output - 1g 2s 3c";

$output = encode_gl(2, 23029);
say "$output - Copper Harvesting Sickle";

my %item = $api->item_details(23029);
$output = encode_gl(\%item);
say "$output - Copper Harvesting Sickle (item_details)";

$output = encode_gl(3, 10016);
say "$output - Do you need assistance?";

$output = encode_gl(4, 72);
say "$output - Desider Atum Waypoint";

$output = encode_gl(6, 5491);
say "$output - Fireball";

$output = encode_gl('skill', 5491);
say "$output - Fireball ('skill')";

$output = encode_gl(8, 1010);
say "$output - Opening Strike";

$output = encode_gl(9, 7);
say "$output - Bolt of Cotton";

my %recipe = $api->recipe_details(7);
$output = encode_gl(\%recipe);
say "$output - Bolt of Cotton (recipe_details)";


exit;
