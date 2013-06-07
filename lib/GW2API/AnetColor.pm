package GW2API::AnetColor;

use parent 'GW2API';

use strict;

use 5.14.0;

use List::Util qw/max min/;

# only include ImageMagick if the generate_guild_emblem method is called
my $generate_ok = eval {require Image::Magick} ? 1 : 0;

use constant PI => 4 * atan2(1, 1);

my $_url_colors           = 'colors.json';

sub new {
  my($class, %cnf) = @_;

  my $emblem_texture_folder = delete $cnf{emblem_texture_folder};
  my $emblem_output_folder = delete $cnf{emblem_output_folder};

  my $self = bless {
      emblem_texture_folder => $emblem_texture_folder,
      emblem_output_folder => $emblem_output_folder
    }, $class;
}

sub _elem
{
  my $self = shift;
  my $elem = shift;
  my $old = $self->{$elem};
  $self->{$elem} = shift if @_;
  return $old;
}

sub emblem_texture_folder { shift->_elem('emblem_texture_folder'    ,@_); }
sub emblem_output_folder  { shift->_elem('emblem_output_folder'    ,@_); }

sub rgb2hex {
  my ($self, $r, $g, $b) = @_;

  my ($r2, $g2, $b2) = map { sprintf "%02X", int($_) } ($r, $g, $b);

  my $hexstring = $r2.$g2.$b2;

  return $hexstring;
}

sub matrix_multiply {
  my ($self, $r_mat1, $r_mat2);
    if (ref($_[0]) eq "GW2API::AnetColor") {
      # called as class method
      ($self, $r_mat1, $r_mat2) = @_;
    } else {
      # called as function
      ($r_mat1, $r_mat2) = @_;        # Taking matrices by reference
    }

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
    my ($self, $r_mat);
    if (ref($_[0]) eq "GW2API::AnetColor") {
      ($self, $r_mat) = @_;
    } else {
      ($r_mat) = @_;
    }

    my $num_rows = @$r_mat;
    my $num_cols = @{$r_mat->[0]}; # Assume all rows have an equal no.
                                   # of columns.
    ($num_rows, $num_cols);
}


