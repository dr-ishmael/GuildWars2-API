use Modern::Perl '2014';

package GuildWars2::API;
BEGIN {
  $GuildWars2::API::VERSION     = '2.0a';
}
use Carp ();
use Digest::MD5 qw(md5_hex);
use JSON::PP;
use LWP::UserAgent;

use Moose;
use Moose::Util::TypeConstraints; # required for enum constraints

use GuildWars2::API::Objects;
use GuildWars2::API::Utils;


####################
# Local constants
####################

my $_base_url             = 'https://api.guildwars2.com';
my $_base_render_url      = "https://render.guildwars2.com/file";

# Pagenames of the available interfaces
my $_url_build            = 'v1/build.json';
#my $_url_build            = 'v2/build.json';

#my $_url_events           = 'v2/events';
#my $_url_events-state     = 'v2/events-state';

#my $_url_worlds           = 'v2/worlds';
#my $_url_continents       = 'v2/continents';
#my $_url_maps             = 'v2/maps';
#my $_url_floors           = 'v2/floors';

my $_url_continents       = 'v1/continents.json';
my $_url_map_floor        = 'v1/map_floor.json';

#my $_url_wvw_matches      = 'v2/wvw/matches';
#my $_url_wvw_objectives   = 'v2/wvw/objectives';

my $_url_quaggans         = 'v2/quaggans';

my $_url_items            = 'v2/items';

my $_url_skins            = 'v2/skins';

my $_url_recipes          = 'v2/recipes';

#my $_url_colors           = 'v2/colors';
my $_url_colors           = 'v1/colors.json';

#my $_url_files            = 'v2/files';

#my $_url_accounts         = 'v2/accounts';
#my $_url_characters       = 'v2/characters';
#my $_url_leaderboards     = 'v2/leaderboards';

my $_url_tp_exchange       = 'v2/commerce/exchange';
my $_url_tp_listings       = 'v2/commerce/listings';
my $_url_tp_prices         = 'v2/commerce/prices';

# Supported languages
my @_languages = qw( de en es fr );

enum 'Lang', [@_languages];


####################
# Attributes
####################

has 'timeout'         => ( is => 'rw', isa => 'Int', default => 30 );
has 'retries'         => ( is => 'rw', isa => 'Int', default => 3 );
has 'language'        => ( is => 'rw', isa => 'Lang', default => 'en' );
has 'max_pagesize'    => ( is => 'rw', isa => 'Int',  default => 200 );
has 'json'            => ( is => 'ro', isa => 'JSON::PP', default => sub{ JSON::PP->new->canonical } );
has 'ua'              => ( is => 'ro', isa => 'LWP::UserAgent', default => sub{ LWP::UserAgent->new } );
has 'api_error'       => ( is => 'ro', isa => 'GuildWars2::API::Objects::Error', writer => '_set_api_error' );
has '_status'         => ( is => 'ro', isa => 'Bool', default => 1,  writer => '_set_status', reader => 'is_success' );
has '_curr_page'      => ( is => 'ro', isa => 'Int',  default => 0,  writer => '_set_curr_page' );
#has '_max_page'       => ( is => 'ro', isa => 'Int',  default => 1,  writer => '_set_max_page' );
#has '_curr_endpoint'  => ( is => 'ro', isa => 'Str',  default => "", writer => '_set_curr_endpoint' );
has '_prefix_map'     => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_prefix_map' );


####################
# Init methods
####################

