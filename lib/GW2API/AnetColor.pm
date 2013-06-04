package GW2API::AnetColor;

use strict;

BEGIN {
  require Exporter;
  our @EXPORT      = qw(compositeColorShiftRgb);
}

use List::Util qw/max min/;

use constant PI => 4 * atan2(1, 1);

sub new {
  my $class = shift;
  my $this = $class->SUPER::new( @_ );
  return bless $this, $class;
}

sub matrix_multiply {
    my ($r_mat1, $r_mat2) = @_;       # Taking matrices by reference
    my ($r_product);                  # Returing product by reference
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
    my ($r_mat)  = @_;
    my $num_rows = @$r_mat;
    my $num_cols = @{$r_mat->[0]}; # Assume all rows have an equal no.
                                   # of columns.
    ($num_rows, $num_cols);
}


sub compositeColorShiftRgb {
  my ($base_rgb, $material) = @_;

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

  # apply the color transformation
  if (ref($base_rgb->[0]) && ref($base_rgb->[0]->[0])) {
    # $base_rgb looks like a 2D array / aka matrix / aka image
    my ($r1, $c1) = matrix_count_rows_cols ($base_rgb);
    my @result_rgb;
    for (my $i = 0; $i < $r1; $i++) {
      for (my $j = 0; $j < $c2; $j++) {
        my @bgrVector = (
          [$base_rgb->[$i]->[$j]->[2]],
          [$base_rgb->[$i]->[$j]->[1]],
          [$base_rgb->[$i]->[$j]->[0]],
          [1],
        );

        @bgrVector = @{matrix_multiply(\@matrix, \@bgrVector)};

        my @resultRgb = map { int(max(0, min(255, $_))) }
                        ($bgrVector[2][0], $bgrVector[1][0], $bgrVector[0][0]);

        $result_rgb[$i]->[$j] = \@resultRgb;
      }
    }
  } else {
    # $base_rgb is a single RGB vector
    my @bgrVector = (
      [$base_rgb->[2]],
      [$base_rgb->[1]],
      [$base_rgb->[0]],
      [1],
    );

    @bgrVector = @{matrix_multiply(\@matrix, \@bgrVector)};

    my @resultRgb = map { int(max(0, min(255, $_))) }
                    ($bgrVector[2][0], $bgrVector[1][0], $bgrVector[0][0]);

  }
  return @resultRgb;
}

1;
