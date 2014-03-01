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

###########################################
### TODO                                ###
### rewrite this for the OO version     ###
###########################################
=pod

=head1 NAME

GuildWars2::GameLink - A function library for encoding and decoding Guild Wars 2
game links

=head1 SYNOPSIS

 use GuildWars2::GameLink qw/decode_gl encode_gl/;

 # Encode a game link for a Copper Harvesting Sickle
 #   type = item
 #     id = 23029

 $output = encode_gl(2, 23029);

 print $output;  # [&AgH1WQAA]

 # Decode a game link

 @output = decode_gl('[&BEgAAAA=]');

 print "$output[0] $output[1]";  # 4 72
                                 # type = 4  = map
                                 #   id = 72 = Desider Atum Waypoint

=head1 DESCRIPTION

GuildWars2::GameLink provides a pair of functions for encoding and decoding
Guild Wars 2 game links (aka chat links). The core function is a conversion
to/from Base64, although the plaintext is a byte string representing integers
(rather than actual text), thus composing the plaintext itself requires some
extra work.

=head1 Functions

=over

=item encode( $type, $id )

Encodes a game link for the given type and ID and returns it as a string.

Known types are listed below; both the numeric and string representations are
supported.

 Numeric   String
 -------   ------
       1   coin
       2   item
       3   text
       4   map
       7   skill
       8   trait
      10   recipe

=item decode( $game_link )

Decodes a game link and returns an array containing the type and ID. If the type
is 2 (item), a third element is returned containing the item's quantity.

=back

=head1 Author

Tony Tauer, E<lt>dr.ishmael[at]gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2013 by Tony Tauer

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__END__
