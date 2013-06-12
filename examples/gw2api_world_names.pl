#!perl -w

use Modern::Perl '2012';

use GuildWars2::API;

my $api = GuildWars2::API->new;

open(OMAIN, ">world_names.csv") or die "unable to open file: $!\n";

say OMAIN "world_id|name";

my %worlds = $api->world_names();

foreach my $world_id (keys %worlds) {
  say OMAIN "$world_id|$worlds{$world_id}";
}

close (OMAIN);

exit;