sub _build_prefix_map {
  return {
    "power" => "mighty",
    "precision" => "precise",
    "toughness" => "resilient",
    "vitality" => "vital",
    "conditiondamage" => "malign",
    "conditionduration" => "giver_1w",
    "healing" => "healing",
    "boonduration" => "winter_suf",
    "power,precision" => "strong",
    "power,toughness" => "vagabond",
    "power,vitality" => "vigorous",
    "power,critdamage" => "honed",
    "power,conditiondamage" => "potent",
    "precision,power" => "hunter",
    "precision,critdamage" => "penetrating",
    "toughness,precision" => "stout",
    "toughness,conditiondamage" => "enduring",
    "toughness,healing" => "giver_2a",
    "vitality,toughness" => "hearty",
    "conditiondamage,precision" => "ravaging",
    "conditiondamage,toughness" => "deserter",
    "conditiondamage,vitality" => "lingering",
    "conditionduration,vitality" => "giver_2w",
    "healing,power" => "rejuvenating",
    "healing,toughness" => "survivor",
    "healing,vitality" => "mending",
    "power,critdamage,precision" => "berserker",
    "power,healing,precision" => "zealot",
    "power,healing,toughness" => "forsaken",
    "power,toughness,vitality" => "soldier",
    "power,critdamage,vitality" => "valkyrie",
    "precision,power,toughness" => "captain",
    "precision,critdamage,power" => "assassin",
    "precision,conditiondamage,power" => "rampager",
    "toughness,power,precision" => "knight",
    "toughness,healing,vitality" => "nomad",
    "toughness,critdamage,power" => "cavalier",
    "toughness,conditiondamage,healing" => "settler",
    "toughness,boonduration,healing" => "giver_3a",
    "vitality,power,toughness" => "sentinel",
    "vitality,power,healing" => "shaman_suf",
    "vitality,conditiondamage,healing" => "shaman",
    "conditiondamage,healing,toughness" => "apostate",
    "conditiondamage,power,vitality" => "carrion",
    "conditiondamage,precision,toughness" => "rabid",
    "conditiondamage,toughness,vitality" => "dire",
    "conditionduration,precision,vitality" => "giver_3w",
    "healing,power,toughness" => "cleric",
    "healing,precision,vitality" => "magi",
    "healing,conditiondamage,toughness" => "apothecary",
    "conditiondamage,critdamage,healing,power,precision,toughness,vitality" => "celestial",
  };
}

sub _retry(&;$) {
    my $sub_ref = shift;
    my $max     = shift || 3;
    my $ret;

  ATTEMPT:
    for my $try (1..$max) {
        $ret = eval { local $SIG{__DIE__}; $sub_ref->(); };
        last unless $@;
        last if $try == $max; # don't waste time sleeping if we've hit the max
        #Carp::carp "Failed $try, retrying.  Error: $@\n";
        sleep(5);
    }
    if ($@) { Carp::carp "failed after $max tries: $@\n"; return undef; }
    return $ret;
}

####################
# Core methods
####################

sub _check_language {
  my ($self, $lang) = @_;

  # If input is undef, return undef
  return undef if !defined($lang);

  my $lang_orig = $lang;

  $lang = lc($lang);

  if (in($lang, \@_languages)) {
    return $lang;
  } else {
    Carp::croak "Language code [$lang_orig] is not supported";
  }
}

sub _api_request {
  my ($self, $interface, $parms) = @_;

  my $parm_string = "";

  if ($parms) {
    my @parm_pairs;
    foreach my $k (sort keys %$parms) {
      push @parm_pairs, "$k=$parms->{$k}";
    }
    $parm_string = '?' . join('&', @parm_pairs)
  }

  my $url = $_base_url . '/' . $interface . $parm_string;

  my ($response, $decoded);

  $self->_set_status(0);

  # Send GET request to API
  $self->ua->timeout($self->{timeout});

  # Encapsulate the entire HTTP request / JSON decode / CHI store process in a
  # _retry block. If any of the 3 steps fails,
  $decoded = _retry {
    # Make HTTP GET request (doesn't die automatically)
    $response = $self->ua->get($url);
    # warn $response->status_line() if $response->is_error();
    die "Error getting URL [$url]:\n" . $response->status_line() if !defined($response);
    $response = $response->decoded_content();

    # ArenaNet uses UTF-8 encoding for text; this sets Perl's internal UTF-8
    # flag for the returned data, inherited by all derived values.
    utf8::decode($response);

    # We have HTTP response, attempt to decode JSON (this dies on decode error, but the eval in _retry catches it)
    my $ret = $self->json->decode($response);

    return $ret;
  };

  ###### need handler here in case _retry fails


  if (ref($decoded) eq "HASH" && (defined($decoded->{error}) || defined($decoded->{text}) )) {
    Carp::carp "API error at URL [$url]";
    $self->_set_api_error(GuildWars2::API::Objects::Error->new($decoded));
  } else {
    $self->_set_status(1);
  }

  return ($response, $decoded);
}


