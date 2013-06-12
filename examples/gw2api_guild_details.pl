#!perl -w

use Modern::Perl '2012';

use CGI;
use GuildWars2::API;
use Win32;

my $api = GuildWars2::API->new;
my $q = CGI->new;

#$api->emblem_texture_folder("C:/Users/ttauer/Pictures/GW2");
#$api->emblem_output_folder("C:/Users/ttauer/Documents/scripts/GW2API/guild emblems");
#$api->emblem_texture_folder("C:/Users/Tony/Pictures/GW2");
#$api->emblem_output_folder("C:/Users/Tony/Documents/GW2W/api/guild emblems");

my $username = Win32::LoginName;
my $emblem_texture_folder = "C:/Users/$username/Pictures/GW2";
my $emblem_output_folder = "./guild emblems";


my @prior_ids = ();
my %prior_hash = ();

# Read in guild IDs that have already been processed.
if (-e "guild_details.csv") {
  print "Reading known guilds from guild_details.csv...\n";
  open (IMAIN, "guild_details.csv") or die "unable to open file: $!\n";

  while (<IMAIN>) {
    next if /^guild_id/; # skip anything that looks like a header row

    my ($id) = split(/\|/, $_);
    push @prior_ids, $id;
    $prior_hash{$id} = $_;
  }

  close (IMAIN);
}

my %colors = $api->colors;

open(OMAIN, ">guild_details_new.csv") or die "unable to open file: $!\n";

say OMAIN "guild_id|guild_name|guild_tag|emblem_bg|emblem_fg|emblem_flip_bg_h|emblem_flip_bg_v|emblem_flip_fg_h|emblem_flip_fg_v|emblem_bg_color|emblem_fg_color1|emblem_fg_color2";

#open(OHTML, ">guild_details.html") or die "unable to open file: $!\n";
#
#print OHTML $q->start_html();
#print OHTML $q->start_table();
#print OHTML $q->Tr(
#  $q->th("Guild ID"),
#  $q->th("Guild Name"),
#  $q->th("Tag"),
#  $q->th("Emblem")
#);

# Get a list of all guild IDs that are currently claiming an objective
say "Getting all guilds that currently control WvW objectives...";
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
say "Merging prior and current guild lists..." if scalar(@prior_ids) > 0;
my @known_guilds = (@prior_ids, @current_guilds);

# Dedupe the list
@known_guilds = keys %{{ map { $_ => 1 } @known_guilds }};

my $i = 0;
say "Parsing all guild details...";
foreach my $guild_id (@known_guilds) {
  my $guild = $api->get_guild($guild_id);

  my $guild_name    = $guild->guild_name;
  my $guild_tag     = $guild->tag;

  # Some guilds don't have emblems!
  my $emblem_bg         = "";
  my $emblem_fg         = "";
  my $emblem_flip_bg_h  = "";
  my $emblem_flip_bg_v  = "";
  my $emblem_flip_fg_h  = "";
  my $emblem_flip_fg_v  = "";
  my $emblem_bg_color   = "";
  my $emblem_fg_color1  = "";
  my $emblem_fg_color2  = "";
  if ($guild->emblem) {
    $emblem_bg         = $guild->emblem->background_id;
    $emblem_fg         = $guild->emblem->foreground_id;
    $emblem_flip_bg_h  = $guild->emblem->flip_background_horizontal;
    $emblem_flip_bg_v  = $guild->emblem->flip_background_vertical;
    $emblem_flip_fg_h  = $guild->emblem->flip_foreground_horizontal;
    $emblem_flip_fg_v  = $guild->emblem->flip_foreground_vertical;
    $emblem_bg_color   = $guild->emblem->background_color_id;
    $emblem_fg_color1  = $guild->emblem->foreground_primary_color_id;
    $emblem_fg_color2  = $guild->emblem->foreground_secondary_color_id;
  }

  my $current_details = "$guild_id|$guild_name|$guild_tag|$emblem_bg|$emblem_fg"
                      . "|$emblem_flip_bg_h|$emblem_flip_bg_v|$emblem_flip_fg_h|$emblem_flip_fg_v"
                      . "|$emblem_bg_color|$emblem_fg_color1|$emblem_fg_color2"
                      ;

  # Generate guild emblems
  my $prior_details = $prior_hash{$guild_id};
  if ( (!defined($prior_details) || $prior_details ne $current_details || ! -e $emblem_output_folder . "/$guild_id.png") && $emblem_fg ne "") {
    my $emblem_img = $guild->emblem->generate(\%colors, $emblem_texture_folder);
    $emblem_img->Write(filename=>"$emblem_output_folder/$guild_id.png");

  }

  say OMAIN $current_details;

#  print OHTML $q->Tr(
#    $q->td($guild_id),
#    $q->td($guild_name),
#    $q->td($guild_tag),
#    $q->td( $emblem_fg eq "" ? "No emblem" : $q->img({src=>"guild emblems/$guild_id.png"}) )
#  );

  say "$i" if ++$i % 25 == 0;
}

my $new_guilds = $i - scalar(@prior_ids);

say "$new_guilds new guilds, $i total guilds";

close (OMAIN);

#unlink "guild_details.csv.bak" || die "unable to delete file: $!\n";
#
#rename "guild_details.csv", "guild_details.csv.bak" || die "unable to rename file: $!\n";
#
#rename "guild_details_new.csv", "guild_details.csv" || die "unable to rename file: $!\n";

exit;

