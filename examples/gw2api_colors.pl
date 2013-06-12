#!perl -w

use Modern::Perl '2012';

use GuildWars2::API;
use GuildWars2::Color qw/ rgb2hex colorShiftMatrix compositeColorShiftRgb /;

my $api = GuildWars2::API->new;

open(OMAIN, ">colors.csv") or die "unable to open file: $!\n";

say OMAIN "color_id|color_name|cloth|leather|metal";
#say OMAIN "color_id|color_name|cloth|cloth-calc|leather|leather-calc|metal|metal-calc";

my %colors = $api->colors;

foreach my $color_id (sort { $a <=> $b } keys %colors) {

  my $color = $colors{$color_id};

  my $color_name = $color->{name};
  my $cloth      = $color->{cloth}->{rgb};
  my $leather    = $color->{leather}->{rgb};
  my $metal      = $color->{metal}->{rgb};

  $cloth   = rgb2hex(@$cloth);
  $leather = rgb2hex(@$leather);
  $metal   = rgb2hex(@$metal);

  say OMAIN "$color_id|$color_name|$cloth|$leather|$metal";

#  my @cloth_matrix   = colorShiftMatrix($color->{cloth});
#  my @leather_matrix = colorShiftMatrix($color->{leather});
#  my @metal_matrix   = colorShiftMatrix($color->{metal});
#
#  my @cloth_calc   = compositeColorShiftRgb($color->{base_rgb},\@cloth_matrix);
#  my @leather_calc = compositeColorShiftRgb($color->{base_rgb},\@leather_matrix);
#  my @metal_calc   = compositeColorShiftRgb($color->{base_rgb},\@metal_matrix);
#
#  my $cloth_calc    = rgb2hex(@cloth_calc);
#  my $leather_calc  = rgb2hex(@leather_calc);
#  my $metal_calc    = rgb2hex(@metal_calc);
#
#  say OMAIN "$color_id|$color_name|$cloth|$cloth_calc|$leather|$leather_calc|$metal|$metal_calc";
}

close (OMAIN);

exit;


