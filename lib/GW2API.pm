package GW2API;

use strict;

use 5.14.0;

our $VERSION     = "0.1";

use CHI;
use JSON::PP;
use List::Util qw/max min/;
use LWP::UserAgent;

use GW2API::AnetColor;

use Carp ();

=pod

=head1 NAME

GW2API - An interface library for the Guild Wars 2 API

=head1 SYNOPSIS

 require GW2API;

 my $api = GW2API->new;

 # Check the current state of an event on all worlds

 my %event_states = $api->event_state_by_world($event_id);

 foreach my $world_id (keys %event_states) {
     my $state = $event_states{$world_id};

     print "$world_id : $state\n";

 }

 # Lookup the attribute bonuses on a weapon

 my %item_details = $api->item_details($item_id);

 my $attributes_ref = %item_details{weapon}->{attributes};

 foreach my $attribute (@$attributes_ref) {
     my ($attr_name, $attr_value) =
          ($attribute->{attribute}, $attribute->{modifier});

     print "+$attr_value $attr_name\n";

 }

=head1 DESCRIPTION

GW2API is a class module that provides a set of standard interfaces to the Guild
Wars 2 API.

=cut

####################
# Constants
####################

# Pagenames of the available interfaces
my $_url_build            = 'build.json';

my $_url_events           = 'events.json';
my $_url_event_names      = 'event_names.json';
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

# Supported languages
my @_languages = qw/de en es fr/;

####################
# Constructor
####################

=pod

=head1 Constructor

=over 4

=item $api = GW2API->new
=item $api = GW2API->new( key => value, ... )

This method constructs a new C<GW2API> object and returns it. Key/value pairs of
configuration options may be provided.

=cut

