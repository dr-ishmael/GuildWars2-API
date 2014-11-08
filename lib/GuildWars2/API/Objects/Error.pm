use Modern::Perl '2014';

=pod

=head1 DESCRIPTION

This subclass of GuildWars2::API::Objects defines the error object, for when the
API returns an error.

=cut

package GuildWars2::API::Objects::Error;
use namespace::autoclean;
use Moose;

has 'error'                 => ( is => 'ro', isa => 'Int' );
has 'product'               => ( is => 'ro', isa => 'Int' );
has 'module'                => ( is => 'ro', isa => 'Int' );
has 'line'                  => ( is => 'ro', isa => 'Int' );
has 'text'                  => ( is => 'ro', isa => 'Str' );

1;
