#!perl -w

use strict;

use GW2API;

my $api = GW2API->new;

open(OMAIN, ">objective_names.csv") or die "unable to open file: $!\n";

print OMAIN "objective_id|name\n";

my %objectives = $api->objective_names();

foreach my $objective_id (keys %objectives) {
  print OMAIN "$objective_id|$objectives{$objective_id}\n";
}

close (OMAIN);

exit;

