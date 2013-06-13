use Modern::Perl '2012';

package GuildWars2::Color;
BEGIN
{
  require Exporter;
  # set the version for version checking
  $GuildWars2::Color::VERSION     = '0.50';
  # Inherit from Exporter to export functions and variables
  our @ISA         = qw(Exporter);
  # Functions and variables which are exported by default
  our @EXPORT      = ();
  # Functions and variables which can be optionally exported
  our @EXPORT_OK   = qw(
                          rgb2hex
                          matrix_multiply matrix_count_rows_cols
                          colorShiftMatrix compositeColorShiftRgb
                       );
}

use Carp ();
use List::Util qw/max min/;

use constant PI => 4 * atan2(1, 1);


sub rgb2hex {
  my ($r, $g, $b) = @_;

  my ($r2, $g2, $b2) = map { sprintf "%02X", int($_) } ($r, $g, $b);

  my $hexstring = $r2.$g2.$b2;

  return $hexstring;
}

sub matrix_multiply {
  my ($r_mat1, $r_mat2) = @_;     # Taking matrices by reference
  my ($r_product);                # Returing product by reference
  my ($r1, $c1) = matrix_count_rows_cols ($r_mat1);
  my ($r2, $c2) = matrix_count_rows_cols ($r_mat2);
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

sub matrix_count_rows_cols {  # return number of rows and columns
  my ($r_mat) = @_;
  my $num_rows = @$r_mat;
  my $num_cols = @{$r_mat->[0]}; # Assume all rows have an equal no.
                                 # of columns.
  ($num_rows, $num_cols);
}


sub colorShiftMatrix {
  my ($material) = @_;

  my $brightness = $material->{brightness} / 128;
  my $contrast   = $material->{contrast};
  my $hue        = ($material->{hue} * PI) / 180;  # convert to radians
  my $saturation = $material->{saturation};
  my $lightness  = $material->{lightness};

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
    @matrix = @{matrix_multiply(\@mult, \@matrix)};
  }

  if ($hue != 0 || $saturation != 1 || $lightness != 1) {
    # transform to HSL
    my @multRgbToHsl = (
      [ 0.707107, 0.0,      -0.707107, 0],
      [-0.408248, 0.816497, -0.408248, 0],
      [ 0.577350, 0.577350,  0.577350, 0],
      [ 0,        0,         0,        1],
    );
    @matrix = @{matrix_multiply(\@multRgbToHsl, \@matrix)};

    # process adjustments
    my $cosHue = cos($hue);
    my $sinHue = sin($hue);
    my @mult = (
      [$cosHue * $saturation,  $sinHue * $saturation, 0,          0],
      [-$sinHue * $saturation, $cosHue * $saturation, 0,          0],
      [0,                      0,                     $lightness, 0],
      [0,                      0,                     0,          1],
    );
    @matrix = @{matrix_multiply(\@mult, \@matrix)};

    # transform back to RGB
    my @multHslToRgb = (
      [ 0.707107, -0.408248, 0.577350, 0],
      [        0,  0.816497, 0.577350, 0],
      [-0.707107, -0.408248, 0.577350, 0],
      [ 0,         0,        0,        1],
    );
    @matrix = @{matrix_multiply(\@multHslToRgb, \@matrix)};
  }

  return @matrix;
}

sub compositeColorShiftRgb {
  my ($base_rgb, $matrix) = @_;

  # apply the color transformation
  my @bgrVector = (
    [$base_rgb->[2]],
    [$base_rgb->[1]],
    [$base_rgb->[0]],
    [1],
  );

  @bgrVector = @{matrix_multiply($matrix, \@bgrVector)};

  my @resultRgb = map { int(max(0, min(255, $_))) }
                  ($bgrVector[2][0], $bgrVector[1][0], $bgrVector[0][0]);

  return @resultRgb;
}

1;

=pod

=head1 NAME

GuildWars2::Color - A function library for performing Guild Wars 2 color
transformations as presented in the GW2 API.

=head1 SYNOPSIS

 use GuildWars2::API;
 use GuildWars2::Color qw/ colorShiftMatrix compositeColorShiftRgb rgb2hex /;

 $api = GuildWars2::API->new;

 %colors = $api->colors;

 $black = $colors{2};

 # Build the transformation matrix for the 'cloth' material

 @cloth_matrix   = colorShiftMatrix($black->{cloth});

 # Apply this transformation matrix to the color's base RGB values

 @cloth_calc = compositeColorShiftRgb($black->{base_rgb},\@cloth_matrix);

 # Convert to RGB hex code

 $cloth_hex = rgb2hex(@cloth_calc);


=head1 DESCRIPTION

GuildWars2::Color provides a set of functions for using the color transformation
data returned by the colors.json API. A transformation is defined for each
color, on each of three materials: cloth, leather, and metal.

At a high level, the transformation involves the following steps:

=item * Each color has a base RGB color that serves as the starting point for the
transformation. (When applying the color to a game texture, e.g. when generating
a guild emblem, the RGB color of the individual pixels is used as the base
color.)

=item * Brightness and contrast shifts are applied in the RGB colorspace.

=item * The color is converted to the HSL colorspace in order to apply hue,
saturation, and lightness shifts.

=item * The final color is converted back to RGB.


=head1 Functions

=over

=item colorShiftMatrix( $material )

Computes the transformation matrix for the given material object and returns it
as an array.

=item compositeColorShiftRgb( \@base_rgb, \@transform_matrix )

Applies the transformation matrix to the base RGB color and returns the
transformed color as an array.

=back

=head1 Author

Tony Tauer, E<lt>dr.ishmael[at]gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2013 by Tony Tauer

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__END__
