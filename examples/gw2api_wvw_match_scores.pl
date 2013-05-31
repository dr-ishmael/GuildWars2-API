#!perl -w

use strict;

use GW2API;

my $api = GW2API->new;

open(OMAIN, ">wvw_match_details.csv") or die "unable to open file: $!\n";

print OMAIN "match_id|red_world_id|red_total_score|blue_world_id|blue_total_score|green_world_id|green_total_score\n";

foreach my $match ($api->wvw_matches) {
  
  my $match_id       = $match->{wvw_match_id};
  my $red_world_id   = $match->{red_world_id};
  my $blue_world_id  = $match->{blue_world_id};
  my $green_world_id = $match->{green_world_id};
  
  my %match_details = $api->wvw_match_details($match_id);
  
  my $scores = $match_details{scores};
  
  my $red_total_score   = $scores->[0];
  my $blue_total_score  = $scores->[1];
  my $green_total_score = $scores->[2];
  
  print OMAIN "$match_id|$red_world_id|$red_total_score|$blue_world_id|$blue_total_score|$green_world_id|$green_total_score\n";
  
}

close (OMAIN);

exit;

