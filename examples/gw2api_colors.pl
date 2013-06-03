#!perl -w

use strict;

use GW2API;

my $api = GW2API->new;


open(OMAIN, ">colors.csv") or die "unable to open file: $!\n";

print OMAIN "color_id|color_name|cloth|leather|metal\n";

my %colors = $api->colors;

foreach my $color_id (sort { $a <=> $b } keys %colors) {

  my $color = $colors{$color_id};

  my $color_name = $color->{name};
  my $cloth      = $color->{cloth}->{rgb};
  my $leather    = $color->{leather}->{rgb};
  my $metal      = $color->{metal}->{rgb};

  $cloth = join(",",@$cloth);
  $leather = join(",",@$leather);
  $metal = join(",",@$metal);

  print OMAIN "$color_id|$color_name|$cloth|$leather|$metal\n";
}

close (OMAIN);

exit;
