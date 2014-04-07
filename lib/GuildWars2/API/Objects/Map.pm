use Modern::Perl '2014';

=pod

=head1 DESCRIPTION

This subclass of GuildWars2::API::Objects defines the cartographic objects used
to represent the world of Tyria.

Access to this data is provided through the C<$api->get_maps()> method, which
returns a hash of L<GuildWars2::API::Objects::Region|/Region> objects, keyed on region_id.

Coordinates are given as units on a "continent" grid of [0, 0] to
[32768, 32768].

=cut

####################
# Region
####################
package GuildWars2::API::Objects::Region;
use Moose;
use Moose::Util::TypeConstraints;

=pod

=head1 CLASSES

=head2 Region

Regions are the top-level cartographic element in Guild Wars 2, thus the Region
class is the top-level cartographic object in GuildWars2::API.  A region can
contain multiple maps.

=head3 Attributes

=over

=item region_name

The region's name.

=item label_coord

An array containing the (x, y) coordinates for positioning the region label.

=item maps

A hash consisting of L<GuildWars2::API::Objects::Map|/Map> objects, keyed on map_id,
representing all of the Maps in the Region.

=back

=cut

has 'region_name'     => ( is => 'ro', isa => 'Str',            required => 1 );
has 'label_coord'     => ( is => 'ro', isa => 'ArrayRef[Int]',  required => 1 );
has 'maps'            => ( is => 'ro', isa => 'HashRef[GuildWars2::API::Objects::Map]' );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  if(my $a = delete $args->{name}) { $args->{region_name} = $a }

  if(my $maps = delete $args->{maps}) {
    foreach my $map_id (keys %$maps) {
      my $map_obj = GuildWars2::API::Objects::Map->new( $maps->{$map_id} );
      $args->{maps}->{$map_id} = $map_obj;
    }
  }

  $class->$orig($args);
};


####################
# Map
####################
package GuildWars2::API::Objects::Map;
use Moose;
use Moose::Util::TypeConstraints;

=pod

=head2 Map

The Map class represents a map definition in Guild Wars 2.

=head3 Attributes

=over

=item map_name

The map's name.

=item min_level
=item max_level

The minimum and maximum levels allowed/recommended for the map.

=item default_floor

The default floor for the map.

=item continent_rect

An array of two (x, y) coordinates. These points are the southwest and northeast
corners of the bounding box for the map.

=item map_rect

Same as C<continent_rect>, but given in map coordinates, which are used by the
events API for defining event locations.

=item points_of_interest

An array of L<GuildWars2::API::Objects::PoI|/PoI> objects.

=item tasks

An array of L<GuildWars2::API::Objects::Task|/Task> objects.

=item skill_challenges

An array of L<GuildWars2::API::Objects::Challenge|/Challenge> objects.

=item sectors

An array of L<GuildWars2::API::Objects::Sector|/Sector> objects.

=back

=cut


has 'map_name'           => ( is => 'ro', isa => 'Str',            required => 1 );
has 'min_level'          => ( is => 'ro', isa => 'Int',            required => 1 );
has 'max_level'          => ( is => 'ro', isa => 'Int',            required => 1 );
has 'default_floor'      => ( is => 'ro', isa => 'Int',            required => 1 );
has 'continent_rect'     => ( is => 'ro', isa => 'ArrayRef[ArrayRef[Int]]',  required => 1 );
has 'map_rect'           => ( is => 'ro', isa => 'ArrayRef[ArrayRef[Int]]',  required => 1 );
has 'points_of_interest' => ( is => 'ro', isa => 'ArrayRef[GuildWars2::API::Objects::PoI]' );
has 'tasks'              => ( is => 'ro', isa => 'ArrayRef[GuildWars2::API::Objects::Task]' );
has 'skill_challenges'   => ( is => 'ro', isa => 'ArrayRef[GuildWars2::API::Objects::Challenge]' );
has 'sectors'            => ( is => 'ro', isa => 'ArrayRef[GuildWars2::API::Objects::Sector]' );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  if(my $a = delete $args->{name}) { $args->{map_name} = $a }

  if(my $x = delete $args->{points_of_interest}) {
    foreach my $m (@$x) {
      my $o = GuildWars2::API::Objects::PoI->new( $m );
      push @{$args->{points_of_interest}}, $o;
    }
  }

  if(my $x = delete $args->{tasks}) {
    foreach my $m (@$x) {
      my $o = GuildWars2::API::Objects::Task->new( $m );
      push @{$args->{tasks}}, $o;
    }
  }

  if(my $x = delete $args->{skill_challenges}) {
    foreach my $m (@$x) {
      my $o = GuildWars2::API::Objects::Challenge->new( $m );
      push @{$args->{skill_challenges}}, $o;
    }
  }

  if(my $x = delete $args->{sectors}) {
    foreach my $m (@$x) {
      my $o = GuildWars2::API::Objects::Sector->new( $m );
      push @{$args->{sectors}}, $o;
    }
  }

  $class->$orig($args);
};

