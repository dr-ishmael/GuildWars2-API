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
      $type = 10;
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
      $type = 7 when 'skill';
      $type = 8 when 'trait';
      # $type = 9 when 'player';
      $type = 10 when 'recipe';
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