####################
# API accessor methods
####################

sub build {
  my ($self) = @_;

  my ($raw, $json) = $self->_api_request($_url_build);

  return $json->{build_id};
}



###
# /quaggans methods

sub list_quaggans {
  my ($self) = @_;

  my ($raw, $json) = $self->_api_request($_url_quaggans);

  return @{$json};
}


###
# Item methods

sub list_items {
  my ($self) = @_;

  my ($raw, $json) = $self->_api_request($_url_items);

  return @{$json};
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

  my ($raw, $json) = $self->_api_request($_url_items, { lang => $lang, ids => $item_id } );

  if ($self->is_success) {
    # Have to calculate MD5 before object construction because the constructor obliterates the original data
    use bytes;
    my $md5 = md5_hex($self->json->encode($json->[0]));
    no bytes;
    my $item = GuildWars2::API::Objects::Item->new($json->[0]);
    $item->_set_md5($md5);

    return $item;

  } else {
    return undef;
  }
}


sub get_items {
  my ($self, $item_ids, $lang) = @_;

  # Sanity checks on item_id
  Carp::croak("You must provide a list of item IDs")
    unless defined $item_ids;

  foreach my $item_id (@$item_ids) {
    Carp::croak("Given item ID [$item_id] is not a positive integer")
      unless $item_id =~ /^\d+$/;
  }

  if (defined $lang) {
    $lang = $self->_check_language($lang);
  } else {
    $lang = $self->{language};
  }

  my ($raw, $json) = $self->_api_request($_url_items, { lang => $lang, ids => join(',', @$item_ids) } );

  if ($self->is_success) {
    my @items;
    foreach my $item_json (@$json) {
      use bytes;
      my $md5 = md5_hex($self->json->encode($item_json)."");
      no bytes;
#      my $item = GuildWars2::API::Objects::Item->new($item_json);
#      $item->_set_md5($md5);
      my $item = {
        json => $item_json,
        md5 => $md5,
      };

      push(@items, $item);
    }

    return @items;

  } else {
    return undef;
  }
}

sub get_item_page {
  my ($self, $pagesize, $lang) = @_;

  if (defined $pagesize) {
    Carp::croak("Given pagesize [$pagesize] is not a positive integer")
      unless $pagesize =~ /^\d+$/;
  } else {
    $pagesize = $self->{max_pagesize};
  }

  if (defined $lang) {
    $lang = $self->_check_language($lang);
  } else {
    $lang = $self->{language};
  }

  my ($raw, $json) = $self->_api_request($_url_items, { lang => $lang, page => $self->{_curr_page}, page_size => $pagesize } );

  if ($self->is_success) {
    my @items;
    foreach my $item_json (sort { $a->{id} <=> $b->{id} } @$json) {
      use bytes;
      my $md5 = md5_hex($self->json->encode($item_json));
      no bytes;
      my $item = GuildWars2::API::Objects::Item->new($item_json);
      $item->_set_md5($md5);

      push(@items, $item);
    }

    $self->_set_curr_page($self->{_curr_page}+1);

    return @items;

  } else {
    return undef;
  }
}


###
# Recipe methods

sub list_recipes {
  my ($self) = @_;

  my ($raw, $json) = $self->_api_request($_url_recipes);

  return @{$json};
}

sub get_recipe {
  my ($self, $recipe_id, $lang) = @_;

  # Sanity checks on recipe_id
  Carp::croak("You must provide a recipe ID")
    unless defined $recipe_id;

  Carp::croak("Given recipe ID [$recipe_id] is not a positive integer")
    unless $recipe_id =~ /^\d+$/;

  if (defined $lang) {
    $lang = $self->_check_language($lang);
  } else {
    $lang = $self->{language};
  }

  my ($raw, $json) = $self->_api_request($_url_recipes, { lang => $lang, ids => $recipe_id } );

  if ($self->is_success) {
    # Have to calculate MD5 before object construction because the constructor obliterates the original data
    use bytes;
    my $md5 = md5_hex($self->json->encode($json->[0]));
    no bytes;
    my $recipe = GuildWars2::API::Objects::Recipe->new($json->[0]);
    $recipe->_set_md5($md5);

    return $recipe;

  } else {
    return undef;
  }
}


