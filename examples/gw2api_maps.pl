#!perl -w

use Modern::Perl '2012';

use GuildWars2::API;

my $api = GuildWars2::API->new;

open(OMAIN, ">maps.csv") or die "unable to open file: $!\n";

say OMAIN "map_id|map_name|min_level|max_level|default_floor|floors|region_id|map_rect_sw_x|map_rect_sw_y|map_rect_ne_x|map_rect_ne_y|continent_rect_sw_x|continent_rect_sw_y|continent_rect_ne_x|continent_rect_ne_y";

my %maps = $api->get_maps;

foreach my $map_id (sort { $a <=> $b } keys %maps) {

  my $map = $maps{$map_id};

  my $map_name            = $map->map_name;
  my $min_level           = $map->min_level;
  my $max_level           = $map->max_level;
  my $default_floor       = $map->default_floor;
  my $floors              = $map->floors;
  my $region_id           = $map->region_id;
  my $map_rect            = $map->map_rect;
  my $continent_rect = $map->continent_rect;


say OMAIN "$map_id|$map_name|$min_level|$max_level|$default_floor"
        . "|" . join(',', @$floors)
        . "|$region_id|$map_rect->[0][0]|$map_rect->[0][1]|$map_rect->[1][0]|$map_rect->[1][1]|$continent_rect->[0][0]|$continent_rect->[0][1]|$continent_rect->[1][0]|$continent_rect->[1][1]";

}

close (OMAIN);

exit;
