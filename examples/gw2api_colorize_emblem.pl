#!perl -w

use strict;


use GW2API;

use Image::Magick;


my $api = GW2API->new;

my %colors = $api->colors;

my $base_png        = "C:\\Users\\Tony\\Pictures\\GW2\\guild emblems\\59642.png";
my $primary_mask    = "C:\\Users\\Tony\\Pictures\\GW2\\guild emblems\\59644.png";
my $secondary_mask  = "C:\\Users\\Tony\\Pictures\\GW2\\guild emblems\\59646.png";



my $image = Image::Magick->new;
$image->Set(size=>'256x256');

$image->ReadImage("C:\\Users\\Tony\\Pictures\\GW2\\guild emblems\\59642.png",
                  "C:\\Users\\Tony\\Pictures\\GW2\\guild emblems\\59644.png",
                  "C:\\Users\\Tony\\Pictures\\GW2\\guild emblems\\59646.png"
);



# Primary
#my %p_material = (brightness=>-2,contrast=>1,hue=>135,saturation=>0.546875,lightness=>0.976563);
#foreach my $x ( 0 .. 256 ) {
#    foreach my $y ( 0 .. 256 ) {
#        my @rgb = $image->[0]->getPixel(x=>$x, y=>$y);
#
##print join(',', @rgb);
#
#        my @rgb2 = $api->anetcolor->compositeColorShiftRgb(\@rgb,\%p_material);
#
##print join(',', @rgb2);
#
#        #my ($alpha) = $image->[1]->getPixel(x=>$x, y=>$y);
#
#        #$alpha /= 255;
#
#        #@rgb2 = map { $_ * $alpha } @rgb2;
#
#        $image->[0]->setPixel(x=>$x, y=>$y, color=>\@rgb2);
#    }
#}

# Secondary
my %s_material = (brightness=>4,contrast=>1,hue=>240,saturation=>0.625,lightness=>1.09375);
foreach my $x ( 0 .. 256 ) {
    foreach my $y ( 0 .. 256 ) {
        my @rgb = $image->[0]->getPixel(x=>$x, y=>$y);

        my ($r2,$g2,$b2) = $api->anetcolor->compositeColorShiftRgb(\@rgb,\%s_material);
#
#        my ($alpha) = $image->[2]->getPixel(x=>$x, y=>$y);
#
#        $alpha /= 255;
#
#        ($r2,$g2,$b2) = map { $_ * $alpha } ($r2,$g2,$b2);
#
        $image->[0]->setPixel(x=>$x, y=>$y, color=>[$r2,$g2,$b2]);
    }
}


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