sub get_recipes {
  my ($self, $recipe_ids, $lang) = @_;

  # Sanity checks on recipe_id
  Carp::croak("You must provide a list of recipe IDs")
    unless defined $recipe_ids;

  foreach my $recipe_id (@$recipe_ids) {
    Carp::croak("Given recipe ID [$recipe_id] is not a positive integer")
      unless $recipe_id =~ /^\d+$/;
  }

  if (defined $lang) {
    $lang = $self->_check_language($lang);
  } else {
    $lang = $self->{language};
  }

  my ($raw, $json) = $self->_api_request($_url_recipes, { lang => $lang, ids => join(',', @$recipe_ids) } );

  if ($self->is_success) {
    my @recipes;
    foreach my $recipe_json (@$json) {
      use bytes;
      my $md5 = md5_hex($self->json->encode($recipe_json)."");
      no bytes;
      my $recipe = GuildWars2::API::Objects::Recipe->new($recipe_json);
      $recipe->_set_md5($md5);

      push(@recipes, $recipe);
    }

    return @recipes;

  } else {
    return undef;
  }
}

sub get_recipe_page {
  my ($self, $pagesize, $lang) = @_;

  if (defined $pagesize) {
    Carp::croak("Given pagesize [$pagesize] is not a positive integer")
      unless $pagesize =~ /^\d+$/;
  } else {
    $pagesize = $self->{max_pagesize};
  }

  if (defined $lang) {
    $lang = $self->_check_language($lang);
  } else {
    $lang = $self->{language};
  }

  my ($raw, $json) = $self->_api_request($_url_recipes, { lang => $lang, page => $self->{_curr_page}, page_size => $pagesize } );

  if ($self->is_success) {
    my @recipes;
    foreach my $recipe_json (sort { $a->{id} <=> $b->{id} } @$json) {
      use bytes;
      my $md5 = md5_hex($self->json->encode($recipe_json));
      no bytes;
      my $recipe = GuildWars2::API::Objects::Recipe->new($recipe_json);
      $recipe->_set_md5($md5);

      push(@recipes, $recipe);
    }

    $self->_set_curr_page($self->{_curr_page}+1);

    return @recipes;

  } else {
    return undef;
  }
}



###
# Recipe methods

sub list_skins {
  my ($self) = @_;

  my ($raw, $json) = $self->_api_request($_url_skins);

  return @{$json};
}

sub get_skin {
  my ($self, $skin_id, $lang) = @_;

  # Sanity checks on skin_id
  Carp::croak("You must provide a skin ID")
    unless defined $skin_id;

  Carp::croak("Given skin ID [$skin_id] is not a positive integer")
    unless $skin_id =~ /^\d+$/;

  if (defined $lang) {
    $lang = $self->_check_language($lang);
  } else {
    $lang = $self->{language};
  }

  my ($raw, $json) = $self->_api_request($_url_skins, { lang => $lang, ids => $skin_id } );

  if ($self->is_success) {
    # Have to calculate MD5 before object construction because the constructor obliterates the original data
    use bytes;
    my $md5 = md5_hex($self->json->encode($json->[0]));
    no bytes;
    my $skin = GuildWars2::API::Objects::Skin->new($json->[0]);
    $skin->_set_md5($md5);

    return $skin;

  } else {
    return undef;
  }
}


sub get_skins {
  my ($self, $skin_ids, $lang) = @_;

  # Sanity checks on skin_id
  Carp::croak("You must provide a list of skin IDs")
    unless defined $skin_ids;

  foreach my $skin_id (@$skin_ids) {
    Carp::croak("Given skin ID [$skin_id] is not a positive integer")
      unless $skin_id =~ /^\d+$/;
  }

  if (defined $lang) {
    $lang = $self->_check_language($lang);
  } else {
    $lang = $self->{language};
  }

  my ($raw, $json) = $self->_api_request($_url_skins, { lang => $lang, ids => join(',', @$skin_ids) } );

  if ($self->is_success) {
    my @skins;
    foreach my $skin_json (@$json) {
      use bytes;
      my $md5 = md5_hex($self->json->encode($skin_json)."");
      no bytes;
      my $skin = GuildWars2::API::Objects::Skin->new($skin_json);
      $skin->_set_md5($md5);

      push(@skins, $skin);
    }

    return @skins;

  } else {
    return undef;
  }
}

