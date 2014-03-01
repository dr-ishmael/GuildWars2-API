use Modern::Perl '2012';

package GuildWars2::API;
BEGIN {
  $GuildWars2::API::VERSION     = '0.50';
}
use Carp ();
use CHI;
use GuildWars2::API::Objects;
use JSON::PP;
use List::Util qw/max min/;
use LWP::UserAgent;

use Moose;
use Moose::Util qw( with_traits );
use Moose::Util::TypeConstraints;

####################
# Local constants
####################

my $_api_version          = 'v1';

my $_base_url             = 'https://api.guildwars2.com/' . $_api_version;
my $_base_render_url      = "https://render.guildwars2.com/file";

# Pagenames of the available interfaces
my $_url_build            = 'build.json';

my $_url_events           = 'events.json';
my $_url_event_details    = 'event_details.json';
my $_url_event_names      = 'event_names.json';

my $_url_continents       = 'continents.json';
my $_url_maps             = 'maps.json';
my $_url_map_floor        = 'map_floor.json';
my $_url_map_names        = 'map_names.json';

my $_url_world_names      = 'world_names.json';

my $_url_matches          = 'wvw/matches.json';
my $_url_match_details    = 'wvw/match_details.json';
my $_url_objective_names  = 'wvw/objective_names.json';

my $_url_items            = 'items.json';
my $_url_item_details     = 'item_details.json';

my $_url_recipes          = 'recipes.json';
my $_url_recipe_details   = 'recipe_details.json';

my $_url_guild_details    = 'guild_details.json';

my $_url_colors           = 'colors.json';

my $_url_files            = 'files.json';


# Supported languages
enum 'Lang', [qw(de en es fr)];

####################
# Attributes
####################


has 'timeout'         => ( is => 'rw', isa => 'Int', default => 30 );
has 'retries'         => ( is => 'rw', isa => 'Int', default => 3 );
has 'language'        => ( is => 'rw', isa => 'Lang', default => 'en' );
has 'nocache'         => ( is => 'ro', isa => 'Bool', default => undef );
has 'cache_dir'       => ( is => 'ro', isa => 'Str', default => './gw2api-cache' );
has 'cache_age'       => ( is => 'rw', isa => 'Str', default => '7 days' );
has 'event_cache_age' => ( is => 'rw', isa => 'Str', default => '30 seconds' );
has 'wvw_cache_age'   => ( is => 'rw', isa => 'Str', default => '5 minutes' );
has 'json'            => ( is => 'ro', isa => 'JSON::PP', default => sub{ JSON::PP->new } );
has 'ua'              => ( is => 'ro', isa => 'LWP::UserAgent', default => sub{ LWP::UserAgent->new } );
has 'cache'           => ( is => 'ro', isa => 'Maybe[CHI::Driver::File]', lazy => 1, builder => '_init_cache' );
has '_status'         => ( is => 'ro', isa => 'Bool', default => 1, writer => '_set_status', reader => 'is_success' );


####################
# Init methods
####################

sub _init_cache {
  my $self = shift;

  unless (defined $self->nocache) {
    # If it exists...
    if ( -e $self->cache_dir ) {
      # ... make sure it's a directory
      if ( ! -d $self->cache_dir ) {
        Carp::croak "Cache_dir [$self->cache_dir] is not a directory";
      }
      # ... make sure it's writeable
      if ( ! -w $self->cache_dir ) {
        Carp::croak "Unable to write to cache_dir [$self->cache_dir]";
      }
    # Otherwise, attempt to create it
    } else {
      mkdir $self->cache_dir or Carp::croak "Failed to create cache_dir [$self->cache_dir]: $!\n";
    }
    return CHI->new( driver => 'File', root_dir => $self->cache_dir );
  }
  return undef;
}


####################
# Core methods
####################

