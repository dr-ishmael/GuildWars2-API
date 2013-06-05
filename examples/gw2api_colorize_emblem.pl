#!perl -w

use strict;

use 5.14.0;

use GW2API;
use Image::Magick;

my $api = GW2API->new(nocache => 1);

my %colors = $api->colors;

# defaults for unit testing
my $bg_id = 2;
my $fg_id = 58;
my $bg_color_id = 584;
my $fg_color_id1 = 617;
my $fg_color_id2 = 139;

my $flags = ["FlipForegroundVertical"];

my $outfile= "test.png";

if (defined($ARGV[0])) {
  my %guild_details = $api->guild_details($ARGV[0]);
  $bg_id        = $guild_details{emblem}->{background_id};
  $fg_id        = $guild_details{emblem}->{foreground_id};
  $bg_color_id  = $guild_details{emblem}->{background_color_id};
  $fg_color_id1 = $guild_details{emblem}->{foreground_primary_color_id};
  $fg_color_id2 = $guild_details{emblem}->{foreground_secondary_color_id};

  $flags        = $guild_details{emblem}->{flags};

  ($outfile= "$guild_details{guild_id}.png") =~ s/ /_/g;
}

my $base_png        = "C:\\Users\\ttauer\\Pictures\\GW2\\guild emblems\\".$fg_id.".png";
my $primary_mask    = "C:\\Users\\ttauer\\Pictures\\GW2\\guild emblems\\".$fg_id."a.png";
my $secondary_mask  = "C:\\Users\\ttauer\\Pictures\\GW2\\guild emblems\\".$fg_id."b.png";
my $bg_png          = "C:\\Users\\ttauer\\Pictures\\GW2\\guild emblem backgrounds\\".$bg_id.".png";


my $b_material = $colors{$bg_color_id}->{cloth};
my $p_material = $colors{$fg_color_id1}->{cloth};
my $s_material = $colors{$fg_color_id2}->{cloth};


my $image = Image::Magick->new;
$image->Set(size=>'256x256');

$image->ReadImage('xc:none',        # 0
                  $base_png,        # 1
                  $primary_mask,    # 2
                  'xc:none',        # 3
                  $base_png,        # 4
                  $secondary_mask,  # 5
                  $bg_png           # 6
);


# Mask primary color zone onto base canvas
$image->[2]->Level(levels=>"50%,50%");
$image->[2]->Set(alpha=>"copy");
$image->[0]->Composite(image=>$image->[1], mask=>$image->[2]);

# Mask secondary color zone onto base canvas
$image->[5]->Level(levels=>"50%,50%");
$image->[5]->Set(alpha=>"copy");
$image->[3]->Composite(image=>$image->[4], mask=>$image->[5]);


# Primary
my @p_matrix = $api->anetcolor->colorShiftMatrix($p_material);
foreach my $x ( 0 .. 256 ) {
  foreach my $y ( 0 .. 256 ) {
    my ($alpha) = $image->[2]->getPixel(x=>$x, y=>$y);

    if ($alpha > 0) {
      my @rgb = $image->[0]->getPixel(x=>$x, y=>$y);

      @rgb = map { $_ * 255} @rgb;

      my @rgb2 = $api->anetcolor->compositeColorShiftRgb(\@rgb,\@p_matrix);

      @rgb2 = map { $_ / 255} @rgb2;

      $image->[0]->setPixel(x=>$x, y=>$y, color=>\@rgb2);
    }
  }
}

# Secondary
my @s_matrix = $api->anetcolor->colorShiftMatrix($s_material);
foreach my $x ( 0 .. 256 ) {
  foreach my $y ( 0 .. 256 ) {
    my ($alpha) = $image->[5]->getPixel(x=>$x, y=>$y);

    if ($alpha > 0) {
      my @rgb = $image->[3]->getPixel(x=>$x, y=>$y);

      @rgb = map { $_ * 255} @rgb;

      my @rgb2 = $api->anetcolor->compositeColorShiftRgb(\@rgb,\@s_matrix);

      @rgb2 = map { $_ / 255} @rgb2;

      $image->[3]->setPixel(x=>$x, y=>$y, color=>\@rgb2);
    }
  }
}

# Background
my @b_matrix = $api->anetcolor->colorShiftMatrix($b_material);
foreach my $x ( 0 .. 256 ) {
  foreach my $y ( 0 .. 256 ) {
    my ($alpha) = $image->[6]->getPixel(x=>$x, y=>$y);

    if ($alpha > 0) {
      my @rgb = $image->[6]->getPixel(x=>$x, y=>$y);

      @rgb = map { $_ * 255} @rgb;

      my @rgb2 = $api->anetcolor->compositeColorShiftRgb(\@rgb,\@b_matrix);

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


$image->[6]->Write(filename=>"C:\\Users\\ttauer\\Documents\\scripts\\GW2API\\guild emblems\\$outfile");


exit;
