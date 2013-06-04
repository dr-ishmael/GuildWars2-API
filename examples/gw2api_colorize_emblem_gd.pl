#!perl -w


# This "works" in that it applies the color transforms appropriately. However,
# GD fails at alpha handling, so there's no way to make the result game-accurate.

use strict;

use GW2API;
use GW2API::AnetColor;

use GD;


my $api = GW2API->new;

my %colors = $api->colors;

my $base_png        = "C:\\Users\\Tony\\Pictures\\GW2\\guild emblems\\59642.png";
my $primary_mask    = "C:\\Users\\Tony\\Pictures\\GW2\\guild emblems\\59644.png";
my $secondary_mask  = "C:\\Users\\Tony\\Pictures\\GW2\\guild emblems\\59646.png";

GD::Image->trueColor(1);

my $image = GD::Image->newFromPng($base_png);

my $primary = GD::Image->newFromPng($primary_mask);

my $secondary = GD::Image->newFromPng($secondary_mask);

$image->alphaBlending(0);
$image->saveAlpha(1);

my ($height, $width) = $image->getBounds;


# Primary
my %p_material = (brightness=>45,contrast=>1.44531,hue=>10,saturation=>0.0234375,lightness=>1.5625);
foreach my $x ( 0 .. $width ) {
    foreach my $y ( 0 .. $height ) {
        my ($index) = $image->getPixel($x,$y);

        my @rgb = $image->rgb($index);

        my ($r2,$g2,$b2) = $api->anetcolor->compositeColorShiftRgb(\@rgb,\%p_material);

        my ($aindex) = $primary->getPixel($x,$y);
        my ($alpha) = $primary->rgb($aindex);

        $alpha /= 255;

        ($r2,$g2,$b2) = map { $_ * $alpha } ($r2,$g2,$b2);

        my $newindex = $image->colorExact($r2,$g2,$b2) ||  $image->colorAllocate($r2,$g2,$b2);

        $image->setPixel($x,$y,$newindex);

    }
}

# Secondary
my %s_material = (brightness=>-3,contrast=>1.0625,hue=>356,saturation=>1.21094,lightness=>0.976563);
foreach my $x ( 0 .. $width ) {
    foreach my $y ( 0 .. $height ) {
        my ($index) = $image->getPixel($x,$y);

        my @rgb = $image->rgb($index);

        my ($r2,$g2,$b2) = $api->anetcolor->compositeColorShiftRgb(\@rgb,\%p_material);

        my ($aindex) = $secondary->getPixel($x,$y);
        my ($alpha) = $secondary->rgb($aindex);

        $alpha /= 255;

        ($r2,$g2,$b2) = map { $_ * $alpha } ($r2,$g2,$b2);

        my $newindex = $image->colorExact($r2,$g2,$b2) ||  $image->colorAllocate($r2,$g2,$b2);

        $image->setPixel($x,$y,$newindex);

    }
}

my $png_data = $image->png;
open (OFP,">test.png") || die "can't open output: $!";
binmode OFP;
print OFP $png_data;
close OFP;

exit;

__END__

"443":{"name":"White","base_rgb":[128,
26,
26],"cloth":{"brightness":45,"contrast":1.44531,"hue":10,"saturation":0.0234375,"lightness":1.5625,"rgb":[189,
186,
185]

"673":{"name":"Red","base_rgb":[128,
26,
26],"cloth":{"brightness":-3,"contrast":1.0625,"hue":356,"saturation":1.21094,"lightness":0.976563,