sub new {
  # Check for common user mistake
  Carp::croak("Options to GW2API should be key/value pairs, not a hash reference")
      if ref($_[1]) eq 'HASH';

  my($class, %cnf) = @_;

=pod

=over

=item timeout [INT]

The length of time, in seconds, to wait for a response from the API. Defaults to
30.

=cut

  my $timeout = delete $cnf{timeout};
  $timeout = 30 unless defined $timeout;

=pod

=item retries [INT]

The number of times to attempt an API request before dying. Defaults to 3.

=cut

  my $retries = delete $cnf{retries};
  $retries = 3 unless defined $retries;

=pod

=item version [STRING]

The version of the API to use. Defaults to 'v1', which is the only version
available at this time.

=cut

  my $version = delete $cnf{version};
  $version = 'v1' unless defined $version;

=pod

=item language [STRING]

The language code to use for all API requests. Defaults to 'en', other
supported languages are 'de', 'es', and 'fr'. This setting can be overridden
when calling individual API methods.

=cut

  my $language = _check_language(delete $cnf{language});
  $language = 'en' unless defined $language;

=pod

=item emblem_texture_folder [STRING]

Local path of a folder containing guild emblem textures. Defaults to null. The
folder should contain the subfolders "guild emblems" and "guild emblem
backgrounds". See the C<generate_guild_emblem> method under L</AnetColor
Methods> for details.

=cut

  my $emblem_texture_folder = delete $cnf{emblem_texture_folder};

=pod

=item emblem_output_folder [STRING]

Local path of a folder where generated guild emblems will be output. Defaults to
null. See the C<generate_guild_emblem> method under L</AnetColor Methods> for
details.

=cut

  my $emblem_output_folder = delete $cnf{emblem_output_folder};

=pod

=item nocache [BOOL]

Disable local caching of API responses. Defaults to undef. Using this in
combination with any of the following cache options will cause an error.

=cut

  my $nocache = delete $cnf{nocache};

=pod

=item cache_dir [STRING]

The local directory to use as the cache location. Defaults to './gw2api-cache'
and will attempt to create the directory if it does not exist.

=cut

  my $cache_dir = delete $cnf{cache_dir};
  Carp::croak("Can't mix cache_dir and nocache")
    if $cache_dir && $nocache;

=pod

=item cache_age [DURATION]

Length of time after which the cached responses will expire. Defaults to '24
hours'. Accepted values are strings consisting of an integer followed by a time
unit, e.g. '1 day' or '10 seconds'.

This applies to I<most> of the APIs; the following *_cache_age parameters
override this setting for specific APIs.

=cut

  my $cache_age = delete $cnf{cache_age};
  Carp::croak("Can't mix cache_age and nocache")
    if $cache_age && $nocache;
  $cache_age = "24 hours" unless defined $cache_age;

=pod

=item event_cache_age [DURATION]

Length of time after which the cached version of I<event state> responses will
expire. Defaults to '30 seconds'.

=cut

  my $event_cache_age = delete $cnf{event_cache_age};
  Carp::croak("Can't mix event_cache_age and nocache")
    if $event_cache_age && $nocache;
  $event_cache_age = "30 seconds" unless defined $event_cache_age;

=pod

=item wvw_cache_age [DURATION]

Length of time after which the cached version of I<WvW match detail> responses
will expire. Defaults to '5 minutes'.

=cut

  my $wvw_cache_age = delete $cnf{wvw_cache_age};
  Carp::croak("Can't mix wvw_cache_age and nocache")
    if $wvw_cache_age && $nocache;
  $wvw_cache_age = "1 minute" unless defined $wvw_cache_age;

=pod

=back

=back

=cut

  if (%cnf && $^W) {
    Carp::carp("Unrecognized GW2API options: @{[sort keys %cnf]}");
  }

  # Create object
  my $self  = bless {
      timeout         => $timeout,
      retries         => $retries,
      version         => $version,
      base_url        => 'https://api.guildwars2.com/' . $version,
      language        => $language,
      json            => JSON::PP->new,
      ua              => LWP::UserAgent->new,
      anetcolor       => undef,
      cache           => undef,
      cache_age       => $cache_age,
      event_cache_age => $event_cache_age,
      wvw_cache_age   => $wvw_cache_age,
      nocache         => $nocache,
    }, $class;

  $self->{anetcolor} = GW2API::AnetColor->new(
                        emblem_texture_folder => $emblem_texture_folder,
                        emblem_output_folder => $emblem_output_folder
                     );

  # Set up file caching
  unless (defined $nocache) {
    $cache_dir = './gw2api-cache' unless defined $cache_dir;
    # If it exists...
    if ( -e $cache_dir ) {
      # ... make sure it's a directory
      if ( ! -d $cache_dir ) {
        Carp::croak "Cache_dir [$cache_dir] is not a directory";
      }
      # ... make sure it's writeable
      if ( ! -w $cache_dir ) {
        Carp::croak "Unable to write to cache_dir [$cache_dir]";
      }
    # Otherwise, attempt to create it
    } else {
      mkdir $cache_dir or Carp::croak "Failed to create cache_dir [$cache_dir]: $!\n";
    }
    $self->{cache} = CHI->new( driver => 'File', root_dir => $cache_dir );
  }

  return $self;
}

####################
# "Sub-classed" objects
####################

=pod

=head2 Subclassed objects

The following classes are loaded into the constructor and can be accessed as
"subobjects" of the main $api object.

=over

=item L<CHI|http://search.cpan.org/~jswartz/CHI-0.56/lib/CHI.pm> - $api->cache

Interface to the file cache handler. Used for storing API responses locally.

=item L<JSON::PP|http://search.cpan.org/~makamaka/JSON-PP-2.27202/lib/JSON/PP.pm> - $api->json

Interface for encoding/decoding JSON strings. Used to decode the JSON responses
from the API.

=item L<LWP::UserAgent|search.cpan.org/~gaas/libwww-perl-6.05/lib/LWP/UserAgent.pm> - $api->ua

HTTP interface. Used for interacting with the API.

