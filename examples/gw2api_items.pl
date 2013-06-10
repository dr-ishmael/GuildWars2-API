#!perl -w

use strict;

use GW2API;

sub print_attributes($$);
sub process_equipment($$);
sub process_infix($$);

my %known_keys = map { $_ => 1 } qw(armor back bag consumable container crafting_material description flags game_types gathering gizmo item_id level name rarity restrictions tool trinket trophy type upgrade_component vendor_value weapon);

my %known_subkeys = ();
$known_subkeys{Armor}             = { map { $_ => 1} qw(defense infix_upgrade infusion_slots suffix_item_id type weight_class) };
$known_subkeys{Back}              = { map { $_ => 1} qw(infix_upgrade infusion_slots suffix_item_id) };
$known_subkeys{Bag}               = { map { $_ => 1} qw(no_sell_or_sort size) };
$known_subkeys{Consumable}        = { map { $_ => 1} qw(color_id description duration_ms recipe_id type unlock_type) };
$known_subkeys{Container}         = { map { $_ => 1} qw(type) };
$known_subkeys{Gathering}         = { map { $_ => 1} qw(type) };
$known_subkeys{Gizmo}             = { map { $_ => 1} qw(type) };
$known_subkeys{Tool}              = { map { $_ => 1} qw(charges type) };
$known_subkeys{Trinket}           = { map { $_ => 1} qw(infix_upgrade infusion_slots suffix_item_id type) };
$known_subkeys{UpgradeComponent}  = { map { $_ => 1} qw(bonuses flags infix_upgrade infusion_upgrade_flags suffix type) };
$known_subkeys{Weapon}            = { map { $_ => 1} qw(damage_type defense infix_upgrade infusion_slots max_power min_power suffix_item_id type) };

my %types = (
  'Armor'             => 'armor',
  'Back'              => 'back',
  'Bag'               => 'bag',
  'Consumable'        => 'consumable',
  'Container'         => 'container',
  'CraftingMaterial'  => 'crafting_material',
  'Gathering'         => 'gathering',
  'Gizmo'             => 'gizmo',
  'MiniPet'           => 'mini_pet',
  'Tool'              => 'tool',
  'Trinket'           => 'trinket',
  'Trophy'            => 'trophy',
  'UpgradeComponent'  => 'upgrade_component',
  'Weapon'            => 'weapon'
);

my $mode = ">>";
my @prior_ids = ();

