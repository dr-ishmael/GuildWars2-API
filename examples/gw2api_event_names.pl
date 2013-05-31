#!perl -w

use strict;

use GW2API;

my $api = GW2API->new;

open(OMAIN, ">event_names.csv") or die "unable to open file: $!\n";

print OMAIN "event_id|name\n";

my %events = $api->event_names();

foreach my $event_id (keys %events) {
  print OMAIN "$event_id|$events{$event_id}\n";
}

close (OMAIN);

exit;

