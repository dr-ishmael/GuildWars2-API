#!perl

use Modern::Perl '2014';

use DateTime;
use DBI;

use GuildWars2::API;
use GuildWars2::API::Utils;

my $continent_id = 1;
my $floor_id = 2;
my $lang = 'en';


my $api = GuildWars2::API->new;

my @db_keys = qw(type name schema pass);
my @db_vals;
open(DB,"database_info.conf") or die "Can't open db info file: $!";
while (<DB>) {
  chomp;
  @db_vals = split (/,/);
  last;
}
close(DB);
my %db;
@db{@db_keys} = @db_vals;

# Connect to database
my $dbh = DBI->connect('dbi:'.$db{'type'}.':'.$db{'name'}, $db{'schema'}, $db{'pass'},{mysql_enable_utf8 => 1})
  or die "Can't connect: $DBI::errstr\n";

#say OREGS "region_id|region_name|label_coord_x|label_coord_y";
#say OMAPS "region_id|map_id|map_name|min_level|max_level|default_floor|continent_rect_sw_x|continent_rect_sw_y|continent_rect_ne_x|continent_rect_ne_y|map_rect_sw_x|map_rect_sw_y|map_rect_ne_x|map_rect_ne_y";
#say OPNTS "map_id|poi_id|poi_name|poi_type|floor|coord_x|coord_y";
#say OTASK "map_id|task_id|objective|level|coord_x|coord_y";
#say OSKIL "map_id|coord_x|coord_y";
#say OSECT "map_id|sector_id|sector_name|level|coord_x|coord_y";

my $sth_region_upsert = $dbh->prepare('
    insert into map_region_tb (continent_id, region_id, region_name, region_label_coord_x, region_label_coord_y)
    values (?, ?, ?, ?, ?)
    on duplicate key update
      continent_id=VALUES(continent_id)
     ,region_name=VALUES(region_name)
     ,region_label_coord_x=VALUES(region_label_coord_x)
     ,region_label_coord_y=VALUES(region_label_coord_y)
  ')
  or die "Can't prepare statement: $DBI::errstr";

my $sth_map_upsert = $dbh->prepare('
    insert into map_tb (region_id, map_id, map_name, map_min_level, map_max_level, default_floor, map_rect_nw_x, map_rect_nw_y, map_rect_se_x, map_rect_se_y, continent_rect_nw_x, continent_rect_nw_y, continent_rect_se_x, continent_rect_se_y)
    values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    on duplicate key update
      region_id=VALUES(region_id)
     ,map_name=VALUES(map_name)
     ,map_min_level=VALUES(map_min_level)
     ,map_max_level=VALUES(map_max_level)
     ,default_floor=VALUES(default_floor)
     ,map_rect_nw_x=VALUES(map_rect_nw_x)
     ,map_rect_nw_y=VALUES(map_rect_nw_y)
     ,map_rect_se_x=VALUES(map_rect_se_x)
     ,map_rect_se_y=VALUES(map_rect_se_y)
     ,continent_rect_nw_x=VALUES(continent_rect_nw_x)
     ,continent_rect_nw_y=VALUES(continent_rect_nw_y)
     ,continent_rect_se_x=VALUES(continent_rect_se_x)
     ,continent_rect_se_y=VALUES(continent_rect_se_y)
  ')
  or die "Can't prepare statement: $DBI::errstr";

my $sth_sector_upsert = $dbh->prepare('
    insert into map_sector_tb (map_id, sector_id, sector_name, sector_level, sector_coord_x, sector_coord_y)
    values (?, ?, ?, ?, ?, ?)
    on duplicate key update
      map_id=VALUES(map_id)
     ,sector_name=VALUES(sector_name)
     ,sector_coord_x=VALUES(sector_coord_x)
     ,sector_coord_y=VALUES(sector_coord_y)
  ')
  or die "Can't prepare statement: $DBI::errstr";

my $sth_poi_upsert = $dbh->prepare('
    insert into map_poi_tb (map_id, poi_id, poi_name, poi_type, poi_floor, poi_coord_x, poi_coord_y)
    values (?, ?, ?, ?, ?, ?, ?)
    on duplicate key update
      map_id=VALUES(map_id)
     ,poi_name=VALUES(poi_name)
     ,poi_type=VALUES(poi_type)
     ,poi_floor=VALUES(poi_floor)
     ,poi_coord_x=VALUES(poi_coord_x)
     ,poi_coord_y=VALUES(poi_coord_y)
  ')
  or die "Can't prepare statement: $DBI::errstr";

my $sth_task_upsert = $dbh->prepare('
    insert into map_task_tb (map_id, task_id, task_objective, task_level, task_coord_x, task_coord_y)
    values (?, ?, ?, ?, ?, ?)
    on duplicate key update
      map_id=VALUES(map_id)
     ,task_objective=VALUES(task_objective)
     ,task_level=VALUES(task_level)
     ,task_coord_x=VALUES(task_coord_x)
     ,task_coord_y=VALUES(task_coord_y)
  ')
  or die "Can't prepare statement: $DBI::errstr";







my %map_tree = $api->get_maps($continent_id, $floor_id, $lang);

foreach my $region_id (keys %map_tree) {

  my $region = $map_tree{$region_id};

  $sth_region_upsert->execute(
      $continent_id
     ,$region_id
     ,$region->region_name
     ,$region->label_coord->[0]
     ,$region->label_coord->[1]
    )
    or die "Can't execute statement: $DBI::errstr";


  foreach my $map_id (keys %{$region->{maps}}) {

    my $map = $region->{maps}->{$map_id};

    $sth_map_upsert->execute(
        $region_id
       ,$map_id
       ,$map->map_name
       ,$map->min_level
       ,$map->max_level
       ,$map->default_floor
       ,$map->map_rect->[0]->[0]
       ,$map->map_rect->[0]->[1]
       ,$map->map_rect->[1]->[0]
       ,$map->map_rect->[1]->[1]
       ,$map->continent_rect->[0]->[0]
       ,$map->continent_rect->[0]->[1]
       ,$map->continent_rect->[1]->[0]
       ,$map->continent_rect->[1]->[1]
      )
      or die "Can't execute statement: $DBI::errstr";

    my $points_of_interest  = $map->{points_of_interest};
    my $tasks               = $map->{tasks};
    my $skill_challenges    = $map->{skill_challenges};
    my $sectors             = $map->{sectors};

    foreach my $poi (@$points_of_interest) {
      $sth_poi_upsert->execute(
          $map_id
         ,$poi->poi_id
         ,$poi->poi_name
         ,$poi->poi_type
         ,$poi->floor
         ,$poi->coord->[0]
         ,$poi->coord->[1]
        )
        or die "Can't execute statement: $DBI::errstr";
    }

    foreach my $task (@$tasks) {
      $sth_task_upsert->execute(
          $map_id
         ,$task->task_id
         ,$task->objective
         ,$task->level
         ,$task->coord->[0]
         ,$task->coord->[1]
        )
        or die "Can't execute statement: $DBI::errstr";
    }

#    foreach my $skill_challenge (@$skill_challenges) {
#      my $coord     = $skill_challenge->{coord};
#
#      say OSKIL "$map_id|$coord->[0]|$coord->[1]";
#    }

    foreach my $sector (@$sectors) {
      $sth_sector_upsert->execute(
          $map_id
         ,$sector->sector_id
         ,$sector->name
         ,$sector->level
         ,$sector->coord->[0]
         ,$sector->coord->[1]
        )
        or die "Can't execute statement: $DBI::errstr";
    }

  }
}

exit;
