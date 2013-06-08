#!perl -w

use strict;

use GW2API;

my $api = GW2API->new;

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

open(OMAIN, $mode, "recipes.csv") or die "unable to open file: $!\n";

open(ORECIP, $mode, "recipe_ingredients.csv") or die "unable to open file: $!\n";

if ($mode eq ">") {
  print OMAIN "recipe_id|type|output_item_id|output_item_count|min_rating|time_to_craft_ms|disciplines|flags\n";

  print ORECIP "recipe_id|item_id|count\n";
}

my $i = 0;
my $recipe_id;
foreach $recipe_id ($api->recipes()) {

  next if ($recipe_id ~~ @prior_ids);
  my %recipe_details = $api->recipe_details($recipe_id);

  my $type              = $recipe_details{type};
  my $output_item_id    = $recipe_details{output_item_id};
  my $output_item_count = $recipe_details{output_item_count};
  my $min_rating        = $recipe_details{min_rating};
  my $time_to_craft_ms  = $recipe_details{time_to_craft_ms};
  my $disciplines       = $recipe_details{disciplines};
  my $flags             = $recipe_details{flags};
  my $ingredients       = $recipe_details{ingredients};

  print OMAIN "$recipe_id|$type|$output_item_id|$output_item_count|$min_rating|$time_to_craft_ms"
            . "|" . join(',', @$disciplines)
            . "|" . join(',', @$flags)
            . "\n";

  foreach my $ingredient (@$ingredients) {
    my $item_id = $ingredient->{item_id};
    my $count   = $ingredient->{count};

    print ORECIP "$recipe_id|$item_id|$count\n";
  }

  print "$i\n" if ($i++ % 1000) == 0;
}

print "$i recipes processed.\n";

close (OMAIN);
close (ORECIP);

exit;

