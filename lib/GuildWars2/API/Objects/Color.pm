use Carp ();
use Modern::Perl '2012';

=pod

=head1 DESCRIPTION

This subclass of GuildWars2::API::Objects defines the Color and Color::Material
objects.

=cut

####################
# Color
####################
package GuildWars2::API::Objects::Color;
use Moose;
use Moose::Util::TypeConstraints;

=pod

=head1 CLASSES

=head2 Color

The Color object represents a color definition in Guild Wars 2. It is returned
by the $api- >get_colors() method.

=head3 Attributes

=over

=item name

The color's name.

=item base_rgb
=item base_rgb_hex

The base RGB color for the color's transformations. Calling C<base_rgb> returns
the color as an array of integers normalized to 255; calling C<base_rgb_hex>
returns it as a hexadecimal string.

=item cloth
=item leather
=item metal

GuildWars2::API::Objects::Color::Material objects containing the detailed
information for the color transformations on each material.

=back

=cut

subtype 'My::GuildWars2::API::Objects::Color::Material' => as class_type('GuildWars2::API::Objects::Color::Material');
subtype 'My::GuildWars2::API::Objects::Color::RGB'      => as class_type('GuildWars2::API::Objects::Color::RGB');

coerce 'My::GuildWars2::API::Objects::Color::Material'
  => from 'HashRef'
  => via { GuildWars2::API::Objects::Color::Material->new( %{$_} ) };

coerce 'My::GuildWars2::API::Objects::Color::RGB'
  => from 'ArrayRef'
  => via { GuildWars2::API::Objects::Color::RGB->new( red => $_->[0], green => $_->[1], blue => $_->[2] ) };

has 'name'            => ( is => 'ro', isa => 'Str', required => 1 );
has '_base_rgb'       => ( is => 'ro', isa => 'My::GuildWars2::API::Objects::Color::RGB', required => 1, coerce => 1, handles => { base_rgb => 'as_array', base_rgb_hex => 'as_hex' } );
has 'default'         => ( is => 'ro', isa => 'My::GuildWars2::API::Objects::Color::Material', coerce => 1 );
has 'cloth'           => ( is => 'ro', isa => 'My::GuildWars2::API::Objects::Color::Material', coerce => 1 );
has 'leather'         => ( is => 'ro', isa => 'My::GuildWars2::API::Objects::Color::Material', coerce => 1 );
has 'metal'           => ( is => 'ro', isa => 'My::GuildWars2::API::Objects::Color::Material', coerce => 1 );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;
#  use Data::Dumper;
#  print Dumper($args);
#  exit;
  if(my $base_rgb = delete $args->{base_rgb}) {
    $args->{_base_rgb} = $base_rgb;
  }
  $class->$orig($args);
};


####################
# Color->Material
####################
package GuildWars2::API::Objects::Color::Material;
use Moose;
use Moose::Util::TypeConstraints;

=pod

=head2 Color::Material

The Color::Material subobject represents the color transformation parameters for a specific material.

=head3 Attributes

=over

=item brightness
=item contrast
=item hue
=item saturation
=item lightness

The components of the color transformation. Brightness and hue are integers, the
others are floating-point numbers.

=item * rgb
=item * rgb_hex

The pre-computed final RGB value of the color on this material from applying the
color transformation to the color's base_rgb value. Calling C<rgb> returns the
color as an array of integers normalized to 255; calling C<rgb_hex> returns it
as a hexadecimal string.

=item * transform

The computed transformation matrix for this material. Not defined until the
C<generate_transform()> method is called on the material. Utilized by calling
the C<apply_transform($rgb)> method on an RGB value.

=back

=head3 Methods

=over

=item $material->generate_transform()

Generates the transform matrix for the material and stores it in the
C<transform> attribute.

=item $material->apply_transform( $rgb )

Applies the computed C<transform> matrix to the given RGB value. Will generate
the C<transform> matrix if it is undefined. Returns a
GuildWars2::API::Objects::Color::RGB object.

=back

=cut

has 'brightness'      => ( is => 'ro', isa => 'Int', required => 1 );
has 'contrast'        => ( is => 'ro', isa => 'Num', required => 1 );
has 'hue'             => ( is => 'ro', isa => 'Int', required => 1 );
has 'saturation'      => ( is => 'ro', isa => 'Num', required => 1 );
has 'lightness'       => ( is => 'ro', isa => 'Num', required => 1 );
has '_rgb'            => ( is => 'ro', isa => 'My::GuildWars2::API::Objects::Color::RGB', required => 1, coerce => 1, handles => { rgb => 'as_array', rgb_hex => 'as_hex' } );
has 'transform'       => ( is => 'ro', isa => 'ArrayRef[ArrayRef[Num]]', writer => '_set_transform', );

around 'BUILDARGS', sub {
  my ($orig, $class, %args) = @_;
  if(my $rgb = delete $args{rgb}) {
    $args{_rgb} = $rgb;
  }
  $class->$orig(%args);
};

use List::Util qw/max min/;

use constant PI => 4 * atan2(1, 1);