=item GW2API::AnetColor - $api->anetcolor

A true subclass, this is a collection of methods for utilizing the color
transform data returned from the colors API. See the section on L</AnetColor
Methods> for documentation.

=back

=cut

# Shortcuts
sub ua {
  my $self = shift;
  return $self->{ua};
}

sub json {
  my $self = shift;
  return $self->{json};
}

sub cache {
  my $self = shift;
  return $self->{cache};
}

sub anetcolor {
  my $self = shift;
  return $self->{anetcolor};
}

####################
# Core methods - not exposed through documentation
####################

###
# Elem - easy attribute access
###
# @param scalar     New attribute value
#
# @return scalar    Current/old attribute value
#
sub _elem
{
  my $self = shift;
  my $elem = shift;
  my $old = $self->{$elem};
  $self->{$elem} = shift if @_;
  return $old;
}

###
# Check Language
###
# @param scalar     Input language code
#
# @return scalar    Validated language code
#
sub _check_language {
  my ($self, $lang) = @_;

  # If input is undef, return undef
  return undef if !defined($lang);

  my $lang_orig = $lang;

  $lang = lc($lang);

  if ($lang ~~ @_languages) {
    return $lang;
  } else {
    Carp::croak "Language code [$lang_orig] is not supported";
  }
}

###
# API Request
###
# @param scalar     Name of JSON interface
# @param hashref    Key/value pairs of GET parameters
#
# @return scalar    Decoded JSON object
#
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

  my $_url = $self->{base_url} . '/' . $interface . $parm_string;

  my $response;

  # Check in CHI cache first
  $response = $self->cache->get($_url) unless defined $self->{nocache};

  if ( !defined $response ) {

    # If not in cache, send GET request to API
    $self->ua->timeout($self->{timeout});

    for (my $i = 0; $i < $self->{retries}; $i++) {
      $response = $self->ua->get($_url);

      if ($response->is_success()) {
        $response = $response->decoded_content();
      }
    }

    # If no response after using up retries, die
    die $response->status_line() if !defined $response;

    # Set the CHI cache for this $_url for efficient future access
    $cache_age = $self->{cache_age} unless defined $cache_age;
    $self->cache->set($_url, $response, $cache_age) unless defined $self->{nocache};
  }

  my $decoded = $self->json->decode ($response) || Carp::croak("could not decode JSON: $!");

  Carp::croak("Error [$decoded->{text}] returned from $interface for parameters: $parm_string")
    if ref($decoded) eq "HASH" && defined $decoded->{error};

  return $decoded;
}


####################
# Configuration methods
####################

=pod

=head1 Methods

=head2 Config access methods

=over

=item $api->timeout

=item $api->timeout( $timeout )

Get or set the C<timeout> configuration option.

=item $api->retries

=item $api->retries( $retries )

Get or set the C<retries> configuration option.

=item $api->language

=item $api->language( $lang )

Get or set the C<language> configuration option.

=item $api->emblem_texture_folder

=item $api->emblem_texture_folder( $path )

Get or set the C<emblem_texture_folder> configuration option.

=item $api->emblem_output_folder

=item $api->emblem_output_folder( $path )

Get or set the C<emblem_output_folder> configuration option.

=back

=cut

sub timeout               { shift->_elem('timeout'     ,@_); }
sub retries               { shift->_elem('retries'     ,@_); }
sub language              { shift->_elem('language'    ,@_); }
sub emblem_texture_folder { shift->anetcolor->_elem('emblem_texture_folder'    ,@_); }
sub emblem_output_folder  { shift->anetcolor->_elem('emblem_output_folder'    ,@_); }


####################
# Specific API accessors
####################

=pod

=head2 API methods

=over

=item $api->build

Returns the current build number.

=cut

sub build {
 my ($self) = @_;

  my $json = $self->_api_request($_url_build);

  return $json->{build_id};
}

=pod