sub _api_request {
  my ($self, $interface, $parms, $cache_age) = @_;

  my $parm_string = "";

  if ($parms) {
    my @parm_pairs;
    foreach my $k (sort keys %$parms) {  # sort necessary so that cache keys are deterministic
      push @parm_pairs, "$k=$parms->{$k}";
    }
    $parm_string = '?' . join('&', @parm_pairs)
  }

  my $url = $_base_url . '/' . $interface . $parm_string;

  my $response;

  # Check in CHI cache first
  $response = $self->cache->get($url) unless defined $self->{nocache};

  if ( !defined $response ) {

    $self->_set_status(0);

    # If not in cache, send GET request to API
    $self->ua->timeout($self->{timeout});

    for (my $i = 0; $i < $self->{retries}; $i++) {
      $response = $self->ua->get($url);

      last if $response->is_success();
    }

    # If no response or error after using up retries, die
    if (!defined($response)) {
      Carp::carp "Error getting URL [$url]:\n" . $response->status_line();
      $self->cache->remove($url) unless defined $self->{nocache};
      return undef;
    }

    $response = $response->decoded_content();

    # Set the CHI cache for this $url for efficient future access
    $cache_age = $self->{cache_age} unless defined $cache_age;
    $self->cache->set($url, $response, $cache_age) unless defined $self->{nocache};
  }

  my $decoded;
  eval { $decoded = $self->json->decode ($response) };
  if ($@) {
    Carp::carp "Error decoding JSON for URL [$url]:\n" . $@;
    $self->cache->remove($url) unless defined $self->{nocache};
    return undef;
  }

  if (defined($decoded->{error})) {
    Carp::carp "API error at [$url]";
    $self->cache->remove($url) unless defined $self->{nocache};
  } else {
    $self->_set_status(1);
  }

  return $decoded;
}


####################
# API accessor methods
####################

sub build {
 my ($self) = @_;

  my $json = $self->_api_request($_url_build);

  return $json->{build_id};
}

sub _generic_names {
 my ($self, $interface, $lang) = @_;

  if (defined $lang) {
    $lang = $self->_check_language($lang);
  } else {
    $lang = $self->{language};
  }

  my $json = $self->_api_request($interface, { lang => $lang } );

  return undef if !$self->is_success();

  my $names = {};

  foreach my $subject (@$json) {
    my $id    = $subject->{id};
    my $name  = $subject->{name};

    $names->{$id} = $name;
  }

  return %$names;
}

sub event_names {
  my ($self, $lang) = @_;

  return $self->_generic_names($_url_event_names, $lang);
}

sub map_names {
  my ($self, $lang) = @_;

  return $self->_generic_names($_url_map_names, $lang);
}

sub world_names {
  my ($self, $lang) = @_;

  return $self->_generic_names($_url_world_names, $lang);
}

sub objective_names {
  my ($self, $lang) = @_;

  return $self->_generic_names($_url_objective_names, $lang);
}


sub event_state {
  my ($self, $event_id, $world_id) = @_;

  # Sanity checks on event_id
  Carp::croak("You must provide an event ID")
    unless defined $event_id;

  Carp::croak("Given event ID [$event_id] does not match event ID pattern")
    unless $event_id =~ /^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$/i;

  # Sanity check on world_id
  Carp::croak("Given world ID [$world_id] is not a positive integer")
    unless $world_id =~ /^\d+$/;

  my $json = $self->_api_request($_url_events, { event_id => $event_id, world_id => $world_id }, $self->event_cache_age );

  Carp::croak("No results for event ID [$event_id] and world ID [$world_id]")
    unless @{$json->{events}} > 0;

  return $json->{events}->[0]->{state};
}


sub event_state_by_world {
  my ($self, $event_id) = @_;

  # Sanity checks on event_id
  Carp::croak("You must provide an event ID")
    unless defined $event_id;

  Carp::croak("Given event ID [$event_id] does not match event ID pattern")
    unless $event_id =~ /^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$/i;

  my $json = $self->_api_request($_url_events, { event_id => $event_id }, $self->event_cache_age );

  Carp::croak("No results for event ID [$event_id]")
    unless @{$json->{events}} > 0;

  my $event_state_by_world = {};

  foreach my $event (@{$json->{events}}) {
    my $world_id  = $event->{world_id};
    my $state     = $event->{state};

    $event_state_by_world->{$world_id} = $state;
  }

  return %$event_state_by_world;
}

sub event_states_in_map {
  my ($self, $map_id, $world_id) = @_;

  # Sanity checks on map_id
  Carp::croak("You must provide a map ID")
    unless defined $map_id;

  Carp::croak("Given map ID [$map_id] is not a positive integer")
    unless $map_id =~ /^\d+$/;

  # Sanity checks on world_id
  Carp::croak("You must provide a world ID")
    unless defined $world_id;

  Carp::croak("Given world ID [$world_id] is not a positive integer")
    unless $world_id =~ /^\d+$/;

  my $json = $self->_api_request($_url_events, { map_id  => $map_id, world_id => $world_id }, $self->event_cache_age );

  Carp::croak("No results for map ID [$map_id] and world ID [$world_id]")
    unless @{$json->{events}} > 0;

  my $event_states = {};

  foreach my $event (@{$json->{events}}) {
    my $event_id  = $event->{event_id};
    my $state     = $event->{state};

    $event_states->{$event_id} = $state;
  }

  return %$event_states;
}