sub get_skin_page {
  my ($self, $pagesize, $lang) = @_;

  if (defined $pagesize) {
    Carp::croak("Given pagesize [$pagesize] is not a positive integer")
      unless $pagesize =~ /^\d+$/;
  } else {
    $pagesize = $self->{max_pagesize};
  }

  if (defined $lang) {
    $lang = $self->_check_language($lang);
  } else {
    $lang = $self->{language};
  }

  my ($raw, $json) = $self->_api_request($_url_skins, { lang => $lang, page => $self->{_curr_page}, page_size => $pagesize } );

  if ($self->is_success) {
    my @skins;
    foreach my $skin_json (sort { $a->{id} <=> $b->{id} } @$json) {
      use bytes;
      my $md5 = md5_hex($self->json->encode($skin_json));
      no bytes;
      my $skin = GuildWars2::API::Objects::Skin->new($skin_json);
      $skin->_set_md5($md5);

      push(@skins, $skin);
    }

    $self->_set_curr_page($self->{_curr_page}+1);

    return @skins;

  } else {
    return undef;
  }
}


sub get_continents {
  my ($self, $lang) = @_;

  if (defined $lang) {
    $lang = $self->_check_language($lang);
  } else {
    $lang = $self->{language};
  }

  my ($raw, $json) = $self->_api_request($_url_continents, { "lang" => $lang });

  my %map_tree;

  foreach my $continent_id (keys %{$json->{continents}}) {
   $map_tree{$continent_id} = GuildWars2::API::Objects::Continent->new( $json->{continents}->{$continent_id} );
  }

  return %map_tree;
}


sub get_map_floor {
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
    $floor_id = 0;
  }

  my ($raw, $json) = $self->_api_request($_url_map_floor, { "continent_id" => $continent_id, "floor" => $floor_id, "lang" => $lang });

  my $floor = GuildWars2::API::Objects::Floor->new( $json );

  return $floor;
}


sub get_colors {
  my ($self, $lang) = @_;

  if (defined $lang) {
    $lang = $self->_check_language($lang);
  } else {
    $lang = $self->{language};
  }

  my ($raw, $json) = $self->_api_request($_url_colors, { lang => $lang } );

  my %color_objs;
  foreach my $color_id (keys %{$json->{colors}}) {
    $color_objs{$color_id} = GuildWars2::API::Objects::Color->new( $json->{colors}->{$color_id} );
  }

  return %color_objs;
}



sub prefix_lookup {
  my ($self, $item) = @_;
  return $item->_prefix_lookup($self->_prefix_map);
}

1;
__END__



sub list_skins {
  my ($self) = @_;

  my ($raw, $json) = $self->_api_request($_url_skins, {}, "1 second");

  return @{$json->{skins}};
}


sub get_skin {
  my ($self, $skin_id, $lang) = @_;

  # Sanity checks on item_id
  Carp::croak("You must provide a skin ID")
    unless defined $skin_id;

  Carp::croak("Given skin ID [$skin_id] is not a positive integer")
    unless $skin_id =~ /^\d+$/;

  if (defined $lang) {
    $lang = $self->_check_language($lang);
  } else {
    $lang = $self->{language};
  }

  my ($raw, $json) = $self->_api_request($_url_skin_details, { lang => $lang, skin_id => $skin_id } );

  if ($self->is_success) {
    # Convert CamelCase type value to lower_case subobject name
    (my $tx = $json->{type}) =~ s/([a-z])([A-Z])/${1}_$2/g;
    $tx = lc($tx);

    # Standardize name of type-specific subobject
    if (my $a = delete $json->{$tx}) { $json->{type_data} = $a; }

    my $skin = GuildWars2::API::Objects::Skin->new($json);

    # Store the original raw JSON response
    $skin->_set_json($raw);
    my $eraw = $raw;
    utf8::encode($eraw);
    $skin->_set_md5(md5_hex($eraw));

    return $skin;
  } else {
    Carp::carp("Given skin ID [$skin_id] returned an API error message");
    my $error = GuildWars2::API::Objects::Error->new($json);
    return $error;
  }
}



1;

__END__
