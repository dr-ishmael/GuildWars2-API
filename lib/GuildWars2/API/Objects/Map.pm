use Carp ();
use Modern::Perl '2012';

=pod

=head1 DESCRIPTION

This subclass of GuildWars2::API::Objects defines the Map object.

=cut

####################
# Map
####################
package GuildWars2::API::Objects::Map;
use Moose;
use Moose::Util::TypeConstraints;

=pod

=head1 CLASSES

=head2 Map

The Map object represents a map definition in Guild Wars 2. It is returned
by the $api- >get_maps() method.

=head3 Attributes

=over

=item map_name

The map's name.

=item min_level
=item max_level

The minimum and maximum levels allowed/recommended for the map.

=item default_floor

The default floor for the map.

=item floors

An array listing all the floors that the map covers.

=item region_id

The ID of the region that the map belongs to.

=item map_rect
=item continent_rect

Arrays containing the southwest and northeast points (X,Y) defining the extent
of the map, in both map coordinates and continent coordinates.

=back

=cut

has 'map_name'        => ( is => 'ro', isa => 'Str',            required => 1 );
has 'min_level'       => ( is => 'ro', isa => 'Int',            required => 1 );
has 'max_level'       => ( is => 'ro', isa => 'Int',            required => 1 );
has 'default_floor'   => ( is => 'ro', isa => 'Int',            required => 1 );
has 'floors'          => ( is => 'ro', isa => 'ArrayRef[Int]',  required => 1 );
has 'region_id'       => ( is => 'ro', isa => 'Int',            required => 1 );
has 'map_rect'        => ( is => 'ro', isa => 'ArrayRef[ArrayRef[Int]]',  required => 1 );
has 'continent_rect'  => ( is => 'ro', isa => 'ArrayRef[ArrayRef[Int]]',  required => 1 );


1;
