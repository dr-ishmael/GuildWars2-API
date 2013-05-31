#!perl -w

use strict;

use GW2API;

my $api = GW2API->new;

open(OMAIN, ">map_names.csv") or die "unable to open file: $!\n";

print OMAIN "map_id|name\n";

my %maps = $api->map_names;

foreach my $map_id (keys %maps) {
  print OMAIN "$map_id|$maps{$map_id}\n";
}

close (OMAIN);

exit;

