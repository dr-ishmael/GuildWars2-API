#!perl -w

use Modern::Perl '2012';

use GuildWars2::API;

my $mode = ">>";
my @prior_ids = ();

if (defined($ARGV[0]) && $ARGV[0] eq "clean") {
  $mode = ">";
} else {
  # Read in item IDs that have already been processed.

  open (IMAIN, "items.csv") or die "unable to open file: $!";

  while (<IMAIN>) {
    my ($id) = split(/\|/, $_);
    push @prior_ids, $id;
  }

  close (IMAIN);
}

open(OMAIN, $mode, "items.csv") or die "unable to open file: $!\n";

open(OARMOR, $mode, "item_armor.csv") or die "unable to open file: $!\n";
open(OBACKX, $mode, "item_back.csv") or die "unable to open file: $!\n";
open(OBAGSX, $mode, "item_bags.csv") or die "unable to open file: $!\n";
open(OCONSM, $mode, "item_consumables.csv") or die "unable to open file: $!\n";
open(OTOOLX, $mode, "item_tools.csv") or die "unable to open file: $!\n";
open(OTRNKT, $mode, "item_trinkets.csv") or die "unable to open file: $!\n";
open(OUPGRD, $mode, "item_upgrade_components.csv") or die "unable to open file: $!\n";
open(OWEAPN, $mode, "item_weapons.csv") or die "unable to open file: $!\n";

open(OATTRB, $mode, "item_attributes.csv") or die "unable to open file: $!\n";
open(ORNBNS, $mode, "item_rune_bonuses.csv") or die "unable to open file: $!\n";

if ($mode eq ">") {
  say OMAIN "item_id|item_name|item_type|item_subtype|level|rarity|description|vendor_value"
          . "|Activity|Dungeon|Pve|Pvp|PvpLobby|Wvw" # game_type_flags
          . "|AccountBound|HideSuffix|NoMysticForge|NoSalvage|NoSell|NotUpgradeable|NoUnderwater|SoulbindOnAcquire|SoulBindOnUse|Unique" #item_flags
          ;

  say OARMOR "item_id|armor_type|armor_class|defense|race|infusion_slot|suffix_item_id|buff_skill_id|buff_desc";
  say OBACKX "item_id|infusion_slot|suffix_item_id|buff_skill_id|buff_desc";
  say OBAGSX "item_id|bag_size|invisible";
  say OCONSM "item_id|consumable_type|food_duration_ms|food_description|unlock_type|unlock_color_id|unlock_recipe_id";
  say OTOOLX "item_id|tool_type|charges";
  say OTRNKT "item_id|trinket_type|infusion_slot|suffix_item_id|buff_skill_id|buff_desc";
  say OUPGRD "item_id|upgrade_type|applies_to|suffix|infusion_type|buff_skill_id|buff_desc";
  say OWEAPN "item_id|weapon_type|damage_type|min_strength|max_strength|defense|infusion_slot|suffix_item_id|buff_skill_id|buff_desc";

  say OATTRB "item_id|attribute|modifier";
  say ORNBNS "item_id|bonus_1|bonus_2|bonus_3|bonus_4|bonus_5|bonus_6";
}

my $api = GuildWars2::API->new;