sub wvw_matches {
  my ($self) = @_;

  my $json = $self->_api_request($_url_matches);

  return @{$json->{wvw_matches}};
}


sub wvw_match_details {
  my ($self, $match_id) = @_;

  # Sanity checks on match_id
  Carp::croak("You must provide a match ID")
    unless defined $match_id;

  Carp::croak("Given match ID [$match_id] is invalid")
    unless $match_id =~ /^[12]-[1-9]$/i;

  my $json = $self->_api_request($_url_match_details, { match_id => $match_id }, "5 minutes" );

  return %$json;
}


sub list_items {
  my ($self) = @_;

  my $json = $self->_api_request($_url_items);

  return @{$json->{items}};
}


sub get_item {
  my ($self, $item_id, $lang) = @_;

  # Sanity checks on item_id
  Carp::croak("You must provide an item ID")
    unless defined $item_id;

  Carp::croak("Given item ID [$item_id] is not a positive integer")
    unless $item_id =~ /^\d+$/;

  if (defined $lang) {
    $lang = $self->_check_language($lang);
  } else {
    $lang = $self->{language};
  }

  my $json = $self->_api_request($_url_item_details, { lang => $lang, item_id => $item_id } );

  # Convert CamelCase type value to lower_case subobject name
  (my $tx = $json->{type}) =~ s/([a-z])([A-Z])/${1}_$2/g;
  $tx = lc($tx);

  # Standardize name of type-specific subobject
  if (my $a = delete $json->{$tx}) { $json->{type_data} = $a; }

  my $item;
  # Instantiate the class with special roles for certain types
  my @special_types = qw/ armor back bag consumable tool trinket upgrade_component weapon /;
  if ($tx ~~ @special_types) {
    $item = with_traits(
      'GuildWars2::API::Objects::Item',
      (
        "GuildWars2::API::Objects::Item::" . $json->{type},
      ),
    )->new( $json );
  } else {
    # If it's not a special type, instantiate as a plain item
    $item = GuildWars2::API::Objects::Item->new($json);
  }

  return $item;
}


sub list_recipes {
  my ($self) = @_;

  my $json = $self->_api_request($_url_recipes);

  return @{$json->{recipes}};
}


sub get_recipe {
  my ($self, $recipe_id) = @_;

  # Sanity checks on recipe_id
  Carp::croak("You must provide a recipe ID")
    unless defined $recipe_id;

  Carp::croak("Given recipe ID [$recipe_id] is not a positive integer")
    unless $recipe_id =~ /^\d+$/;

  my $json = $self->_api_request($_url_recipe_details, { recipe_id => $recipe_id } );

  my $recipe = GuildWars2::API::Objects::Recipe->new( $json );

  return $recipe;
}


sub get_colors {
  my ($self, $lang) = @_;

  if (defined $lang) {
    $lang = $self->_check_language($lang);
  } else {
    $lang = $self->{language};
  }

  my $json = $self->_api_request($_url_colors, { lang => $lang } );

  my %color_objs;
  foreach my $color_id (keys %{$json->{colors}}) {
    $color_objs{$color_id} = GuildWars2::API::Objects::Color->new( $json->{colors}->{$color_id} );
  }

  return %color_objs;
}


sub get_guild {
  my ($self, $guild_id) = @_;

  # Sanity checks on guild_id
  Carp::croak("You must provide a guild ID or guild name")
    unless defined $guild_id;

  my $id_or_name;
  if ($guild_id =~ /^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$/i) {
    $id_or_name = "guild_id";
  } else {
    $guild_id =~ s/ /%20/g;
    $id_or_name = "guild_name";
  }

  my $json = $self->_api_request($_url_guild_details, { $id_or_name => $guild_id });

  return undef if !$self->is_success();

  my $guild_obj = GuildWars2::API::Objects::Guild->new( $json );

  return $guild_obj;
}


