use Modern::Perl '2012';

package GuildWars2::GameLink;

BEGIN
{
  require Exporter;
  # set the version for version checking
  $GuildWars2::GameLink::VERSION     = '0.50';
  # Inherit from Exporter to export functions and variables
  our @ISA         = qw(Exporter);
  # Functions and variables which are exported by default
  our @EXPORT      = ();
  # Functions and variables which can be optionally exported
  our @EXPORT_OK   = qw(decode_gl encode_gl);
}

use Carp ();
use MIME::Base64;

sub decode_gl {
  my ($gl) = @_;

  my @decoded = unpack('(H2)*', decode_base64($gl));

  my $type = hex shift @decoded;

  my $quantity;

  $quantity = hex shift @decoded if $type == 2;

  my $id4 = shift @decoded;
  my $id3 = shift @decoded;
  my $id2 = shift @decoded;
  my $id1 = shift @decoded;

  my $id = hex $id1 . $id2 . $id3 . $id4;

  my @result = ($type, $id, $quantity);

  return @result;
}

sub encode_gl {
  my ($a, $b) = @_;

  my ($type, $id);

  if (ref($a) eq "HASH") {
    if(defined($a->{item_id})) {
      $type = 2;
      $id = $a->{item_id};
    } elsif (defined($a->{recipe_id})) {
      $type = 9;
      $id = $a->{recipe_id};
    } else {
      Carp::croak("Unrecognized structure (not item or recipe) passed to encode_game_link()");
    }
  } elsif (ref($a)) {
    Carp::croak("First argument to encode_game_link() must be scalar or hash ref; found " . ref($a));
  } else {
    for (lc($a)) {
      $type = 1 when 'coin';
      $type = 2 when 'item';
      $type = 3 when 'text';
      $type = 4 when 'map';
      # $type = 5 when ???;
      $type = 6 when 'skill';
      # $type = 7 when 'player';
      $type = 8 when 'trait';
      $type = 9 when 'recipe';
      $type = $a when /[1234689]/;
      default { Carp::croak("Unrecognized type [$a] passed to encode_game_link()") }
    }
    $id = $b;
  }

  $type = sprintf('%02x',$type);
  $type .= '01' if $type eq '02'; # use default quantity of 1 for item links

  $id = sprintf('%08x',$id);
  $id = substr($id,6,2) . substr($id,4,2) . substr($id,2,2) . substr($id,0,2);

  my $gl = '[&' . encode_base64( pack('H*', $type.$id), '' ) . ']';

  return $gl;
}



1;
