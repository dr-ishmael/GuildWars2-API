#!perl -w

use Modern::Perl '2012';

use GuildWars2::API;

my $api = GuildWars2::API->new;

my $event_id    = '67C17850-AC4C-4258-A03F-373021ECD10B';
my $event_name  = 'Collect fur samples for Linnea.';

my $world_id    = 1017;

# Single event, single world
print "Checking status of event '$event_name' on Tarnished Coast: ";

my $state = $api->event_state($event_id, 1017);

say $state;

# Single event, all worlds
say "Checking status of event '$event_name' on all worlds: ";

my %wstates = $api->event_state_by_world($event_id);
my %worlds = $api->world_names;

for my $world_id (keys %wstates) {
  say sprintf "\t%-20s\t%s", $worlds{$world_id}, $wstates{$world_id};
}


# All events in map, single world

say "Checking status of all events in Metrica Province on Tarnished Coast:";

my %mstates = $api->event_states_in_map(35, 1017);
my %events = $api->event_names;

for my $event_id (keys %mstates) {
  say sprintf "\t%-15s\t%s", $mstates{$event_id}, $events{$event_id};
}

exit;