sub get_maps {
  my ($self, $continent_id, $floor_id, $lang) = @_;

  if (defined $lang) {
    $lang = $self->_check_language($lang);
  } else {
    $lang = $self->{language};
  }

  if (! defined $continent_id) {
    $continent_id = 1;
  }

  if (! defined $floor_id) {
    $floor_id = 2;
  }

  my $json = $self->_api_request($_url_map_floor, { "continent_id" => $continent_id, "floor" => $floor_id, "lang" => $lang });

  my %map_tree;

  foreach my $region_id (keys %{$json->{regions}}) {
   $map_tree{$region_id} = GuildWars2::API::Objects::Region->new( $json->{regions}->{$region_id} );
  }

  return %map_tree;
}


###
# Experimental stuff past here
###



sub get_icon_url {
  my ($self, $_obj, $_format) = @_;

  # Default to png format
  $_format = "png" if !defined($_format);

  Carp::croak("Unrecognized icon format [$_format]; valid formats are jpg and png.")
    if ($_format ne "png" && $_format ne "jpg");

  return $_base_render_url . '/' . $_obj->{icon_signature} . '/' . $_obj->{file_id} . '.' . $_format;
}

sub get_icon {
  my ($self, $_format) = @_;

  my $render_url = $self->get_icon_url($_format);

### build an icon cache similar to API response cache
}



1;

=pod

=head1 NAME

GuildWars2::API - An interface library for the Guild Wars 2 API

=head1 SYNOPSIS

 use GuildWars2::API;

 $api = GuildWars2::API->new();

 # Check the current state of an event on all worlds

 %event_states = $api->event_state_by_world($event_id);

 foreach my $world_id (keys %event_states) {
     my $state = $event_states{$world_id};

     print "$world_id : $state\n";
 }

 # Lookup the attribute bonuses on a weapon

 %item_details = $api->item_details($item_id);

 $attributes_ref = %item_details{weapon}->{attributes};

 foreach $attribute (@$attributes_ref) {
     ($attr_name, $attr_value) =
          ($attribute->{attribute}, $attribute->{modifier});

     print "+$attr_value $attr_name\n";
 }

=head1 DESCRIPTION

GuildWars2::API is a class module that provides a set of standard interfaces to
the L<Guild Wars 2 API|http://wiki.guildwars2.com/wiki/API:Main>.

=head1 Constructor

=over

=item $api = GuildWars2::API->new
=item $api = GuildWars2::API->new( key => value, ... )

This method constructs a new C<GuildWars2::API> object and returns it. Key/value
pairs of configuration options may be provided, which then become class
attributes.

Each of the attributes can be accessed via an eponymous class method. Most can
also be assigned new values in this manner, although a few attributes are
designated read-only.

 my $api = GuildWars2::API->new( timeout => 60 );

 print $api->timeout;   # 60

 $api->timeout(180);

 print $api->timeout;   # 180

=over

=item timeout [INT]

The length of time, in seconds, to wait for a response from the API. Defaults to
30.

=item retries [INT]

The number of times to attempt an API request before dying. Defaults to 3.

=item language [STRING]

The language code to use for all API requests. Defaults to 'en', other
supported languages are 'de', 'es', and 'fr'. This setting can be overridden
when calling individual API methods.

=item nocache [BOOL]

I<Read-only>. Disable local caching of API responses. Defaults to undef. Using this in
combination with any of the following cache options will cause an error.

=item cache_dir [STRING]

I<Read-only>. The local directory to use as the cache location. Defaults to './gw2api-cache'
and will attempt to create the directory if it does not exist.

=item cache_age [DURATION]

Length of time after which the cached responses will expire. Defaults to '24
hours'. Accepted values are strings consisting of an integer followed by a time
unit, e.g. '1 day' or '10 seconds' etc.

This applies to I<most> of the APIs; the following *_cache_age parameters
override this setting for specific APIs.

=item event_cache_age [DURATION]

Length of time after which the cached version of I<event state> responses will
expire. Defaults to '30 seconds'.

=item wvw_cache_age [DURATION]

Length of time after which the cached version of I<WvW match detail> responses
will expire. Defaults to '5 minutes'.

=back

=back

=head2 Subclassed objects

The following classes are loaded into the GuildWars2::API class and can be
accessed as "subobjects" of the main C<$api> object.

=over

=item L<CHI> - $api->cache

Interface to the file cache handler. Used for storing API responses locally.

=item L<JSON::PP> - $api->json

Interface for encoding/decoding JSON strings. Used to decode the JSON responses
from the API.

=item L<LWP::UserAgent> - $api->ua

HTTP interface. Used for interacting with the API.

