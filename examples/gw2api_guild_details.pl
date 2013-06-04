#!perl -w

use strict;

use GW2API;

my $api = GW2API->new;

my @prior_ids = ();

# Read in guild IDs that have already been processed.
if (-e "guild_details.csv") {
  open (IMAIN, "guild_details.csv") or die "unable to open file: $!\n";

  <IMAIN>; # throw out the header row

  while (<IMAIN>) {
    my ($id) = split(/\|/, $_);
    push @prior_ids, $id;
  }

  close (IMAIN);
}

open(OMAIN, ">guild_details.csv") or die "unable to open file: $!\n";

print OMAIN "guild_id|guild_name|guild_tag|emblem_bg|emblem_bg_color|emblem_fg|emblem_fg_color1|emblem_fg_color2|flags\n";

# Get a list of all guild IDs that are currently claiming an objective
my @current_guilds;
foreach my $match ($api->wvw_matches) {
  my %match_details = $api->wvw_match_details($match->{wvw_match_id});
  foreach my $map (@{$match_details{maps}}) {
    foreach my $objective (@{$map->{objectives}}) {
      push @current_guilds, $objective->{owner_guild} if defined($objective->{owner_guild});
    }
  }
}
# Merge with our prior list
my @known_guilds = (@prior_ids, @current_guilds);

# Dedupe the list
@known_guilds = keys %{{ map { $_ => 1 } @known_guilds }};


foreach my $guild_id (@known_guilds) {
  my %guild_details = $api->guild_details($guild_id);

  my $guild_name    = $guild_details{guild_name};
  my $guild_tag     = $guild_details{tag};

  # Some guilds don't have emblems!
  my $emblem_bg         = $guild_details{emblem}->{background_id} || "";
  my $emblem_bg_color   = $guild_details{emblem}->{background_color_id} || "";
  my $emblem_fg         = $guild_details{emblem}->{foreground_id} || "";
  my $emblem_fg_color1  = $guild_details{emblem}->{foreground_primary_color_id} || "";
  my $emblem_fg_color2  = $guild_details{emblem}->{foreground_secondary_color_id} || "";
  my $emblem_flags      = $guild_details{emblem}->{flags} || [];

  print OMAIN "$guild_id|$guild_name|$guild_tag|$emblem_bg|$emblem_bg_color|$emblem_fg|$emblem_fg_color1|$emblem_fg_color2"
            . "|" . join(",", @$emblem_flags)
            . "\n";
}

close (OMAIN);

exit;

