use Modern::Perl '2014';

=pod

=head1 DESCRIPTION

This subclass of GuildWars2::API::Objects defines the Guild and Guild::Emblem
objects.

=cut

####################
# Guild
####################
package GuildWars2::API::Objects::Guild;
use Moose;
use Moose::Util::TypeConstraints;

use GuildWars2::API::Utils;

subtype 'My::GuildWars2::API::Objects::Guild::Emblem' => as class_type('GuildWars2::API::Objects::Guild::Emblem');

coerce 'My::GuildWars2::API::Objects::Guild::Emblem'
  => from 'HashRef'
  => via { GuildWars2::API::Objects::Guild::Emblem->new( %{$_} ) };

=pod

=head1 CLASSES

=head2 Guild

The Guild object represents a guild in Guild Wars 2. It is returned by the $api-
>get_guild() method.

=head3 Attributes

=over

=item guild_id

The internal ID for the guild. Consists of a string of hexadecimal characters in
the pattern XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX.

=item guild_name

The guild's name. Encoded as UTF8.

=item tag

The guild's tag. Encoded as UTF8, max of 4 characters.

=item emblem

A L</"Guild::Emblem"> object.

=back

=cut

has 'guild_id'        => ( is => 'ro', isa => 'Str', required => 1 );
has 'guild_name'      => ( is => 'ro', isa => 'Str', required => 1 );
has 'tag'             => ( is => 'ro', isa => 'Str', required => 1 );
has 'emblem'          => ( is => 'ro', isa => 'My::GuildWars2::API::Objects::Guild::Emblem', coerce => 1 );


####################
# Guild->Emblem
####################
package GuildWars2::API::Objects::Guild::Emblem;
use Moose;

=pod

=head2 Guild::Emblem

The Guild::Emblem object contains information for generating a guild's emblem.

=head3 Attributes

=over

=item background_id
=item foreground_id

The internal ID numbers of the textures used as the emblem background and foreground.

=item flip_background_horizontal
=item flip_background_vertical
=item flip_foreground_horizontal
=item flip_foreground_vertical

Boolean flags that indicate whether the background or foreground should be
flipped and in which direction(s).

=item background_color_id
=item foreground_primary_color_id
=item foreground_secondary_color_id

The internal ID numbers of the colors used in the guild emblem.

=back

=head3 Methods

=over

=item $emblem->generate( $colors, $emblem_texture_folder )

Generates the guild emblem and returns it as an L<Image::Magick> object, which
can then be writte in the image format of your choice.

The arguments must be a L<\"Colors"> object and a path to the local repository
of emblem base textures. In the example below, C<C:/path/to/emblem_textures>
contains the subfolders C<guild emblems> and C<guild emblem backgrounds>.

 my $guild = $api->get_guild("My Guild Name");

 my %colors = $api->get_colors();

 my $emblem = $guild->emblem->generate(\%colors, "C:/path/to/emblem_textures");

 $emblem->Write(filename=>"C:/path/to/generated_emblems/" . $guild->id . ".png");

=back

=cut

has 'background_id'                 => ( is => 'ro', isa => 'Int',  required => 1 );
has 'foreground_id'                 => ( is => 'ro', isa => 'Int',  required => 1 );
has 'flip_background_horizontal'    => ( is => 'ro', isa => 'Bool', required => 1 );
has 'flip_background_vertical'      => ( is => 'ro', isa => 'Bool', required => 1 );
has 'flip_foreground_horizontal'    => ( is => 'ro', isa => 'Bool', required => 1 );
has 'flip_foreground_vertical'      => ( is => 'ro', isa => 'Bool', required => 1 );
has 'background_color_id'           => ( is => 'ro', isa => 'Int',  required => 1 );
has 'foreground_primary_color_id'   => ( is => 'ro', isa => 'Int',  required => 1 );
has 'foreground_secondary_color_id' => ( is => 'ro', isa => 'Int',  required => 1 );

around 'BUILDARGS', sub {
  my ($orig, $class, %args) = @_;
  if(my $flags = delete $args{flags}) {
    $args{flip_background_horizontal} = in("FlipBackgroundHorizontal", $flags) ? 1 : 0;
    $args{flip_background_vertical}   = in("FlipBackgroundVertical",   $flags) ? 1 : 0;
    $args{flip_foreground_horizontal} = in("FlipForegroundHorizontal", $flags) ? 1 : 0;
    $args{flip_foreground_vertical}   = in("FlipForegroundVertical",   $flags) ? 1 : 0;
  }

  $class->$orig(%args);
};

sub generate {
  my ($self, $colors, $source_folder) = @_;

  # Only allow image generation if Image::Magick is available
  my $generate_ok = eval {require Image::Magick} ? 1 : 0;
  Carp::croak("ImageMagick is not installed, you can't generate guild emblems!") if !$generate_ok;

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

  my $image = Image::Magick->new;
  $image->Set(size=>'256x256');

  my $error = $image->Read(
    'xc:none',                                            # 0
    $source_folder."/guild emblems/".$base_png,           # 1
    $source_folder."/guild emblems/".$primary_mask,       # 2
    'xc:none',                                            # 3
    $source_folder."/guild emblems/".$base_png,           # 4
    $source_folder."/guild emblems/".$secondary_mask,     # 5
    $source_folder."/guild emblem backgrounds/".$bg_png   # 6
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

  # Perform color transforms
  _transform_image($image, 0, 2, $colors->{$fg_color_id1}->cloth);
  _transform_image($image, 3, 5, $colors->{$fg_color_id2}->cloth);
  _transform_image($image, 6, 6, $colors->{$bg_color_id}->cloth);

  # Composite foreground primary onto secondary
  $image->[0]->Composite(image=>$image->[3]);

  # Perform flip/flops
  $image->[0]->Flop() if $flip_fg_h;
  $image->[0]->Flip() if $flip_fg_v;
  $image->[6]->Flop() if $flip_bg_h;
  $image->[6]->Flip() if $flip_bg_v;

  # Composite foreground onto background
  $image->[6]->Composite(image=>$image->[0]);

  # Explicitly reclaim memory by deleting all but the final image
  for my $i (0..5) {
    undef $image->[$i];
  }

  return $image->[6];
}

sub _transform_image {
  my ($image, $base, $alpha, $material) = @_;
  foreach my $x ( 0 .. 256 ) {
    foreach my $y ( 0 .. 256 ) {
      my ($alpha) = $image->[$alpha]->getPixel(x=>$x, y=>$y);

      if ($alpha > 0) {
        my @rgb = $image->[$base]->getPixel(x=>$x, y=>$y);

        @rgb = map { $_ * 255} @rgb;

        my @rgb2 = $material->apply_transform(@rgb)->as_array();

        @rgb2 = map { $_ / 255} @rgb2;

        $image->[$base]->setPixel(x=>$x, y=>$y, color=>\@rgb2);
      }
    }
  }
}

1;
