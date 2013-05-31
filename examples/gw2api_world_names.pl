#!perl -w

use strict;

use GW2API;

my $api = GW2API->new;

open(OMAIN, ">world_names.csv") or die "unable to open file: $!\n";

print OMAIN "world_id|name\n";

my %worlds = $api->world_names();

foreach my $world_id (keys %worlds) {
  print OMAIN "$world_id|$worlds{$world_id}\n";
}

close (OMAIN);

exit;

