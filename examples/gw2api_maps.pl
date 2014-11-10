#!perl

use Modern::Perl '2014';

use DateTime;
use DBI;

use GuildWars2::API;
use GuildWars2::API::Utils;

###
# Set up API interface
my $api = GuildWars2::API->new;

# Read config info for database
# This file contains a single line, of the format:
#   <database_type>,<database_name>,<schema_name>,<schema_password>
#
# where <database_type> corresponds to the DBD module for your database.
#
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

if (defined($ARGV[0]) && $ARGV[0] eq "test") {
  $db{'schema'} = $db{'schema'} . "_test";
}

# Connect to database
my $dbh = DBI->connect('dbi:'.$db{'type'}.':'.$db{'name'}, $db{'schema'}, $db{'pass'},{mysql_enable_utf8 => 1})
  or die "Can't connect: $DBI::errstr\n";

# Prepare SQL statements
my $sth_continent_upsert = $dbh->prepare('
    insert ignore into map_continent_tb (continent_id, continent_name, continent_dims_x, continent_dims_y, min_zoom, max_zoom)
    values (?, ?, ?, ?, ?, ?)
  ')
  or die "Can't prepare statement: $DBI::errstr";

my $sth_map_floor_upsert = $dbh->prepare('
    insert ignore into map_floor_tb (continent_id, floor_id, texture_dims_x, texture_dims_y, clamped_view_nw_x, clamped_view_nw_y, clamped_view_se_x, clamped_view_se_y)
    values (?, ?, ?, ?, ?, ?, ?, ?)
  ')
  or die "Can't prepare statement: $DBI::errstr";

my $sth_region_upsert = $dbh->prepare('
    insert ignore into map_region_tb (continent_id, floor_id, region_id, region_name, region_label_coord_x, region_label_coord_y)
    values (?, ?, ?, ?, ?, ?)
  ')
  or die "Can't prepare statement: $DBI::errstr";

my $sth_map_upsert = $dbh->prepare('
    insert ignore into map_tb (region_id, map_id, map_name, map_min_level, map_max_level, default_floor, map_rect_nw_x, map_rect_nw_y, map_rect_se_x, map_rect_se_y, continent_rect_nw_x, continent_rect_nw_y, continent_rect_se_x, continent_rect_se_y)
    values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ')
  or die "Can't prepare statement: $DBI::errstr";

my $sth_sector_upsert = $dbh->prepare('
    insert ignore into map_sector_tb (map_id, sector_id, sector_name, sector_level, sector_coord_x, sector_coord_y)
    values (?, ?, ?, ?, ?, ?)
  ')
  or die "Can't prepare statement: $DBI::errstr";

my $sth_challenge_upsert = $dbh->prepare('
    insert ignore into map_challenge_tb (map_id, challenge_id, challenge_coord_x, challenge_coord_y)
    values (?, ?, ?, ?)
  ')
  or die "Can't prepare statement: $DBI::errstr";

my $sth_poi_upsert = $dbh->prepare('
    insert ignore into map_poi_tb (map_id, poi_id, poi_name, poi_type, poi_floor, poi_coord_x, poi_coord_y)
    values (?, ?, ?, ?, ?, ?, ?)
  ')
  or die "Can't prepare statement: $DBI::errstr";

my $sth_task_upsert = $dbh->prepare('
    insert ignore into map_task_tb (map_id, task_id, task_objective, task_level, task_coord_x, task_coord_y)
    values (?, ?, ?, ?, ?, ?)
  ')
  or die "Can't prepare statement: $DBI::errstr";

#my $sth_floor_x_region_upsert = $dbh->prepare('
#    insert ignore into floor_x_region_tb (floor_id, region_id)
#    values (?, ?)
#  ')
#  or die "Can't prepare statement: $DBI::errstr";

my $sth_floor_x_map_upsert = $dbh->prepare('
    insert ignore into floor_x_map_tb (floor_id, map_id)
    values (?, ?)
  ')
  or die "Can't prepare statement: $DBI::errstr";

my $sth_map_floor_x_poi_upsert = $dbh->prepare('
    insert ignore into map_floor_x_poi_tb (map_id, floor_id, poi_id)
    values (?, ?, ?)
  ')
  or die "Can't prepare statement: $DBI::errstr";

my $sth_map_floor_x_challenge_upsert = $dbh->prepare('
    insert ignore into map_floor_x_challenge_tb (map_id, floor_id, challenge_id)
    values (?, ?, ?)
  ')
  or die "Can't prepare statement: $DBI::errstr";

my $sth_map_floor_x_task_upsert = $dbh->prepare('
    insert ignore into map_floor_x_task_tb (map_id, floor_id, task_id)
    values (?, ?, ?)
  ')
  or die "Can't prepare statement: $DBI::errstr";

my $sth_map_floor_x_sector_upsert = $dbh->prepare('
    insert ignore into map_floor_x_sector_tb (map_id, floor_id, sector_id)
    values (?, ?, ?)
  ')
  or die "Can't prepare statement: $DBI::errstr";





my %continents = $api->get_continents();

for my $continent_id (sort keys %continents) {

  my $continent = $continents{$continent_id};

  say "Continent [$continent_id]: " . $continent->continent_name;

  $sth_continent_upsert->execute(
    $continent_id,
    ,$continent->continent_name
    ,$continent->continent_dims->[0]
    ,$continent->continent_dims->[1]
    ,$continent->min_zoom
    ,$continent->max_zoom
  )
  or die "Can't execute statement: $DBI::errstr";

  for my $floor_id (sort {$a<=>$b} @{$continent->floors}) {

    say "  Floor [$floor_id]";

    my $floor = $api->get_map_floor($continent_id, $floor_id);

    $sth_map_floor_upsert->execute(
      $continent_id
      ,$floor_id
      ,$floor->texture_dims->[0]
      ,$floor->texture_dims->[1]
      ,$floor->clamped_view ? $floor->clamped_view->[0]->[0] : undef
      ,$floor->clamped_view ? $floor->clamped_view->[0]->[1] : undef
      ,$floor->clamped_view ? $floor->clamped_view->[1]->[0] : undef
      ,$floor->clamped_view ? $floor->clamped_view->[1]->[1] : undef
    )
    or die "Can't execute statement: $DBI::errstr";

    my $regions = $floor->regions;

    foreach my $region_id (sort {$a<=>$b} keys %$regions) {

      my $region = $regions->{$region_id};

      say "    Region [$region_id]: " . $region->region_name;

      $sth_region_upsert->execute(
          $continent_id
          ,$floor_id
          ,$region_id
          ,$region->region_name
          ,$region->label_coord->[0]
          ,$region->label_coord->[1]
        )
        or die "Can't execute statement: $DBI::errstr";

#      $sth_floor_x_region_upsert->execute(
#        $floor_id
#        ,$region_id
#      )
#     or die "Can't execute statement: $DBI::errstr";

      my $maps = $region->maps;

      foreach my $map_id (sort {$a<=>$b} keys %$maps) {

        my $map = $maps->{$map_id};

        say "      Map [$map_id]: " . $map->map_name;

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

        $sth_floor_x_map_upsert->execute(
          $floor_id
          ,$map_id
        )
        or die "Can't execute statement: $DBI::errstr";


        foreach my $poi (@{$map->{points_of_interest}}) {
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

          $sth_map_floor_x_poi_upsert->execute(
            $map_id
            ,$floor_id
            ,$poi->poi_id
          )
          or die "Can't execute statement: $DBI::errstr";
        }


        foreach my $challenge (@{$map->{skill_challenges}}) {
          $sth_challenge_upsert->execute(
              $map_id
              ,$challenge->challenge_id
              ,$challenge->coord->[0]
              ,$challenge->coord->[1]
            )
            or die "Can't execute statement: $DBI::errstr";

          $sth_map_floor_x_challenge_upsert->execute(
            $map_id
            ,$floor_id
            ,$challenge->challenge_id
          )
          or die "Can't execute statement: $DBI::errstr";
        }


        foreach my $task (@{$map->{tasks}}) {
          $sth_task_upsert->execute(
              $map_id
              ,$task->task_id
              ,$task->objective
              ,$task->level
              ,$task->coord->[0]
              ,$task->coord->[1]
            )
            or die "Can't execute statement: $DBI::errstr";

          $sth_map_floor_x_task_upsert->execute(
            $map_id
            ,$floor_id
            ,$task->task_id
          )
          or die "Can't execute statement: $DBI::errstr";
        }


        foreach my $sector (@{$map->{sectors}}) {
          $sth_sector_upsert->execute(
              $map_id
              ,$sector->sector_id
              ,$sector->name
              ,$sector->level
              ,$sector->coord->[0]
              ,$sector->coord->[1]
            )
            or die "Can't execute statement: $DBI::errstr";

          $sth_map_floor_x_sector_upsert->execute(
            $map_id
            ,$floor_id
            ,$sector->sector_id
          )
          or die "Can't execute statement: $DBI::errstr";
        }

      } # end for my $map
    } # end for my $region
  } # end for my $floor
} # end for my $continent

exit;