=item $api->event_names
=item $api->event_names( $lang )

=item $api->map_names
=item $api->map_names( $lang )

=item $api->world_names
=item $api->world_names( $lang )

=item $api->objective_names
=item $api->objective_names( $lang )

Each of these methods returns a hash, keyed by the event/map/etc. ID, containing
the names corresponding to those IDs. An optional language parameter can be
passed to override the default language.

=cut

sub _generic_names {
 my ($self, $interface, $lang) = @_;

  if (defined $lang) {
    $lang = $self->_check_language($lang);
  } else {
    $lang = $self->{language};
  }

  my $json = $self->_api_request($interface, { lang => $lang } );

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

=pod

=item $api->event_state( $event_id, $world_id )

Returns a string containing the current state of a specific event on a specific
world. Event state will be one of the following values (definitions are from
L<the official API documentation|https://forum-en.guildwars2.com/forum/community/api/API-Documentation/>):

 State        Meaning
 ------------ ---------------------------------------------------------
 Active       The event is running now.
 Success      The event has succeeded.
 Fail         The event has failed.
 Warmup       The event is inactive, and will only become active once
              certain criteria are met.
 Preparation  The criteria for the event to start have been met, but
              certain activities (such as an NPC dialogue) have not
              completed yet. After the activites have been completed,
              the event will become Active.

=cut

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

  my $json = $self->_api_request($_url_events, { event_id => $event_id, world_id => $world_id }, "30 seconds" );

  Carp::croak("No results for event ID [$event_id] and world ID [$world_id]")
    unless @{$json->{events}} > 0;

  return $json->{events}->[0]->{state};
}

=pod

=item $api->event_state_by_world( $event_id )

Returns a hash, keyed by world ID, containing the current state of the given
event on each world.

=cut

sub event_state_by_world {
  my ($self, $event_id) = @_;

  # Sanity checks on event_id
  Carp::croak("You must provide an event ID")
    unless defined $event_id;

  Carp::croak("Given event ID [$event_id] does not match event ID pattern")
    unless $event_id =~ /^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$/i;

  my $json = $self->_api_request($_url_events, { event_id => $event_id }, "30 seconds" );

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

=pod

=item $api->event_states_in_map( $map_id, $world_id )

Returns a hash, keyed by event ID, containing the current state of all events
occurring within a specific map on a specific world.

=cut

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

  my $json = $self->_api_request($_url_events, { map_id  => $map_id, world_id => $world_id }, "30 seconds" );

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

=pod

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

=cut

sub wvw_matches {
  my ($self) = @_;

  my $json = $self->_api_request($_url_matches);

  return @{$json->{wvw_matches}};
}

=pod

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

=cut

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

=pod

=item $api->items

Returns an array containing all known item IDs.

=cut

sub items {
  my ($self) = @_;

  my $json = $self->_api_request($_url_items);

  return @{$json->{items}};
}

=pod

=item $api->item_details( $item_id )
=item $api->item_details( $item_id, $lang )

Returns a hash containing detailed information for the given item ID. An
optional language parameter can be passed to override the default language. The
hash has the following structure (elements marked with *** are enumerated below
the main structure):

 (
   item_id      => [INT],           # Item ID
   name         => [STRING],        # Item name
   description  => [STRING],        # Item description
   type         => [STRING],        # Item type***
   level        => [INT],           # Required level
   rarity       => [STRING],        # Rarity***
   vendor_value => [INT],           # Value when sold to a merchant
   game_types   => @([STRING],...), # Game types where item can be used***
   flags        => @([STRING],...), # Behavioral flags***
   restrictions => @([STRING],...), # Racial restrictions***

   # One of the following data elements corresponding to the value of "type" above.
   # Note that some item types do not have a corresponding data element.

   armor =>
     {
       type           => [STRING],  # Armor type***
       weight_class   => [STRING],  # Armor weight class (Light, Medium, Heavy, Clothing)
       defense        => [INT],     # Defense value
       infusion_slots => @( ),      # Infusion slots***
       infix_upgrade  => %( ),      # Infix upgrade***
       suffix_item_id => [INT],     # Item ID of attached upgrade component
     }

   back =>
     {
       infusion_slots => @( ),      # Infusion slots***
       infix_upgrade  => %( ),      # Infix upgrade***
       suffix_item_id => [INT],     # Item ID of attached upgrade component
     }

   bag =>
     {
       no_sell_or_sort => [BOOL],   # Items in bag are not sorted or shown to merchants
       size            => [INT],    # Number of slots
     }

   consumable =>
     {
       type         => [STRING],    # Consumable type***
       duration_ms  => [INT],       # Duration of nourishment effect
       description  => [STRING],    # Description of nourishment effect
                                    # (Nourishment effects are only on Food and Utility consumables)
       unlock_type  => [STRING],    # Unlock subtype (BagSlot, BankTab, CraftingRecipe, Dye)
       color_id     => [INT],       # Color_id unlocked by a Dye (cf. $api->colors)
       recipe_id    => [INT],       # Recipe_id unlocked by a CraftingRecipe (cf. $api->recipe_details)
     }

   container =>
     {
       type => [STRING],            # Container type (Default, GiftBox)
     }

   gathering =>
     {
       type => [STRING],            # Gathering type (Foraging, Logging, Mining)
     }

   gizmo =>
     {
       type => [STRING],            # Gizmo type (Default, RentableContractNpc, UnlimitedConsumable)
     }

   tool =>
     {
       type => [STRING],            # Tool type (Salvage)
     }

   trinket =>
     {
       type => [STRING],            # Trinket type (Accessory, Amulet, Ring)
       infusion_slots => @( ),      # Infusion slots***
       infix_upgrade  => %( ),      # Infix upgrade***
       suffix_item_id => [INT],     # Item ID of attached upgrade component
     }

   upgrade_component =>
     {
       type           => [STRING],        # Upgrade type (Default, Gem, Rune, Sigil)
       flags          => @([STRING],...), # Upgrade flags***
       infusion_upgrade_flags => @([STRING],...), # Infusion flags (Defense, Offense, Utility)
       bonuses        => @([STRING],...), # Rune bonuses
       infix_upgrade  => %( ),            # Infix upgrade***
       suffix         => [STRING],        # Suffix bestowed by the upgrade
     }

   weapon =>
     {
       type        => [STRING],     # Weapon type***
       damage_type => [STRING],     # Damage type (Physical, Fire, Ice, Lightning)
       min_power   => [INT],        # Minimum weapon strength value
       max_power   => [INT],        # Maximum weapon strength value
       defense     => [INT],        # Defense value
       infusion_slots => @( ),      # Infusion slots***
       infix_upgrade  => %( ),      # Infix upgrade***
       suffix_item_id => [INT],     # Item ID of attached upgrade component
     }
 )

The following elements are shared between different type data elements:

 infusion_slots =>
   [
     {
       flags  => @([STRING]...),  # Flags on the infusion slot (Defense, Offense, Utility)
     },
     ...                          # repeat for multiple infusion slots (no item has >1 currently)
   ]

 infix_upgrade =>
   {
     buff       =>
       {
         skill_id     => [INT],     # Skill ID of the infixed buff skill
         description  => [STRING],  # Description of the infixed buff skill
       },
     attributes =>
       [
         {
           attribute  => [STRING],  # Attribute name
                                    #   (ConditionDamage, CritDamage, Healing,
                                    #    Power, Precision, Toughness, Vitality)
           modifier   => [INT],     # Value of attribute bonus
         },
         ...                        # Repeat for each attribute
       ]
   }

Enumerations:

=over

=item Item type

 Armor
 Back
 Bag
 Consumable
 Container
 CraftingMaterial
 Gathering
 Gizmo
 MiniPet
 Tool
 Trinket
 Trophy
 UpgradeComponent
 Weapon

=item Rarity

 Junk
 Basic
 Fine
 Masterwork
 Rare
 Exotic
 Ascended
 Legendary

=item Game types

 Activity
 Dungeon
 Pve
 Pvp
 PvpLobby
 Wvw

=item Flags

 AccountBound
 HideSuffix
 NoMysticForge
 NoSalvage
 NoSell
 NotUpgradeable
 NoUnderwater
 SoulBindOnAcquire
 SoulBindOnUse
 Unique

=item  Restrictions

 Asura
 Charr
 Human
 Norn
 Sylvari

*NOTE: There is a single item with restrictions of ('Guardian', 'Warrior'); this is probably a mistake in the API build.

=item Armor type

 Boots
 Coat
 Gloves
 Helm
 HelmAquatic
 Leggings
 Shoulders

=item Consumable type

 AppearanceChange
 ContractNpc
 Food
 Generic
 Halloween
 Immediate
 Transmutation
 Unlock
 Utility

=item Upgrade component flags

 # Armor
 HeavyArmor
 LightArmor
 MediumArmor

 # Weapons
 Axe
 LongBow
 ShortBow
 Dagger
 Focus
 Greatsword
 Hammer
 Harpoon
 Mace
 Pistol
 Rifle
 Scepter
 Shield
 Speargun
 Staff
 Sword
 Torch
 Trident
 Warhorn

 # Trinkets
 Trinket

=item Weapon type

 Axe
 Dagger
 Focus
 Greatsword
 Hammer
 Harpoon
 LongBow
 Mace
 Pistol
 Rifle
 Scepter
 Shield
 ShortBow
 Speargun
 Staff
 Sword
 Torch
 Toy
 Trident
 TwoHandedToy
 Warhorn

=back

=cut

sub item_details {
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

  return %$json;
}

=pod

=item $api->recipes

Returns an array containing all known recipe IDs.

=cut

sub recipes {
  my ($self) = @_;

  my $json = $self->_api_request($_url_recipes);

  return @{$json->{recipes}};
}

=pod

=item $api->recipe_details( $recipe_id )
=item $api->recipe_details( $recipe_id, $lang )

Returns a hash containing detailed information for the given recipe ID. An
optional language parameter can be passed to override the default language. The
hash has the following structure:

 (
   recipe_id          => [INT],         # Recipe ID
   type               => [STRING],      # Recipe type***
   output_item_id     => [INT],         # Item ID of the recipe output
   output_item_count  => [INT],         # Quantity of item output
   min_rating         => [INT],         # Required rating in the associated crafting discipline
   time_to_craft_ms   => [INT],         # Duration of crafting the recipe
   disciplines        => @([STRING]...) # List of disciplines that can craft the recipe
                                        # (Armorsmith, Artificer, Chef, Huntsman, Jeweler,
                                        #  Leatherworker, Tailor, Weaponsmith)
   flags              => @([STRING]...) # If recipe is not learned through Discovery (AutoLearned, LearnedFromItem)
   ingredients        =>
     [
       {
         item_id  => [INT],           # Item ID of the ingredient
         count    => [INT],           # Required quantity of the ingredient
       },
       ...                            # Repeat for each ingredient, up to 4
     ],
 )

=cut

sub recipe_details {
  my ($self, $recipe_id) = @_;

  # Sanity checks on recipe_id
  Carp::croak("You must provide a recipe ID")
    unless defined $recipe_id;

  Carp::croak("Given recipe ID [$recipe_id] is not a positive integer")
    unless $recipe_id =~ /^\d+$/;

  my $json = $self->_api_request($_url_recipe_details, { recipe_id => $recipe_id } );

  return %$json;
}

=pod

=item $api->colors
=item $api->colors( $lang )

Returns a hash, keyed on color_id, containing color information for all colors
in the game. Each entry is a hashref with the following structure:

 {
   name     => [STRING],      # Color name
   base_rgb => array([INT]),  # Base RGB color for applying transformations
   cloth    =>                # Transformation data for cloth material
     {
       brightness => [FLOAT],       # Brightness shift (RGB255)
       contrast   => [FLOAT],       # Contrast shift (RGB255)
       hue        => [FLOAT],       # Hue shift (0 <= H <= 360)
       saturation => [FLOAT],       # Saturation shift (0 <= S <= 1)
       lightness  => [FLOAT],       # Lightness shift (0 <= L <= 1)
       rgb        => array([INT]),  # Pre-calculated RGB values from the base_rgb color
     },
   leather  => { ... },       # Transformation data for leather material (same structure as cloth)
   metal    => { ... },       # Transformation data for metal material (same structure as cloth)
 }

=cut

sub colors {
  my ($self, $lang) = @_;

  if (defined $lang) {
    $lang = $self->_check_language($lang);
  } else {
    $lang = $self->{language};
  }

  my $json = $self->_api_request($_url_colors, { lang => $lang } );

  return %{$json->{colors}};
}

=pod

=item $api->guild_details( $guild_id )
=item $api->guild_details( $guild_name )

Returns a hash containing detailed information for the given guild ID or guild
name. If the argument doesn't match the pattern of a guild ID, it is assumed to
be a guild name. The hash has the following structure:

 (
   guild_id   => [STRING],    # Guild ID
   guild_name => [STRING],    # Guild name
   tag        => [STRING],    # Guild tag
   emblem     =>              # Guild emblem data
     {
       background_id                  => [INT]          # ID of background texture
       foreground_id                  => [INT]          # ID of foreground texture
       flags                          => @([STRING]...) # Identify bg/fg transformations
                                                        # (FlipBackgroundHorizontal, FlipBackgroundVertical,
                                                        #  FlipForegroundHorizontal, FlipForegroundVertical)
       background_color_id            => [INT]          # Color ID of background color
       foreground_primary_color_id    => [INT]          # Color ID of primary foreground color
       foreground_secondary_color_id  => [INT]          # Color ID of secondary foreground color
     }
 )

=cut

sub guild_details {
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

  return %$json;
}
=pod

=back

=cut

# Here I include POD for the AnetColor subclass so everything is documented in
# one place

=pod

=head1 AnetColor Methods

=over

=item $api->anetcolor->colorShiftMatrix( \%material )

Uses the color transformation data (brightness, contrast, hue, saturation,
lightness) provided by the colors API to generate a transformation matrix,
returned as an array. C<%material> is one of the 'cloth', 'leather', or 'metal'
subobjects of the colors API.

=item $api->anetcolor->compositeColorShiftRgb( \@base_rgb, \@transform_matrix )

Takes a transformation matrix generated by the C<colorShiftMatrix> method and
applies it to an RGB color. Returns the transformed RGB values as an array.

=item $api->anetcolor->matrix_multiply( \@matrixA, \@matrixB )

Multiplies two matrices. Returns the result as an arrayref.

=item $api->anetcolor->matrix_count_rows_cols( \@matrix )

Retruns an array listing the number of rows and columns in the matrix.

=item $api->anetcolor->generate_guild_emblem( \%guild_details, \%colors )

Generates a guild emblem image based on emblem information from the
guild_details API and color information from the colors API.

Requires the Image::Magick module, which can be downloaded from
L<http://www.imagemagick.org>.

Also requires a set of guild emblem textures extracted from the game. A zip
archive of such can be found in this module's repository on GitHub. Unzip the
archive to a folder, then provide the path to that folder as the value for
I<emblem_texture_folder> in the API object's configuration.

=back

=cut

# And the final stuff!

=pod

=head1 Author

Tony Tauer, E<lt>dr.ishmael[at]gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2013 by Tony Tauer

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
