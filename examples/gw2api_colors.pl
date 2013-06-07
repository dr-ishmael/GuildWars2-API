#!perl -w

use strict;

use GW2API;

my $api = GW2API->new;


open(OMAIN, ">colors.csv") or die "unable to open file: $!\n";

#print OMAIN "color_id|color_name|cloth|cloth-calc|leather|leather-calc|metal|metal-calc\n";
print OMAIN "color_id|color_name|cloth|leather|metal\n";

my %colors = $api->colors;

foreach my $color_id (sort { $a <=> $b } keys %colors) {

  my $color = $colors{$color_id};

  my $color_name = $color->{name};
  my $cloth      = $color->{cloth}->{rgb};
  my $leather    = $color->{leather}->{rgb};
  my $metal      = $color->{metal}->{rgb};

  $cloth   = $api->anetcolor->rgb2hex(@$cloth);
  $leather = $api->anetcolor->rgb2hex(@$leather);
  $metal   = $api->anetcolor->rgb2hex(@$metal);

  print OMAIN "$color_id|$color_name|$cloth|$leather|$metal\n";

#  my @cloth_matrix   = $api->anetcolor->colorShiftMatrix($color->{cloth});
#  my @leather_matrix = $api->anetcolor->colorShiftMatrix($color->{leather});
#  my @metal_matrix   = $api->anetcolor->colorShiftMatrix($color->{metal});
#
#  my @cloth_calc   = $api->anetcolor->compositeColorShiftRgb($color->{base_rgb},\@cloth_matrix);
#  my @leather_calc = $api->anetcolor->compositeColorShiftRgb($color->{base_rgb},\@leather_matrix);
#  my @metal_calc   = $api->anetcolor->compositeColorShiftRgb($color->{base_rgb},\@metal_matrix);
#
#  my $cloth_calc    = join(',', @cloth_calc);
#  my $leather_calc  = join(',', @leather_calc);
#  my $metal_calc    = join(',', @metal_calc);
#
#  print OMAIN "$color_id|$color_name|$cloth|$cloth_calc|$leather|$leather_calc|$metal|$metal_calc\n";
}

close (OMAIN);

exit;


