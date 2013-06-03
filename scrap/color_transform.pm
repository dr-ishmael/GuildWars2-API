# Deprecated color transform code from GW2API.pm

sub colors {
  my ($self, $lang) = @_;

  if (defined $lang) {
    $lang = $self->check_language($lang);
  } else {
    $lang = $self->{language};
  }

  my $json = $self->api_request($_url_colors, { lang => $lang } );

  my %color_data;

  foreach my $color_id (keys %{$json->{colors}}) {
    my $color = $json->{colors}->{$color_id};

    $color_data{$color_id} = { name => $color->{name} };

    foreach my $material (qw/default cloth leather metal/) {
      if (defined $color->{$material}) {
        my $brightness = $color->{$material}->{brightness};
        my $contrast   = $color->{$material}->{contrast};
        my $hue        = $color->{$material}->{hue};
        my $saturation = $color->{$material}->{saturation};
        my $lightness  = $color->{$material}->{lightness};

        # Chained array mapping operations - applied in reverse order
        my ($R, $G, $B) = map { ($_ > 255) ? 255 : $_ }         # 4. Correct values to 0 or 255 if shifts
                          map { ($_ < 0) ? 0 : $_ }             #     result in values outside that range.
                          map { ($_ - 128) * $contrast + 128 }  # 3. Apply contrast shift
                          map { $_ + $brightness }              # 2. Apply brightness shift
                          (128, 26, 26);                        # 1. Base RGB for "most" colors

        my ($H, $S, $L) = $self->rgb2hsl($R, $G, $B);

        $H = (360*$H + $hue)/360;   # 5. Apply hue shift
        $H = $H - 1 if $H > 1;      # 6. Correct hue value (hue is cyclical)

        $S *= $saturation;          # 7. Apply saturation shift
        $S = 1 if $S > 1;           # 8. Correct saturation value to 1 if shift results in value > 1

        $L *= $lightness;           # 9. Apply lightness shift
        $L = 1 if $L > 1;           # 10. Correct lightness value to 1 if shift results in value > 1

        for ($self->{color_format}) {
          when ("rgbhex") { $color_data{$color_id}->{$material} = $self->rgb2hex($self->hsl2rgb($H, $S, $L)) }
          when ("rgb")    {
            my @rgb = map { $_ / 255 } $self->hsl2rgb($H, $S, $L);
            $color_data{$color_id}->{$material} =  \@rgb;
          }
          when ("rgb255") {
            my @rgb = $self->hsl2rgb($H, $S, $L);
            @rgb = map { int($_ + 0.5) } @rgb;
            $color_data{$color_id}->{$material} = \@rgb;
          }
          when ("hsl")    { $color_data{$color_id}->{$material} = [$H, $S, $L] }
          when ("hsl360") {
            my @hsl = ($H*360, $S*100, $L*100);
            @hsl = map { int($_ + 0.5) } @hsl;
            $color_data{$color_id}->{$material} = \@hsl;
          }
        }
      } else {
        $color_data{$color_id}->{$material} = ($self->{color_format} eq "rgbhex") ? "" : [];
      }
    }
  }
  return %color_data;
}

###
# RGB2HSL
###
# @param array(3)   Red, green, blue values normalized to 255
#
# @return array(3)  Hue, saturation, lightness values normalized to 1
#
sub rgb2hsl {
  my ($self, $r, $g, $b) = @_;

  ($r, $g, $b) = map { $_ / 255 } ($r, $g, $b);

  my $max = max($r, $g, $b);
  my $min = min($r, $g, $b);

  my $d = $max - $min;

  my ($h, $s) = (0) x 2;
  my $l = ($max + $min) / 2;

  if ($d > 0) {
    $s = ($l > 0.5) ? $d / (2 - $max - $min) : $d / ($max + $min);
    for ($max) {
      when ($r) { $h = ($g - $b) / $d + (($g < $b) ? 6 : 0); }
      when ($g) { $h = ($b - $r) / $d + 2; }
      when ($b) { $h = ($r - $g) / $d + 4; }
    }
    $h /= 6;
  }

  return ($h, $s, $l);
}

###
# HSL2RGB
###
# @param array(3)   Hue, saturation, lightness values normalized to 1
#
# @return array(3)  Red, green, blue values normalized to 255
#
sub hsl2rgb {
  my ($self, $h, $s, $l) = @_;

  my ($r, $g, $b) = ($l) x 3;

  if ($s != 0) {
    my $q = ($l < 0.5) ? $l * (1 + $s) : $l + $s - $l * $s;
    my $p = 2 * $l - $q;

    $r = $self->hue2rgb($p, $q, $h + 1/3);
    $g = $self->hue2rgb($p, $q, $h);
    $b = $self->hue2rgb($p, $q, $h - 1/3);
  }

  ($r, $g, $b) = map { $_ * 255 } ($r, $g, $b);

  return ($r, $g, $b);
}

###
# Hue2RGB
###
# @param array(3)   P, Q, T
#
# @return scalar    RGB value normalized to 1
#
sub hue2rgb {
  my ($self, $p, $q, $t) = @_;

  $t += 1 if $t < 0;
  $t -= 1 if $t > 1;

  return $p + ($q - $p) * 6 * $t          if $t < 1/6;
  return $q                               if $t < 1/2;
  return $p + ($q - $p) * (2/3 - $t) * 6  if $t < 2/3;
  return $p;
}

###
# RGB2Hex
###
# @param array(3)   Red, green, blue values normalized to 255
#
# @return scalar    6-character hex string
#
sub rgb2hex {
  my ($self, $r, $g, $b) = @_;

  my ($r2, $g2, $b2) = map { sprintf "%02X", int($_) } ($r, $g, $b);

  my $hexstring = $r2.$g2.$b2;

  return $hexstring;
}

