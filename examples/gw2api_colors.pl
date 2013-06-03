#!perl -w

use strict;

use GW2API;

my $api = GW2API->new;

open(OMAIN, ">colors.csv") or die "unable to open file: $!\n";

print OMAIN "color_id|color_name|default|cloth|leather|metal\n";

my %colors = $api->colors;

foreach my $color_id (keys %colors) {

  my $color = $colors{$color_id};

  my $color_name = $color->{name};
  my $default    = $color->{default};
  my $cloth      = $color->{cloth};
  my $leather    = $color->{leather};
  my $metal      = $color->{metal};

  print OMAIN "$color_id|$color_name|$default|$cloth|$leather|$metal\n";
}

close (OMAIN);

exit;
