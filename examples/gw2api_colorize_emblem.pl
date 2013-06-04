#!perl -w

use strict;


use GW2API;

use Image::Magick;


my $api = GW2API->new;

my %colors = $api->colors;

my $base_png        = "C:\\Users\\Tony\\Pictures\\GW2\\guild emblems\\433236.png";
my $primary_mask    = "C:\\Users\\Tony\\Pictures\\GW2\\guild emblems\\433238.png";
my $secondary_mask  = "C:\\Users\\Tony\\Pictures\\GW2\\guild emblems\\433240.png";



my $image = Image::Magick->new;
$image->Set(size=>'256x256');

$image->ReadImage($base_png,
                  $primary_mask,
                  $base_png,
                  $secondary_mask
);



# Secondary
my %s_material = (brightness=>4,contrast=>1,hue=>240,saturation=>0.625,lightness=>1.09375);
foreach my $x ( 0 .. 256 ) {
  foreach my $y ( 0 .. 256 ) {
    my ($alpha) = $image->[3]->getPixel(x=>$x, y=>$y);

    if ($alpha > 0) {
      my @rgb = $image->[2]->getPixel(x=>$x, y=>$y);

      @rgb = map { $_ * 255} @rgb;

      my @rgb2 = $api->anetcolor->compositeColorShiftRgb(\@rgb,\%s_material);

      @rgb2 = map { $_ / 255} @rgb2;

      #@rgb2 = map { $_ * $alpha } @rgb2;

      $image->[2]->setPixel(x=>$x, y=>$y, color=>\@rgb2);
    } else {
      $image->[2]->setPixel(x=>$x, y=>$y, channel=>'Alpha', color=>[1]);
    }
  }
}

# Primary
my %p_material = (brightness=>-2,contrast=>1,hue=>135,saturation=>0.546875,lightness=>0.976563);
foreach my $x ( 0 .. 256 ) {
  foreach my $y ( 0 .. 256 ) {
    my ($alpha) = $image->[1]->getPixel(x=>$x, y=>$y);

    if ($alpha > 0) {
      my @rgb = $image->[0]->getPixel(x=>$x, y=>$y);

      @rgb = map { $_ * 255} @rgb;

      my @rgb2 = $api->anetcolor->compositeColorShiftRgb(\@rgb,\%p_material);

      @rgb2 = map { $_ / 255} @rgb2;

      #@rgb2 = map { $_ * $alpha } @rgb2;

      $image->[0]->setPixel(x=>$x, y=>$y, color=>\@rgb2);
    } else {
      $image->[0]->setPixel(x=>$x, y=>$y, channel=>'Alpha', color=>[1]);
    }
  }
}

$image->[0]->Composite(image=>$image->[2]);

my $filename = "test.png";
$image->Write(filename=>$filename);


exit;

__END__

"617":{"name":"Green","base_rgb":[128,
26,
26],"cloth":{"brightness":-2,"contrast":1,"hue":135,"saturation":0.546875,"lightness":0.976563,

"139":{"name":"Violet","base_rgb":[128,
26,
26],"cloth":{"brightness":4,"contrast":1,"hue":240,"saturation":0.625,"lightness":1.09375,