#!perl -w

use Modern::Perl '2012';

use GuildWars2::API;

my $api = GuildWars2::API->new;

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

open(OINGRD, $mode, "recipe_ingredients.csv") or die "unable to open file: $!\n";

if ($mode eq ">") {
  say OMAIN "recipe_id|type|output_item_id|output_item_count|min_rating|time_to_craft_ms|unlock_method|armorsmith|artificer|chef|huntsman|jeweler|leatherworker|tailor|weaponsmith";

  say OINGRD "recipe_id|item_id|count";
}

my $i = 0;
my $recipe_id;
foreach $recipe_id ($api->list_recipes()) {

  next if ($recipe_id ~~ @prior_ids);
  my $recipe = $api->get_recipe($recipe_id);

  my $recipe_type       = $recipe->recipe_type;
  my $output_item_id    = $recipe->output_item_id;
  my $output_item_count = $recipe->output_item_count;
  my $min_rating        = $recipe->min_rating;
  my $time_to_craft_ms  = $recipe->time_to_craft_ms;
  my $disciplines       = $recipe->disciplines;
  my $unlock_method     = $recipe->unlock_method;
  my $ingredients       = $recipe->ingredients;

  say OMAIN "$recipe_id|$recipe_type|$output_item_id|$output_item_count|$min_rating|$time_to_craft_ms|$unlock_method"
            . "|" . join('|', @$disciplines)
            ;

  foreach my $item_id (keys %$ingredients) {
    my $count   = $ingredients->{$item_id};

    say OINGRD "$recipe_id|$item_id|$count";
  }

  say $i if ($i++ % 1000) == 0;
}

say "$i recipes processed.";

close (OMAIN);
close (OINGRD);

exit;

