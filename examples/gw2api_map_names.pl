#!perl -w

use Modern::Perl '2012';

use GuildWars2::API;

my $api = GuildWars2::API->new;

open(OMAIN, ">map_names.csv") or die "unable to open file: $!\n";

say OMAIN "map_id|name";

my %maps = $api->map_names;

foreach my $map_id (keys %maps) {
  say OMAIN "$map_id|$maps{$map_id}";
}

close (OMAIN);

exit;