=back

=head1 Methods

=over

=item $api->build

Returns the current Guild Wars 2 build number. Useful for tracking when a game
update is released, since the build number will change.

=item $api->event_names
=item $api->event_names( $lang )

=item $api->map_names
=item $api->map_names( $lang )

=item $api->world_names
=item $api->world_names( $lang )

=item $api->objective_names
=item $api->objective_names( $lang )

Each of these methods returns a hash, keyed by the event/map/etc. ID, containing
the names corresponding to those IDs. Pass a language code as an argument to
override the current default language.

=item $api->event_state( $event_id, $world_id )

Returns a string containing the current state of a specific event on a specific
world. Event state will be one of the following values (definitions are from
L<the official API documentation|http://wiki.guildwars2.com/wiki/API:1/events>):

 State        Meaning
 ------------ ---------------------------------------------------------
 Active       The event is running now.
 Inactive     The event is not running now.
 Success      The event has succeeded.
 Fail         The event has failed.
 Warmup       The event is inactive, and will only become active once
              certain criteria are met.
 Preparation  The criteria for the event to start have been met, but
              certain activities (such as an NPC dialogue) have not
              completed yet. After the activites have been completed,
              the event will become Active.

=item $api->event_state_by_world( $event_id )

Returns a hash, keyed by world ID, containing the current state of the given
event on each world.

=item $api->event_states_in_map( $map_id, $world_id )

Returns a hash, keyed by event ID, containing the current state of all events
occurring within a specific map on a specific world.

=item $api->wvw_matches

Returns an array containing basic information on the current WvW matches. Each
array element is a hash with the following structure:

 (
   wvw_match_id   => [STR],     # Match ID
   red_world_id   => [INT],     # World ID of the red world
   blue_world_id  => [INT],     # World ID of the blue world
   green_world_id => [INT],     # World ID of the green world
   start_time     => [STRING],  # Date/time that current match started (UTC)
   end_time       => [STRING],  # Date/time that current match ended (UTC)
 )

=item $api->wvw_match_details( $match_id )

Returns a hash containing detailed information on a specific WvW match. The hash
has the following structure:

 (
   match_id   => [STRING],  # Match ID
   scores     =>
     [
       [INT],               # Red world total score
       [INT],               # Green world total score
       [INT]                # Blue world total score
     ],
   maps       =>            # Array of map data
     [
       {
         type       => [STRING],  # Map type (RedHome, GreenHome, BlueHome, Center)
         scores     =>
           [
             [INT],               # Red world map score
             [INT],               # Green world map score
             [INT]                # Blue world map score
           ],
         objectives =>            # Array of objectives in the map
           [
             {
               id          => [INT],    # Objective ID
               owner       => [STRING], # Current owner of the objective (Red, Blue, Green)
               owner_guild => [STRING], # Guild ID that has claimed the objective
                                        #   (only present if objective has been claimed)
             },
             ...                  # Repeat for all objectives in the map
           ]
       },
       ...                  # Repeat for each of 4 maps
     ],
 )

=item $api->list_items

Returns an array containing all "discovered" item IDs.

=item $api->get_item( $item_id )
=item $api->get_item( $item_id, $lang )

Retrieves data for the given item_id (in the given language or the current
default) and returns a GuildWars2::API::Objects::Item object.

=item $api->list_recipes

Returns an array containing all "discovered" recipe IDs.

=item $api->get_recipe( $recipe_id )
=item $api->get_recipe( $recipe_id, $lang )

Retrieves data for the given recipe_id (in the given language or the current
default) and returns a GuildWars2::API::Objects::Recipe object.

=item $api->get_colors
=item $api->get_colors( $lang )

Returns a hash, keyed on color_id, containing color information for all colors
in the game. Each hash element is a GuildWars2::API::Objects::Color object.

=item $api->get_guild( $guild_id )
=item $api->get_guild( $guild_name )

Retrieves data for the given guild ID or guild name and returns a
GuildWars2::API::Objects::Guild object. If the argument doesn't match the
pattern of a guild ID, it is assumed to be a guild name.

=item $api->get_maps
=item $api->get_maps( $continent_id, $floor_id, $lang )

Retreives a hash, keyed on region_id, containing map information on the world
of Tyria. Each has element is a GuildWars2::API::Objects::Region object.

=back

=head1 Author

Tony Tauer, E<lt>dr.ishmael[at]gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2013 by Tony Tauer

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__END__
