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

if (defined($ARGV[0]) && $ARGV[0] eq "clean") {
  $mode = ">";
}

open(OMAIN, $mode, "objective_names.csv") or die "unable to open file: $!\n";

if ($mode eq ">") {
  print OMAIN "objective_id|name\n";
}

my %objectives = $api->objective_names();

foreach my $objective_id (keys %objectives) {
  print OMAIN "$objective_id|$objectives{$objective_id}\n";
}

close (OMAIN);

exit;