####################
# PoI
####################
package GuildWars2::API::Objects::PoI;
use Moose;
use Moose::Util::TypeConstraints;

use GuildWars2::API::Constants;

with 'GuildWars2::API::Objects::Linkable';

=pod

=head2 PoI

The PoI class represents a point of interest in Guild Wars 2. Note that the
API definition of "point of interest" is broader than the in-game definition;
the API includes points of interest, waypoints, vistas, and certain other points
under this classification.

This class includes the Linkable role for generating game links, defined in
Linkable.pm.

=head3 Attributes

=over

=item poi_id

The internal ID of the point.

=item poi_name

The point's name.

=item poi_type

The point's type:

 landmark
 unlock
 vista
 waypoint

=item floor

The floor that the point is located on.

=item coord

An array of (x, y) coordinates defining the point's location.

=back

=head3 Methods

=over

=item $poi->game_link

Encodes and returns a game link using the point's C<poi_id>. This link can be
copied and pasted into the in-game chat window to generate a chat link for
the point. Clicking the chat link will open the world map and pan to the point's
location.

=back

=cut

has 'poi_id'          => ( is => 'ro', isa => 'Int',            required => 1 );
has 'poi_name'        => ( is => 'ro', isa => 'Str',            required => 1 );
has 'poi_type'        => ( is => 'ro', isa => 'Str',            required => 1 );
has 'floor'           => ( is => 'ro', isa => 'Str',            required => 1 );
has 'coord'           => ( is => 'ro', isa => 'ArrayRef[Num]',  required => 1 );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  if(my $a = delete $args->{name}) { $args->{poi_name} = $a } else { $args->{poi_name} = "" }
  if(my $a = delete $args->{type}) { $args->{poi_type} = $a }

  $class->$orig($args);
};

# Method required to provide type and ID to Linkable role
sub _gl_data {
  my ($self) = @_;
  return (MAP_LINK_TYPE, $self->poi_id);
}


####################
# Task
####################
package GuildWars2::API::Objects::Task;
use Moose;
use Moose::Util::TypeConstraints;

=pod

=head2 Task

The Task class represents a task, also known as a Renown Heart or Renown Region.

=head3 Attributes

=over

=item task_id

The internal ID of the task.

=item objective

The name of the task.

=item level

The recommended level for completing the task.

=item coord

An array of (x, y) coordinates defining the task's location.

=back

=cut

has 'task_id'         => ( is => 'ro', isa => 'Int',            required => 1 );
has 'objective'       => ( is => 'ro', isa => 'Str',            required => 1 );
has 'level'           => ( is => 'ro', isa => 'Int',            required => 1 );
has 'coord'           => ( is => 'ro', isa => 'ArrayRef[Num]',  required => 1 );


####################
# (Skill) Challenge
####################
package GuildWars2::API::Objects::Challenge;
use Moose;
use Moose::Util::TypeConstraints;

=pod

=head2 Challenge

The Challenge class represents a skill challenge.

=head3 Attributes

=over

=item coord

An array of (x, y) coordinates defining the challenge's location.

=back

=cut

has 'coord'           => ( is => 'ro', isa => 'ArrayRef[Num]',  required => 1 );


####################
# Sector
####################
package GuildWars2::API::Objects::Sector;
use Moose;
use Moose::Util::TypeConstraints;

=pod

=head2 Sector

The Sector class represents a sector, also known as an area. Sectors are the
lowest-level cartographic elements in Guild Wars 2.

=head3 Attributes

=over

=item sector_id

The internal ID of the sector.

=item name

The name of the sector.

=item level

The effective level of the sector.

=item coord

An array of (x, y) coordinates defining the sector's centroid.

=back

=cut

has 'sector_id'       => ( is => 'ro', isa => 'Int',            required => 1 );
has 'name'            => ( is => 'ro', isa => 'Str',            required => 1 );
has 'level'           => ( is => 'ro', isa => 'Int',            required => 1 );
has 'coord'           => ( is => 'ro', isa => 'ArrayRef[Num]',  required => 1 );

1;
