use Carp ();
use Modern::Perl '2012';

package GuildWars2::API::Objects;
BEGIN {
  $GuildWars2::API::Objects::VERSION = '0.50';
}
use Moose;

=pod

=head1 DESCRIPTION

This class and its subclasses define the objects that can be returned from
GuildWars2::API. Some objects also have methods attached to them.

=head1 SUBCLASSES

See the individual modules for documentation of these subclasses

=item * GuildWars2::API::Objects::Guild


=cut

use GuildWars2::API::Objects::Guild;


####################
# Color
####################
package GuildWars2::API::Objects::Color;
use Moose;
use Moose::Util::TypeConstraints;

subtype 'My::GuildWars2::API::Objects::Color::Material' => as class_type('GuildWars2::API::Objects::Color::Material');

coerce 'My::GuildWars2::API::Objects::Color::Material'
  => from 'HashRef'
  => via { GuildWars2::API::Objects::Color::Material->new( %{$_} ) };

has 'name'            => ( is => 'ro', isa => 'Str', required => 1 );
has 'base_rgb'        => ( is => 'ro', isa => 'ArrayRef[Int]', required => 1 );
has 'default'         => ( is => 'ro', isa => 'My::GuildWars2::API::Objects::Color::Material', coerce => 1 );
has 'cloth'           => ( is => 'ro', isa => 'My::GuildWars2::API::Objects::Color::Material', coerce => 1 );
has 'leather'         => ( is => 'ro', isa => 'My::GuildWars2::API::Objects::Color::Material', coerce => 1 );
has 'metal'           => ( is => 'ro', isa => 'My::GuildWars2::API::Objects::Color::Material', coerce => 1 );



####################
# Color->Material
####################
package GuildWars2::API::Objects::Color::Material;
use Moose;

has 'brightness'      => ( is => 'ro', isa => 'Int', required => 1 );
has 'contrast'        => ( is => 'ro', isa => 'Num', required => 1 );
has 'hue'             => ( is => 'ro', isa => 'Int', required => 1 );
has 'saturation'      => ( is => 'ro', isa => 'Num', required => 1 );
has 'lightness'       => ( is => 'ro', isa => 'Num', required => 1 );
has 'rgb'             => ( is => 'ro', isa => 'ArrayRef[Int]', required => 1 );


=pod

   cloth    =>                # Transformation data for cloth material
     {
       brightness => [FLOAT],       # Brightness shift (RGB255)
       contrast   => [FLOAT],       # Contrast shift (RGB255)
       hue        => [FLOAT],       # Hue shift (0 <= H <= 360)
       saturation => [FLOAT],       # Saturation shift (0 <= S <= 1)
       lightness  => [FLOAT],       # Lightness shift (0 <= L <= 1)
       rgb        => array([INT]),  # Pre-calculated RGB values from the base_rgb color
     },

=cut

1;