my $i = 0;
foreach my $item_id (sort { $a <=> $b } $api->list_items()) {

  next if ($item_id ~~ @prior_ids);

  my $item = $api->get_item($item_id);

  my $item_name       = $item->item_name;
  my $item_type       = $item->item_type;
  my $item_subtype    = $item->item_subtype || "";
  my $level           = $item->level;
  my $rarity          = $item->rarity;
  (my $description    = $item->description) =~ s/\n/<br>/g;
  my $vendor_value    = $item->vendor_value;
  my $game_type_flags = $item->game_type_flags;
  my $item_flags      = $item->item_flags;

  say OMAIN "$item_id|$item_name|$item_type|$item_subtype|$level|$rarity|$description|$vendor_value"
            . '|' . join('|', map { $game_type_flags->{$_} } sort keys %$game_type_flags )
            . '|' . join('|', map { $item_flags->{$_} } sort keys %$item_flags )
            ;

  #
  # Armor type data
  #
  if ($item_type eq "Armor") {
    my $armor_type      = $item->armor_type;
    my $armor_class     = $item->armor_class;
    my $defense         = $item->defense || "";
    my $race            = $item->race || "";
    my $infusion_slot   = $item->infusion_slot || "";
    my $suffix_item_id  = $item->suffix_item_id || "";
    my $buff_skill_id   = $item->buff_skill_id || "";
    (my $buff_desc       = $item->buff_desc || "") =~ s/\n/<br>/g;

    say OARMOR "$item_id|$armor_type|$armor_class|$defense|$race|$infusion_slot|$suffix_item_id|$buff_skill_id|$buff_desc";

    print_attributes($item);
  }

  #
  # Back type data
  #
  if ($item_type eq "Back") {
    my $infusion_slot   = $item->infusion_slot || "";
    my $suffix_item_id  = $item->suffix_item_id || "";
    my $buff_skill_id   = $item->buff_skill_id || "";
    (my $buff_desc       = $item->buff_desc || "") =~ s/\n/<br>/g;

    say OBACKX "$item_id|$infusion_slot|$suffix_item_id|$buff_skill_id|$buff_desc";

    print_attributes($item);
  }

  #
  # Bag type data
  #
  if ($item_type eq "Bag") {
    my $bag_size            = $item->bag_size;
    my $invisible           = $item->invisible;

    say OBAGSX "$item_id|$bag_size|$invisible";
  }

  #
  # Consumable type data
  #
  if ($item_type eq "Consumable") {
    my $consumable_type     = $item->consumable_type;
    my $food_duration_ms    = $item->food_duration_ms || "";
    my $food_description    = $item->food_description || "";
    my $unlock_type         = $item->unlock_type || "";
    my $unlock_color_id     = $item->unlock_color_id || "";
    my $unlock_recipe_id    = $item->unlock_recipe_id || "";

    $food_description =~ s/\n/<br>/g;
    say OCONSM "$item_id|$consumable_type|$food_duration_ms|$food_description|$unlock_type|$unlock_color_id|$unlock_recipe_id";
  }

  #
  # Tool type data
  #
  if ($item_type eq "Tool") {
    my $tool_type       = $item->tool_type;
    my $charges         = $item->charges;

    say OTOOLX "$item_id|$tool_type|$charges";
  }

  #
  # Trinket type data
  #
  if ($item_type eq "Trinket") {
    my $trinket_type    = $item->trinket_type;
    my $infusion_slot   = $item->infusion_slot || "";
    my $suffix_item_id  = $item->suffix_item_id || "";
    my $buff_skill_id   = $item->buff_skill_id || "";
    (my $buff_desc       = $item->buff_desc || "") =~ s/\n/<br>/g;

    say OTRNKT "$item_id|$trinket_type|$infusion_slot|$suffix_item_id|$buff_skill_id|$buff_desc";

    print_attributes($item);
  }

  #
  # UpgradeComponent type data
  #
  if ($item_type eq "UpgradeComponent") {
    my $upgrade_type    = $item->upgrade_type;
    my $applies_to      = $item->applies_to;
    my $suffix          = $item->suffix || "";
    my $infusion_type   = $item->infusion_type || "";
    my $buff_skill_id   = $item->buff_skill_id || "";
    (my $buff_desc       = $item->buff_desc || "") =~ s/\n/<br>/g;

    say OUPGRD "$item_id|$upgrade_type|$applies_to|$suffix|$infusion_type|$buff_skill_id|$buff_desc";

    print_attributes($item);

    my $rune_bonuses    = $item->rune_bonuses;
    if (defined($rune_bonuses)) {
      say ORNBNS "$item_id|" . join('|', @$rune_bonuses);
    }
  }

  #
  # Weapon type data
  #
  if ($item_type eq "Weapon") {

    my $weapon_type     = $item->weapon_type;
    my $damage_type     = $item->damage_type;
    my $min_strength    = $item->min_strength || "";
    my $max_strength    = $item->max_strength || "";
    my $defense         = $item->defense || "";
    my $infusion_slot   = $item->infusion_slot || "";
    my $suffix_item_id  = $item->suffix_item_id || "";
    my $buff_skill_id   = $item->buff_skill_id || "";
    (my $buff_desc       = $item->buff_desc || "") =~ s/\n/<br>/g;

    say OWEAPN "$item_id|$weapon_type|$damage_type|$min_strength|$max_strength|$defense|$infusion_slot|$suffix_item_id|$buff_skill_id|$buff_desc";

    print_attributes($item);
  }

  say ($i-1) if ($i++ % 1000) == 0;
}

say "$i items processed.";

close(OMAIN);

close(OARMOR);
close(OBACKX);
close(OBAGSX);
close(OCONSM);
close(OTOOLX);
close(OTRNKT);
close(OUPGRD);
close(OWEAPN);

close(OATTRB);
close(ORNBNS);

exit;


sub print_attributes {
  my ($item) = @_;

  if(defined($item->item_attributes)) {
    my $item_id         = $item->item_id;
    my $item_attributes = $item->item_attributes;

    foreach my $a (keys %$item_attributes) {
      my $m = $item_attributes->{$a};
      say OATTRB "$item_id|$a|$m";
    }
  }
}