if (defined($ARGV[0]) && $ARGV[0] eq "clean") {
  $mode = ">";
} else {
  # Read in item IDs that have already been processed.

  open (IMAIN, "items.csv") or die "unable to open file: $!\n";

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
open(OINFSN, $mode, "item_infusions.csv") or die "unable to open file: $!\n";
open(ORNBNS, $mode, "item_rune_bonuses.csv") or die "unable to open file: $!\n";

open(OKEYS, $mode, "all_item_keys.csv") or die "unable to open file: $!\n";

if ($mode eq ">") {
  print OMAIN "item_id|name|description|flags|game_types|level|rarity|restrictions|type|subtype|vendor_value\n";

  print OARMOR "item_id|defense|suffix_item_id|weight_class|buff_skill_id|buff_desc\n";
  print OBACKX "item_id|suffix_item_id|buff_skill_id|buff_desc\n";
  print OBAGSX "item_id|no_sell_or_sort|size\n";
  print OCONSM "item_id|type|duration_ms|description|unlock_type|color_id|recipe_id\n";
  print OTOOLX "item_id|type|charges\n";
  print OTRNKT "item_id|suffix_item_id|type|buff_skill_id|buff_desc\n";
  print OUPGRD "item_id|flags|infusion_upgrade_flags|suffix|type|buff_skill_id|buff_desc\n";
  print OWEAPN "item_id|damage_type|defense|max_power|min_power|suffix_item_id|type|buff_skill_id|buff_desc\n";
  print ORNBNS "item_id|bonus_1|bonus_2|bonus_3|bonus_4|bonus_5|bonus_6\n";

  print OATTRB "item_id|attribute|modifier\n";
  print OINFSN "item_id|infusion_slot_flags\n";

  print OKEYS "item_id|key|subkey\n";
}

my $api = GW2API->new;

my $i = 0;
foreach my $item_id ($api->items()) {

  next if ($item_id ~~ @prior_ids);

  my %item_details = $api->item_details($item_id);

  my $description   = $item_details{description};
  my $flags         = $item_details{flags};
  my $game_types    = $item_details{game_types};
  my $level         = $item_details{level};
  my $name          = $item_details{name};
  my $rarity        = $item_details{rarity};
  my $restrictions  = $item_details{restrictions};
  my $type          = $item_details{type};
  my $vendor_value  = $item_details{vendor_value};

  my $type_data     = $item_details{$types{$type}};

  my $subtype = "";

  if (ref($type_data) eq "HASH" && defined($type_data->{type})) {
    $subtype = $type_data->{type};
  }

  $description =~ s/\n/<br>/g;

  print OMAIN "$item_id|$name|$description|"
            . join(',', @$flags) . '|'
            . join(',', @$game_types) . '|'
            . "$level|$rarity|"
            . join(',', @$restrictions) . '|'
            . "$type|$subtype|$vendor_value|\n";

  #
  # Armor type data
  #
  if ($type eq "Armor") {

    my $defense         = $type_data->{defense};
    my $suffix_item_id  = $type_data->{suffix_item_id};
    my $weight_class    = $type_data->{weight_class};

    my ( $buff_skill_id, $buff_desc ) = process_equipment($item_id,$type_data);

    print OARMOR "$item_id|$defense|$suffix_item_id|$weight_class|$buff_skill_id|$buff_desc\n";

  }

  #
  # Back type data
  #
  if ($type eq "Back") {

    my $suffix_item_id  = $type_data->{suffix_item_id};

    my ( $buff_skill_id, $buff_desc ) = process_equipment($item_id,$type_data);

    print OBACKX "$item_id|$suffix_item_id|$buff_skill_id|$buff_desc\n";

  }

  #
  # Bag type data
  #
  if ($type eq "Bag") {
    my $no_sell_or_sort     = $type_data->{no_sell_or_sort};
    my $size                = $type_data->{size};

    print OBAGSX "$item_id|$no_sell_or_sort|$size\n";

  }

  #
  # Consumable type data
  #
  if ($type eq "Consumable") {
    my $consumable_type     = $type_data->{type};
    my $duration_ms         = $type_data->{duration_ms} || "";
    my $cons_desc           = $type_data->{description} || "";
    my $unlock_type         = $type_data->{unlock_type} || "";
    my $color_id            = $type_data->{color_id} || "";
    my $recipe_id           = $type_data->{recipe_id} || "";

    $cons_desc =~ s/\n/<br>/g;

    print OCONSM "$item_id|$consumable_type|$duration_ms|$cons_desc|$unlock_type|$color_id|$recipe_id\n";

  }

  #
  # Trinket type data
  #
  if ($type eq "Trinket") {

    my $trinket_type    = $type_data->{type};
    my $suffix_item_id  = $type_data->{suffix_item_id};

    my ( $buff_skill_id, $buff_desc ) = process_equipment($item_id,$type_data);

    print OTRNKT "$item_id|$suffix_item_id|$trinket_type|$buff_skill_id|$buff_desc\n";

  }

  #
  # Tool type data
  #
  if ($type eq "Tool") {

    my $tool_type            = $type_data->{type};
    my $charges              = $type_data->{charges};

    print OTOOLX "$item_id|$tool_type|$charges\n";

  }

  #
  # UpgradeComponent type data
  #
  if ($type eq "UpgradeComponent") {

    my $upgrade_type            = $type_data->{type};
    my $flags                   = $type_data->{flags};
    my $infix_upgrade           = $type_data->{infix_upgrade};
    my $infusion_upgrade_flags  = $type_data->{infusion_upgrade_flags};
    my $bonuses                 = $type_data->{bonuses};
    my $suffix                  = $type_data->{suffix};

    my ( $buff_skill_id, $buff_desc ) = process_infix($item_id, $infix_upgrade);

    print OUPGRD "$item_id|"
               . join(',', @$flags) . '|'
               . join(',', @$infusion_upgrade_flags) . '|'
               . "$suffix|$upgrade_type|$buff_skill_id|$buff_desc\n";

    if (defined($bonuses)) {
      print ORNBNS "$item_id|" . join('|', @$bonuses) . "\n";
    }
  }

  #
  # Weapon type data
  #
  if ($type eq "Weapon") {

    my $damage_type     = $type_data->{damage_type};
    my $defense         = $type_data->{defense};
    my $max_power       = $type_data->{max_power};
    my $min_power       = $type_data->{min_power};
    my $suffix_item_id  = $type_data->{suffix_item_id};
    my $weapon_type     = $type_data->{type};

    my ( $buff_skill_id, $buff_desc ) = process_equipment($item_id,$type_data);

    print OWEAPN "$item_id|$damage_type|$defense|$max_power|$min_power|$suffix_item_id|$weapon_type|$buff_skill_id|$buff_desc\n";

  }


  foreach my $key (keys %item_details) {
    next if (exists($known_keys{$key}));
    print OKEYS "$item_id|$key\n";
  }

  if (ref($type_data) eq "HASH") {
    foreach my $key (keys $type_data) {
      next if (exists($known_subkeys{$type}{$key}));
      print OKEYS "$item_id|$type|$key\n";
    }
  }

  print "$i\n" if ($i++ % 1000) == 0;
}

print "$i items processed.\n";

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
close(OINFSN);

close(OKEYS);

exit;


sub print_attributes($$) {
  my ($item_id, $attributes) = @_;

  foreach my $attribute (@$attributes) {
    my $attr_name       = $attribute->{attribute};
    my $modifier        = $attribute->{modifier};

    print OATTRB "$item_id|$attr_name|$modifier\n";
  }
}


#
# Processes the "infix_upgrade" object. Parses the "attribute" subobject and
#  prints to OATTRB. Parses the "buff" subobject and returns as an array ref.
#
# @return array_ref(scalar, scalar)  buff_skill_id, buff_description
#
sub process_infix($$) {
  my ($item_id, $infix_upgrade) = @_;

  my $buff = "";
  my $buff_skill_id = "";
  my $buff_desc = "";

  # "infix_upgrade" can be either empty string or a JSON object
  if (ref($infix_upgrade) eq "HASH") {

    print_attributes($item_id, $infix_upgrade->{attributes});

    $buff = $infix_upgrade->{buff};

    # "buff" can be either empty string or a JSON object
    if (ref($buff) eq "HASH") {
      $buff_skill_id   = $buff->{skill_id};
      $buff_desc       = $buff->{description};
    }
  }

  $buff_desc =~ s/\n/<br>/g;

  return ( $buff_skill_id, $buff_desc );
}

#
# Processes the "infix_upgrade" and "infusion_slots" subobjects.
#
#  infix_upgrade (hash ref):
#   Parses the "attribute" subobject and prints to OATTRB.
#   Parses the "buff" subobject and returns as first 2 elements in array.
#
#  infusion_slots (array ref):
#   Parses each element in the array and prints to OINFSN.
#
# @return array_ref(scalar*2)  buff_skill_id, buff_description
#
sub process_equipment($$) {
  my ($item_id, $type_data) = @_;

  my $infix_upgrade   = $type_data->{infix_upgrade};

  my ( $buff_skill_id, $buff_desc ) = process_infix($item_id, $infix_upgrade);

  my $infusion_slots  = $type_data->{infusion_slots};

  # "infusion_slots" can be either empty string or a JSON array
  foreach my $infusion_slot (@$infusion_slots) {
    my $infusion_slot_flags = join(',', @{$infusion_slot->{flags}});

    print OINFSN "$item_id|$infusion_slot_flags\n";
  }

  return ( $buff_skill_id, $buff_desc );
}

