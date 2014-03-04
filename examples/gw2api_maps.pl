#!perl -w

use Modern::Perl '2012';

use GuildWars2::API;

use Data::Dumper;

my $api = GuildWars2::API->new;


open(OREGS, ">map_regions.csv") or die "unable to open file: $!\n";
open(OMAPS, ">map_maps.csv") or die "unable to open file: $!\n";
open(OPNTS, ">map_landmarks.csv") or die "unable to open file: $!\n";
open(OTASK, ">map_tasks.csv") or die "unable to open file: $!\n";
open(OSKIL, ">map_skills.csv") or die "unable to open file: $!\n";
open(OSECT, ">map_sectors.csv") or die "unable to open file: $!\n";


say OREGS "region_id|region_name|label_coord_x|label_coord_y";
say OMAPS "region_id|map_id|map_name|min_level|max_level|default_floor|continent_rect_sw_x|continent_rect_sw_y|continent_rect_ne_x|continent_rect_ne_y|map_rect_sw_x|map_rect_sw_y|map_rect_ne_x|map_rect_ne_y";
say OPNTS "map_id|poi_id|poi_name|poi_type|floor|coord_x|coord_y";
say OTASK "map_id|task_id|objective|level|coord_x|coord_y";
say OSKIL "map_id|coord_x|coord_y";
say OSECT "map_id|sector_id|sector_name|level|coord_x|coord_y";


my %map_tree = $api->get_maps;

foreach my $region_id (sort { $a <=> $b } keys %map_tree) {

  my $region = $map_tree{$region_id};

  my $region_name = $region->{region_name};
  my $label_coord = $region->{label_coord};

  say OREGS "$region_id|$region_name|" . join('|', @$label_coord);

  foreach my $map_id (sort { $a <=> $b } keys %{$region->{maps}}) {

    my $map = $region->{maps}->{$map_id};

    my $map_name            = $map->{map_name};
    my $min_level           = $map->{min_level};
    my $max_level           = $map->{max_level};
    my $default_floor       = $map->{default_floor};
    my $continent_rect      = $map->{continent_rect};
    my $map_rect            = $map->{map_rect};

    my $points_of_interest  = $map->{points_of_interest};
    my $tasks               = $map->{tasks};
    my $skill_challenges    = $map->{skill_challenges};
    my $sectors             = $map->{sectors};

    say OMAPS "$region_id|$map_id|$map_name|$min_level|$max_level|$default_floor"
            . "|$continent_rect->[0][0]|$continent_rect->[0][1]|$continent_rect->[1][0]|$continent_rect->[1][1]"
            . "|$map_rect->[0][0]|$map_rect->[0][1]|$map_rect->[1][0]|$map_rect->[1][1]";

    foreach my $poi (@$points_of_interest) {
      my $poi_id    = $poi->{poi_id};
      my $poi_name  = $poi->{poi_name};
      my $poi_type  = $poi->{poi_type};
      my $floor     = $poi->{floor};
      my $coord     = $poi->{coord};

      say OPNTS "$map_id|$poi_id|$poi_name|$poi_type|$floor|$coord->[0]|$coord->[1]";
    }

    foreach my $task (@$tasks) {
      my $task_id   = $task->{task_id};
      my $objective = $task->{objective};
      my $level     = $task->{level};
      my $coord     = $task->{coord};

      say OTASK "$map_id|$task_id|$objective|$level|$coord->[0]|$coord->[1]";
    }

    foreach my $skill_challenge (@$skill_challenges) {
      my $coord     = $skill_challenge->{coord};

      say OSKIL "$map_id|$coord->[0]|$coord->[1]";
    }

    foreach my $sector (@$sectors) {
      my $sector_id = $sector->{sector_id};
      my $name      = $sector->{name};
      my $level     = $sector->{level};
      my $coord     = $sector->{coord};

      say OSECT "$map_id|$sector_id|$name|$level|$coord->[0]|$coord->[1]";
    }

  }
}

close (OREGS);
close (OMAPS);
close (OPNTS);
close (OTASK);
close (OSKIL);
close (OSECT);

exit;
