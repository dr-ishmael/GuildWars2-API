use Carp ();
use Modern::Perl '2012';

package GuildWars2::API::Objects::Linkable;
use namespace::autoclean;
use Moose::Role;

use MIME::Base64;

# Consuming class must define a _gl_data method that returns the array ($type, $id).
requires '_gl_data';

# Store the generated game link so it only has to be computed once.
has '_game_link'       => ( is => 'ro', isa => 'Str', writer => '_set_game_link', );

sub game_link {
  my ($self) = @_;

  return $self->_game_link if defined $self->_game_link;

  my ($type, $id) = $self->_gl_data();

  $type = sprintf('%02x',$type);
  $type .= '01' if $type eq '02'; # use default quantity of 1 for item links

  $id = sprintf('%08x',$id);
  $id = substr($id,6,2) . substr($id,4,2) . substr($id,2,2) . substr($id,0,2);

  my $gl = '[&' . encode_base64( pack('H*', $type.$id), '' ) . ']';

  $self->_set_game_link($gl);

  return $gl;
}

1;
