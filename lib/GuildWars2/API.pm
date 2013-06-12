use Modern::Perl '2012';

package GuildWars2::API;
BEGIN {
  $GuildWars2::API::VERSION     = '0.10';
}
use Carp ();
use CHI;
use GuildWars2::API::Guild;
use JSON::PP;
use List::Util qw/max min/;
use LWP::UserAgent;

use Moose;
use Moose::Util::TypeConstraints;

####################
# Local constants
####################

my $_api_version          = 'v1';

my $_base_url             = 'https://api.guildwars2.com/' . $_api_version;

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
enum 'Lang', [qw(de en es fr)];

####################
# Attributes
####################


has 'timeout'         => ( is => 'rw', isa => 'Int', default => 30 );
has 'retries'         => ( is => 'rw', isa => 'Int', default => 3 );
has 'language'        => ( is => 'rw', isa => 'Lang', default => 'en' );
has 'nocache'         => ( is => 'ro', isa => 'Bool', default => undef );
has 'cache_dir'       => ( is => 'ro', isa => 'Str', default => './gw2api-cache' );
has 'cache_age'       => ( is => 'rw', isa => 'Str', default => '24 hours' );
has 'event_cache_age' => ( is => 'rw', isa => 'Str', default => '30 seconds' );
has 'wvw_cache_age'   => ( is => 'rw', isa => 'Str', default => '1 minute' );
has 'json'            => ( is => 'ro', isa => 'JSON::PP', default => sub{ JSON::PP->new } );
has 'ua'              => ( is => 'ro', isa => 'LWP::UserAgent', default => sub{ LWP::UserAgent->new } );
has 'cache'           => ( is => 'ro', isa => 'Maybe[CHI::Driver::File]', lazy => 1, builder => '_init_cache' );


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

    # If not in cache, send GET request to API
    $self->ua->timeout($self->{timeout});

    for (my $i = 0; $i < $self->{retries}; $i++) {
      $response = $self->ua->get($url);

      if ($response->is_success()) {
        $response = $response->decoded_content();
      }
    }

    # If no response or error after using up retries, die
    Carp::croak "Error getting URL [$url]:\n" . $response->status_line() if !defined $response || (ref($response) eq "HTTP::Response" && $response->is_error());

    # Set the CHI cache for this $_url for efficient future access
    $cache_age = $self->{cache_age} unless defined $cache_age;
    $self->cache->set($url, $response, $cache_age) unless defined $self->{nocache};
  }

  my $decoded = $self->json->decode ($response) || Carp::croak("could not decode JSON: $!");

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


sub items {
  my ($self) = @_;

  my $json = $self->_api_request($_url_items);

  return @{$json->{items}};
}


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


sub recipes {
  my ($self) = @_;

  my $json = $self->_api_request($_url_recipes);

  return @{$json->{recipes}};
}


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

  my $guild = GuildWars2::API::Guild->new( $json );

  return $guild;
}


1;