sub generate_transform {
  my ($self) = @_;

  my $brightness = $self->{brightness} / 128;
  my $contrast   = $self->{contrast};
  my $hue        = ($self->{hue} * PI) / 180;  # convert to radians
  my $saturation = $self->{saturation};
  my $lightness  = $self->{lightness};

  my @matrix = (
    [1, 0, 0, 0],
    [0, 1, 0, 0],
    [0, 0, 1, 0],
    [0, 0, 0, 1],
  );

  if ($brightness != 0 || $contrast != 1) {
    # process brightness and contrast
    my $t = 128 * (2 * $brightness + 1 - $contrast);
    my @mult = (
      [$contrast, 0, 0, $t],
      [0, $contrast, 0, $t],
      [0, 0, $contrast, $t],
      [0, 0, 0, 1],
    );
    @matrix = @{_matrix_multiply(\@mult, \@matrix)};
  }

  if ($hue != 0 || $saturation != 1 || $lightness != 1) {
    # transform to HSL
    my @multRgbToHsl = (
      [ 0.707107, 0.0,      -0.707107, 0],
      [-0.408248, 0.816497, -0.408248, 0],
      [ 0.577350, 0.577350,  0.577350, 0],
      [ 0,        0,         0,        1],
    );
    @matrix = @{_matrix_multiply(\@multRgbToHsl, \@matrix)};

    # process adjustments
    my $cosHue = cos($hue);
    my $sinHue = sin($hue);
    my @mult = (
      [$cosHue * $saturation,  $sinHue * $saturation, 0,          0],
      [-$sinHue * $saturation, $cosHue * $saturation, 0,          0],
      [0,                      0,                     $lightness, 0],
      [0,                      0,                     0,          1],
    );
    @matrix = @{_matrix_multiply(\@mult, \@matrix)};

    # transform back to RGB
    my @multHslToRgb = (
      [ 0.707107, -0.408248, 0.577350, 0],
      [        0,  0.816497, 0.577350, 0],
      [-0.707107, -0.408248, 0.577350, 0],
      [ 0,         0,        0,        1],
    );
    @matrix = @{_matrix_multiply(\@multHslToRgb, \@matrix)};
  }

  $self->_set_transform(\@matrix);
}

sub _matrix_multiply {
  my ($r_mat1, $r_mat2) = @_;     # Taking matrices by reference
  my ($r_product);                # Returing product by reference
  my ($r1, $c1) = _matrix_count_rows_cols ($r_mat1);
  my ($r2, $c2) = _matrix_count_rows_cols ($r_mat2);
  die "Matrix 1 has $c1 columns and matrix 2 has $r2 rows."
       . " Cannot multiply\n" unless ($c1 == $r2);
  for (my $i = 0; $i < $r1; $i++) {
    for (my $j = 0; $j < $c2; $j++) {
      my $sum = 0;
      for (my $k = 0; $k < $c1; $k++) {
          $sum += $r_mat1->[$i][$k] * $r_mat2->[$k][$j];
      }
      $r_product->[$i][$j] = $sum;
    }
  }
  $r_product;
}

sub _matrix_count_rows_cols {  # return number of rows and columns
  my ($r_mat) = @_;
  my $num_rows = @$r_mat;
  my $num_cols = @{$r_mat->[0]}; # Assume all rows have an equal no.
                                 # of columns.
  ($num_rows, $num_cols);
}

sub apply_transform {
  my ($self, @base_rgb) = @_;

  if (!defined($self->transform)) {
    $self->generate_transform();
  }

  # apply the color transformation
  my @bgrVector = (
    [$base_rgb[2]],
    [$base_rgb[1]],
    [$base_rgb[0]],
    [1],
  );

  @bgrVector = @{_matrix_multiply($self->transform, \@bgrVector)};

  my @rgb = map { int(max(0, min(255, $_))) }
                  ($bgrVector[2][0], $bgrVector[1][0], $bgrVector[0][0]);

  return GuildWars2::API::Objects::Color::RGB->new( red => $rgb[0], green => $rgb[1], blue => $rgb[2] );
}

####################
# Color->RGB
####################
package GuildWars2::API::Objects::Color::RGB;
use Moose;
use Moose::Util::TypeConstraints;

=pod

=head2 Color::RGB

The Color::RGB subobject is the output of the Color::Material::apply_transform()
method and is a representation of an RGB color, using integers normalized to
255.

=head3 Attributes

=over

=item red
=item green
=item blue

The red, green, and blue component values of the color.

=back

=head3 Methods

=over

=item as_array

Returns the red, green, and blue component values in an array.

=item as_hex

Returns the RGB value as a hex string.

=back

=cut

subtype 'RGB255',
  as 'Int',
  where { $_ >= 0 && $_ <= 255 },
  message { "This number ($_) is not between 0 and 255!" };

has 'red'             => ( is => 'ro', isa => 'RGB255', required => 1 );
has 'green'           => ( is => 'ro', isa => 'RGB255', required => 1 );
has 'blue'            => ( is => 'ro', isa => 'RGB255', required => 1 );

sub as_array {
  my ($self) = @_;
  return ($self->red, $self->green, $self->blue);
}

sub as_hex {
  my ($self) = @_;
  my ($r, $g, $b) = map { sprintf "%02X", int($_) } ($self->red, $self->green, $self->blue);
  return $r.$g.$b;
}


1;
