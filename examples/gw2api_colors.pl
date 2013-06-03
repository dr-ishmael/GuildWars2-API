#!perl -w

use strict;

use GW2API;

my $api = GW2API->new;

$api->color_format("rgbhex");


open(OMAIN, ">colors.csv") or die "unable to open file: $!\n";

print OMAIN "xcolor_id|color_name|default|cloth|leather|metal\n";

my %colors = $api->colors;

foreach my $color_id (sort { $a <=> $b } keys %colors) {

  my $color = $colors{$color_id};

  my $color_name = $color->{name};
  my $default    = $color->{default};
  my $cloth      = $color->{cloth};
  my $leather    = $color->{leather};
  my $metal      = $color->{metal};

  #$default = join(",",@$default);
  #$cloth = join(",",@$cloth);
  #$leather = join(",",@$leather);
  #$metal = join(",",@$metal);

  print OMAIN "$color_id|$color_name|$default|$cloth|$leather|$metal\n";
}

close (OMAIN);

exit;
