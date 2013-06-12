use Modern::Perl '2012';

package GuildWars2::API::Guild;
use Carp ();

use Moose;
use Moose::Util::TypeConstraints;

subtype 'My::GuildWars2::API::Guild::Emblem' => as class_type('GuildWars2::API::Guild::Emblem');

coerce 'My::GuildWars2::API::Guild::Emblem'
  => from 'HashRef'
  => via { GuildWars2::API::Guild::Emblem->new( %{$_} ) };

has 'guild_id'        => ( is => 'ro', isa => 'Str', required => 1 );
has 'guild_name'      => ( is => 'ro', isa => 'Str', required => 1 );
has 'tag'             => ( is => 'ro', isa => 'Str', required => 1 );
has 'emblem'          => ( is => 'ro', isa => 'My::GuildWars2::API::Guild::Emblem', coerce => 1 );



package GuildWars2::API::Guild::Emblem;
use Moose;


has 'background_id'                 => ( is => 'ro', isa => 'Int', required => 1 );
has 'foreground_id'                 => ( is => 'ro', isa => 'Int', required => 1 );
has 'flip_background_horizontal'    => ( is => 'ro', isa => 'Bool', required => 1 );
has 'flip_background_vertical'      => ( is => 'ro', isa => 'Bool', required => 1 );
has 'flip_foreground_horizontal'    => ( is => 'ro', isa => 'Bool', required => 1 );
has 'flip_foreground_vertical'      => ( is => 'ro', isa => 'Bool', required => 1 );
has 'background_color_id'           => ( is => 'ro', isa => 'Int', required => 1 );
has 'foreground_primary_color_id'   => ( is => 'ro', isa => 'Int', required => 1 );
has 'foreground_secondary_color_id' => ( is => 'ro', isa => 'Int', required => 1 );

around 'BUILDARGS', sub {
  my ($orig, $class, %args) = @_;
  if(my $flags = delete $args{flags}) {
    $args{flip_background_horizontal} = "FlipBackgroundHorizontal" ~~ @$flags ? 1 : 0;
    $args{flip_background_vertical}   = "FlipBackgroundVertical"   ~~ @$flags ? 1 : 0;
    $args{flip_foreground_horizontal} = "FlipForegroundHorizontal" ~~ @$flags ? 1 : 0;
    $args{flip_foreground_vertical}   = "FlipForegroundVertical"   ~~ @$flags ? 1 : 0;
  }

  $class->$orig(%args);
};

sub generate {
  my ($self, $colors, $source_folder) = @_;

  # Only allow image generation if Image::Magick is available
  my $generate_ok = eval {require Image::Magick} ? 1 : 0;
  Carp::croak("ImageMagick is not installed, you can't generate guild emblems!") if !$generate_ok;

  use GuildWars2::Color qw/ colorShiftMatrix compositeColorShiftRgb /;

  # Sanity checks on emblem texture folder
  Carp::croak("You must provide a source_folder in order to generate guild emblems.")
    if !defined($source_folder);

  Carp::croak("source_folder [$source_folder] does not exist!")     if ! -e $source_folder;
  Carp::croak("source_folder [$source_folder] is not a directory!") if ! -d $source_folder;

  Carp::croak("source_folder [$source_folder] doesn't have expected subfolders!")
    if ! -e "$source_folder/guild emblems"
    || ! -d "$source_folder/guild emblems"
    || ! -e "$source_folder/guild emblem backgrounds"
    || ! -d "$source_folder/guild emblem backgrounds"
  ;

  my $bg_id           = $self->background_id;
  my $fg_id           = $self->foreground_id;
  my $bg_color_id     = $self->background_color_id;
  my $fg_color_id1    = $self->foreground_primary_color_id;
  my $fg_color_id2    = $self->foreground_secondary_color_id;
  my $flip_bg_h       = $self->flip_background_horizontal;
  my $flip_bg_v       = $self->flip_background_vertical;
  my $flip_fg_h       = $self->flip_foreground_horizontal;
  my $flip_fg_v       = $self->flip_foreground_vertical;

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
    $source_folder."/guild emblems/".$base_png,          # 1
    $source_folder."/guild emblems/".$primary_mask,      # 2
    'xc:none',                                # 3
    $source_folder."/guild emblems/".$base_png,          # 4
    $source_folder."/guild emblems/".$secondary_mask,    # 5
    $source_folder."/guild emblem backgrounds/".$bg_png  # 6
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
  my @p_matrix = colorShiftMatrix($p_material);
  foreach my $x ( 0 .. 256 ) {
    foreach my $y ( 0 .. 256 ) {
      my ($alpha) = $image->[2]->getPixel(x=>$x, y=>$y);

      if ($alpha > 0) {
        my @rgb = $image->[0]->getPixel(x=>$x, y=>$y);

        @rgb = map { $_ * 255} @rgb;

        my @rgb2 = compositeColorShiftRgb(\@rgb,\@p_matrix);

        @rgb2 = map { $_ / 255} @rgb2;

        $image->[0]->setPixel(x=>$x, y=>$y, color=>\@rgb2);
      }
    }
  }

  # Secondary
  my @s_matrix = colorShiftMatrix($s_material);
  foreach my $x ( 0 .. 256 ) {
    foreach my $y ( 0 .. 256 ) {
      my ($alpha) = $image->[5]->getPixel(x=>$x, y=>$y);

      if ($alpha > 0) {
        my @rgb = $image->[3]->getPixel(x=>$x, y=>$y);

        @rgb = map { $_ * 255} @rgb;

        my @rgb2 = compositeColorShiftRgb(\@rgb,\@s_matrix);

        @rgb2 = map { $_ / 255} @rgb2;

        $image->[3]->setPixel(x=>$x, y=>$y, color=>\@rgb2);
      }
    }
  }

  # Background
  my @b_matrix = colorShiftMatrix($b_material);
  foreach my $x ( 0 .. 256 ) {
    foreach my $y ( 0 .. 256 ) {
      my ($alpha) = $image->[6]->getPixel(x=>$x, y=>$y);

      if ($alpha > 0) {
        my @rgb = $image->[6]->getPixel(x=>$x, y=>$y);

        @rgb = map { $_ * 255} @rgb;

        my @rgb2 = compositeColorShiftRgb(\@rgb,\@b_matrix);

        @rgb2 = map { $_ / 255} @rgb2;

        $image->[6]->setPixel(x=>$x, y=>$y, color=>\@rgb2);
      }
    }
  }

  # Composite foreground primary onto secondary
  $image->[0]->Composite(image=>$image->[3]);

  $image->[0]->Flop() if $flip_fg_h;
  $image->[0]->Flip() if $flip_fg_v;
  $image->[6]->Flop() if $flip_bg_h;
  $image->[6]->Flip() if $flip_bg_v;

  # Composite foreground onto background
  $image->[6]->Composite(image=>$image->[0]);

  return $image->[6];
}

1;