sub colorShiftMatrix {
  my ($self, $material) = @_;

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
  my ($self, $base_rgb, $matrix) = @_;

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

sub generate_guild_emblem {
  my ($self, $guild_details, $colors) = @_;

  Carp::croak("ImageMagick is not installed, you can't generate guild emblems!") if !$generate_ok;

  Carp::croak("You must supply a value for the emblem_texture_folder configuration option in order to generate guild emblems.")
    if !defined($self->{emblem_texture_folder});

  # for simpler local access
  my $tf = $self->emblem_texture_folder;
  my $of = $self->emblem_output_folder;

  # Sanity checks on emblem texture folder
  Carp::croak("emblem_texture_folder [$tf] does not exist!")     if ! -e $tf;
  Carp::croak("emblem_texture_folder [$tf] is not a directory!") if ! -d $tf;

  Carp::croak("emblem_texture_folder [$tf] doesn't have expected subfolders!")
    if ! -e "$tf/guild emblems"
    || ! -e "$tf/guild emblem backgrounds"
    || ! -d "$tf/guild emblems"
    || ! -d "$tf/guild emblem backgrounds"
  ;

  # Sanity checks on emblem output folder
  Carp::croak("emblem_output_folder [$of] does not exist!")     if ! -e $of;
  Carp::croak("emblem_output_folder [$of] is not a directory!") if ! -d $of;
  Carp::croak("emblem_output_folder [$of] is not writable!")    if ! -w $of;

  my $guild_id        = $guild_details->{guild_id};

  my $bg_id           = $guild_details->{emblem}->{background_id};
  my $fg_id           = $guild_details->{emblem}->{foreground_id};
  my $bg_color_id     = $guild_details->{emblem}->{background_color_id};
  my $fg_color_id1    = $guild_details->{emblem}->{foreground_primary_color_id};
  my $fg_color_id2    = $guild_details->{emblem}->{foreground_secondary_color_id};
  my $flags           = $guild_details->{emblem}->{flags};

  my $base_png        = $fg_id.".png";
  my $primary_mask    = $fg_id."a.png";
  my $secondary_mask  = $fg_id."b.png";
  my $bg_png          = $bg_id.".png";

  my $b_material = $colors->{$bg_color_id}->{cloth};
  my $p_material = $colors->{$fg_color_id1}->{cloth};
  my $s_material = $colors->{$fg_color_id2}->{cloth};

  my $image = Image::Magick->new;
  $image->Set(size=>'256x256');

  my $error = $image->Read(
    'xc:none',                                # 0
    $tf."/guild emblems/".$base_png,          # 1
    $tf."/guild emblems/".$primary_mask,      # 2
    'xc:none',                                # 3
    $tf."/guild emblems/".$base_png,          # 4
    $tf."/guild emblems/".$secondary_mask,    # 5
    $tf."/guild emblem backgrounds/".$bg_png  # 6
  );

  Carp::croak($error) if $error;

  # Mask primary color zone onto base canvas
  $image->[2]->Level(levels=>"50%,50%");
  $image->[2]->Set(alpha=>"copy");
  $image->[0]->Composite(image=>$image->[1], mask=>$image->[2]);

  # Mask secondary color zone onto base canvas
  $image->[5]->Level(levels=>"50%,50%");
  $image->[5]->Set(alpha=>"copy");
  $image->[3]->Composite(image=>$image->[4], mask=>$image->[5]);


  # Primary
  my @p_matrix = $self->colorShiftMatrix($p_material);
  foreach my $x ( 0 .. 256 ) {
    foreach my $y ( 0 .. 256 ) {
      my ($alpha) = $image->[2]->getPixel(x=>$x, y=>$y);

      if ($alpha > 0) {
        my @rgb = $image->[0]->getPixel(x=>$x, y=>$y);

        @rgb = map { $_ * 255} @rgb;

        my @rgb2 = $self->compositeColorShiftRgb(\@rgb,\@p_matrix);

        @rgb2 = map { $_ / 255} @rgb2;

        $image->[0]->setPixel(x=>$x, y=>$y, color=>\@rgb2);
      }
    }
  }

  # Secondary
  my @s_matrix = $self->colorShiftMatrix($s_material);
  foreach my $x ( 0 .. 256 ) {
    foreach my $y ( 0 .. 256 ) {
      my ($alpha) = $image->[5]->getPixel(x=>$x, y=>$y);

      if ($alpha > 0) {
        my @rgb = $image->[3]->getPixel(x=>$x, y=>$y);

        @rgb = map { $_ * 255} @rgb;

        my @rgb2 = $self->compositeColorShiftRgb(\@rgb,\@s_matrix);

        @rgb2 = map { $_ / 255} @rgb2;

        $image->[3]->setPixel(x=>$x, y=>$y, color=>\@rgb2);
      }
    }
  }

  # Background
  my @b_matrix = $self->colorShiftMatrix($b_material);
  foreach my $x ( 0 .. 256 ) {
    foreach my $y ( 0 .. 256 ) {
      my ($alpha) = $image->[6]->getPixel(x=>$x, y=>$y);

      if ($alpha > 0) {
        my @rgb = $image->[6]->getPixel(x=>$x, y=>$y);

        @rgb = map { $_ * 255} @rgb;

        my @rgb2 = $self->compositeColorShiftRgb(\@rgb,\@b_matrix);

        @rgb2 = map { $_ / 255} @rgb2;

        $image->[6]->setPixel(x=>$x, y=>$y, color=>\@rgb2);
      }
    }
  }

  # Composite foreground primary onto secondary
  $image->[0]->Composite(image=>$image->[3]);

  for (@$flags) {
    $image->[0]->Flop() when "FlipForegroundHorizontal";
    $image->[0]->Flip() when "FlipForegroundVertical";
    $image->[6]->Flop() when "FlipBackgroundHorizontal";
    $image->[6]->Flip() when "FlipBackgroundVertical";
  }

  # Composite foreground onto background
  $image->[6]->Composite(image=>$image->[0]);

  # Write out the final image
  $image->[6]->Write(filename=>"$of/$guild_id.png");
}


1;
