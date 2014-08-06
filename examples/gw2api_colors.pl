#!perl -w

use Modern::Perl '2012';

use GuildWars2::API;
#use GuildWars2::Color qw/ rgb2hex colorShiftMatrix compositeColorShiftRgb /;

my $api = GuildWars2::API->new;

open(OMAIN, ">colors.csv") or die "unable to open file: $!\n";

say OMAIN "color_id|color_name|cloth|leather|metal";
#say OMAIN "color_id|color_name|cloth|cloth-calc|leather|leather-calc|metal|metal-calc";

my %colors = $api->get_colors();

foreach my $color_id (sort { $a <=> $b } keys %colors) {

  my $color = $colors{$color_id};

  my $color_name = $color->name;
  my $cloth      = $color->cloth->rgb_hex;
  my $leather    = $color->leather->rgb_hex;
  my $metal      = $color->metal->rgb_hex;

  say OMAIN "$color_id|$color_name|$cloth|$leather|$metal";

#  $color->cloth->generate_transform();
#  $color->leather->generate_transform();
#  $color->metal->generate_transform();
#
#  my $cloth_calc   = $color->cloth->apply_transform($color->base_rgb)->as_hex();
#  my $leather_calc = $color->leather->apply_transform($color->base_rgb)->as_hex();
#  my $metal_calc   = $color->metal->apply_transform($color->base_rgb)->as_hex();
#
#  say OMAIN "$color_id|$color_name|$cloth|$cloth_calc|$leather|$leather_calc|$metal|$metal_calc";
}

close (OMAIN);

exit;
