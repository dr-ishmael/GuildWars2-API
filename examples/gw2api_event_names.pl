#!perl -w

BEGIN { push @INC, '.'; $| = 1; }

my $old_warn_handler = $SIG{__WARN__};
$SIG{__WARN__} = sub {
    $old_warn_handler->(@_) if $old_warn_handler;
    die @_;
};

use strict;

use GW2API;

my $api = GW2API->new( cache_dir => './cached' );

my $mode = ">>";
my @prior_ids = ();

if (defined($ARGV[0]) && $ARGV[0] eq "clean") {
  $mode = ">";
} else {
  # Read in item IDs that have already been processed.
  
  open (IMAIN, "recipes.csv") or die "unable to open file: $!\n";
  
  while (<IMAIN>) {
    my ($id) = split(/\|/, $_);
    push @prior_ids, $id;
  }
  
  close (IMAIN);
}

open(OMAIN, $mode, "event_names.csv") or die "unable to open file: $!\n";

if ($mode eq ">") {
  print OMAIN "event_id|name\n";
}

my %events = $api->event_names();

foreach my $event_id (keys %events) {
  print OMAIN "$event_id|$events{$event_id}\n";
}

close (OMAIN);

exit;

