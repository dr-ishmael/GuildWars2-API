use Modern::Perl '2014';

package GuildWars2::API::Objects;
BEGIN {
  $GuildWars2::API::Objects::VERSION = '0.50';
}
use Moose;

=pod

=head1 DESCRIPTION

This class and its subclasses define the objects that can be returned from
GuildWars2::API. Some objects also have methods attached to them.

=head1 SUBCLASSES

See the individual modules for documentation of these subclasses.

=item * GuildWars2::API::Objects::Color
=item * GuildWars2::API::Objects::Guild
=item * GuildWars2::API::Objects::Item
=item * GuildWars2::API::Objects::Map
=item * GuildWars2::API::Objects::Recipe

This module defines a role for use by multiple object types.

=item * GuildWars2::API::Objects::Linkable

=cut

use GuildWars2::API::Objects::Color;
use GuildWars2::API::Objects::Guild;
use GuildWars2::API::Objects::Item;
use GuildWars2::API::Objects::Map;
use GuildWars2::API::Objects::Recipe;
use GuildWars2::API::Objects::Skin;

use GuildWars2::API::Objects::Linkable;

1;

