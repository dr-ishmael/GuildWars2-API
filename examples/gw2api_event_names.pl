#!perl -w

use Modern::Perl '2012';

use GuildWars2::API;

my $api = GuildWars2::API->new;

open(OMAIN, ">event_names.csv") or die "unable to open file: $!\n";

say OMAIN "event_id|name";

my %events = $api->event_names();

foreach my $event_id (keys %events) {
  say OMAIN "$event_id|$events{$event_id}";
}

close (OMAIN);

exit;

