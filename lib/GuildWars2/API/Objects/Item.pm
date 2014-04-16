use Modern::Perl '2014';

=pod

=head1 DESCRIPTION

This subclass of GuildWars2::API::Objects defines the different item objects.

=cut

####################
# Item
####################
package GuildWars2::API::Objects::Item;
use namespace::autoclean;
use Moose;
use Moose::Util::TypeConstraints;

use GuildWars2::API::Constants;
use GuildWars2::API::Utils;

with 'GuildWars2::API::Objects::Linkable';

=pod

=head1 CLASSES

=head2 Item

The Item class is the base for all types of items. It includes the Linkable role
for generating game links, defined in Linkable.pm.

For some types, additional roles are included into this base class which define
additional attributes.

=head3 Attributes

=over

=item item_id

The internal ID of the item.

=item item_name

The item's name.

=item item_type
=item item_subtype

The item's primary and secondary types. The primary type determines the
specific class of object that this module builds. If the primary type has no
subtypes, then C<item_subtype> will be set to 'null'. Possible combinations:

  B<item_type>
    B<item_subtype>
  Armor
    Boots
    Coat
    Gloves
    Helm
    HelmAquatic
    Leggings
    Shoulders
  Back
  Bag
  Consumable
    AppearanceChange
    Booze
    ContractNpc
    Food
    Generic
    Halloween
    Immediate
    Transmutation
    Unknown
    Unlock
    Utility
  Container
    Default
    GiftBox
  CraftingMaterial
  Gathering
    Foraging
    Logging
    Mining
  Gizmo
    Default
    RentableContractNpc
    UnlimitedConsumable
  MiniPet
  Tool
    Salvage
  Trinket
    Accessory
    Amulet
    Ring
  Trophy
  UpgradeComponent
    Default
    Gem
    Rune
    Sigil
  Weapon
    Axe
    Dagger
    Focus
    Greatsword
    Hammer
    Harpoon
    LargeBundle
    LongBow
    Mace
    Pistol
    Rifle
    Scepter
    Shield
    ShortBow
    Speargun
    Staff
    Sword
    Torch
    Toy
    Trident
    TwoHandedToy
    Warhorn

=item description

The item's description.

=item level

The required character level to use the item. I<UpgradeComponent type only>: The
required item level for attaching this upgrade.

=item rarity

The item's rarity. Possible values:

 Junk
 Basic
 Fine
 Masterwork
 Rare
 Exotic
 Ascended
 Legendary

=item vendor_value

The amount of coin received for selling the item to a vendor.

=item game_type_flags

A hash of boolean flags identifying the game types where the item can be
used. Keys:

 Activity
 Dungeon
 Pve
 Pvp
 PvpLobby
 Wvw

=item item_flags

A hash of boolean flags identifying how the item behaves. Keys and descriptions:

 Flag               Meaning
 -----------------  ------------------------------------------------------------
 AccountBound       Item is account bound, meaning it cannot be listed on the
                      Trading Post or attached to a mail message.
 HideSuffix         Item's name does not change to reflect the attached upgrade.
 NoMysticForge      Item cannot be placed in the Mystic Forge.
 NoSalvage          Item cannot be salvaged.
 NoSell             Item cannot be sold to vendors.
 NotUpgradeable     Item does not have an upgrade slot.
 NoUnderwater       Item cannot be used in underwater mode.
 SoulBindOnAcquire  Item is soulbound to the character who acquired it, i.e. it
                      can only be equipped by that character (account bound
                      restrictions also apply).
 SoulBindOnUse      Item becomes soulbound when it is equipped.
 Unique             Only 1 copy of this item can be equipped on a character at
                      a time.

=item item_warnings

If any inconsistencies or unknown values are encountered while parsing the API
response, a warning message will be returned in this attribute.

=back

=head3 Methods

=over

=item $item->game_link

Encodes and returns a game link using the item's C<item_id>. This link can be
copied and pasted into the in-game chat window to generate a chat link for the
item. Hovering on the chat link will produce a tooltip with the item's details,
and right-clicking the chat link for certain item types will give a shortcut
menu.

=back

=cut

my @_default_gametypes = qw( Activity Dungeon Pve Pvp PvpLobby Wvw );

my @_default_flags = qw( AccountBound HideSuffix NoMysticForge NoSalvage NoSell NotUpgradeable NoUnderwater SoulbindOnAcquire SoulBindOnUse Unique );

my %enum_map = (
  'item_type' => [qw(
      Armor Back Bag Consumable Container CraftingMaterial Gathering Gizmo MiniPet
      Tool Trinket Trophy UpgradeComponent Weapon
    )],
  'item_subtype' => [
      # Common
      # Subtype is not used by (is null for): Back Bag CraftingMaterial MiniPet Trophy
      # Default used by: Container Gizmo UpgradeComponent
      qw(null Default Unknown),
      # Armor
      qw(Boots Coat Gloves Helm HelmAquatic Leggings Shoulders),
      # Consumable
      qw(AppearanceChange Booze ContractNpc Food Generic Halloween Immediate Transmutation Unlock UnTransmutation UpgradeRemoval Utility),
      # Container
      qw(GiftBox),
      # Gathering
      qw(Foraging Logging Mining),
      # Gizmo
      qw(RentableContractNpc UnlimitedConsumable),
      # Tool
      qw(Salvage),
      # Trinket
      qw(Accessory Amulet Ring),
      # UpgradeComponent
      qw(Gem Rune Sigil),
      # Weapon
      qw(Axe Dagger Focus Greatsword Hammer Harpoon LargeBundle LongBow Mace Pistol Rifle
         Scepter Shield ShortBow Speargun Staff Sword Torch Toy Trident TwoHandedToy Warhorn)
    ],
  'rarity' => [qw( Junk Basic Fine Masterwork Rare Exotic Ascended Legendary )],
  'armor_weight' => [qw( Clothing Light Medium Heavy )],
  'armor_race' => [qw( Asura Charr Human Norn Sylvari )],
  'damage_type' => [qw( Fire Ice Lightning Physical )],
  'infusion_type' => [qw( Agony Defense Offense Omni Utility )],
  'infusion_slot_type' => [qw( Defense Offense Utility )],
  'unlock_type' => [qw( BagSlot BankTab CollectibleCapacity Content CraftingRecipe Dye )],
  'upgrade_atype' => [qw( All Armor Trinket Weapon )],
);

enum 'ItemType',          $enum_map{'item_type'};
enum 'ItemSubtype',       $enum_map{'item_subtype'};
enum 'ItemRarity',        $enum_map{'rarity'};
enum 'ArmorWeight',       $enum_map{'armor_weight'};
enum 'ArmorRace',         $enum_map{'armor_race'};
enum 'DamageType',        $enum_map{'damage_type'};
enum 'InfusionType',      $enum_map{'infusion_type'};
enum 'InfusionSlotType',  $enum_map{'infusion_slot_type'};
enum 'UnlockType',        $enum_map{'unlock_type'};
enum 'UpgradeAType',      $enum_map{'upgrade_atype'};


has 'item_id'               => ( is => 'ro', isa => 'Int',            required => 1 );
has 'item_name'             => ( is => 'ro', isa => 'Str',            required => 1 );
has 'item_type'             => ( is => 'ro', isa => 'ItemType',       required => 1 );
has 'level'                 => ( is => 'ro', isa => 'Int',            required => 1 );
has 'rarity'                => ( is => 'ro', isa => 'ItemRarity',     required => 1 );
has 'vendor_value'          => ( is => 'ro', isa => 'Int',            required => 1 );
has 'game_type_flags'       => ( is => 'ro', isa => 'HashRef[Bool]',  required => 1 );
has 'item_flags'            => ( is => 'ro', isa => 'HashRef[Bool]',  required => 1 );
has 'icon_file_id'          => ( is => 'ro', isa => 'Int',            required => 1 );
has 'icon_signature'        => ( is => 'ro', isa => 'Str',            required => 1 );
has 'description'           => ( is => 'ro', isa => 'Str'           );
has 'item_subtype'          => ( is => 'ro', isa => 'ItemSubtype'   );
has 'item_attributes'       => ( is => 'ro', isa => 'HashRef[Int]'  );
has 'buff_skill_id'         => ( is => 'ro', isa => 'Int'           );
has 'buff_desc'             => ( is => 'ro', isa => 'Str'           );
has 'infusion_slot_1_type'  => ( is => 'ro', isa => 'Str'           );
has 'infusion_slot_1_item'  => ( is => 'ro', isa => 'Int'           );
has 'infusion_slot_2_type'  => ( is => 'ro', isa => 'Str'           );
has 'infusion_slot_2_item'  => ( is => 'ro', isa => 'Int'           );
has 'suffix_item_id'        => ( is => 'ro', isa => 'Str'           );
has 'suffix_2_item_id'      => ( is => 'ro', isa => 'Str'           );
has 'armor_weight'          => ( is => 'ro', isa => 'ArmorWeight'   );
has 'defense'               => ( is => 'ro', isa => 'Int'           );
has 'armor_race'            => ( is => 'ro', isa => 'ArmorRace'     );
has 'bag_size'              => ( is => 'ro', isa => 'Int'           );
has 'invisible'             => ( is => 'ro', isa => 'Bool'          );
has 'food_duration_sec'     => ( is => 'ro', isa => 'Str'           );
has 'food_description'      => ( is => 'ro', isa => 'Str'           );
has 'unlock_type'           => ( is => 'ro', isa => 'UnlockType'    );
has 'unlock_color_id'       => ( is => 'ro', isa => 'Str'           );
has 'unlock_recipe_id'      => ( is => 'ro', isa => 'Str'           );
has 'charges'               => ( is => 'ro', isa => 'Int'           );
has 'upgrade_type'          => ( is => 'ro', isa => 'UpgradeAType'  );
has 'suffix'                => ( is => 'ro', isa => 'Str'           );
has 'infusion_type'         => ( is => 'ro', isa => 'InfusionType'  );
has 'rune_bonuses'          => ( is => 'ro', isa => 'ArrayRef[Str]' );
has 'damage_type'           => ( is => 'ro', isa => 'DamageType'    );
has 'min_strength'          => ( is => 'ro', isa => 'Int'           );
has 'max_strength'          => ( is => 'ro', isa => 'Int'           );
has 'item_warnings'         => ( is => 'ro', isa => 'Str'           );
has 'raw_json'              => ( is => 'ro', isa => 'Str', writer => '_set_json' );
has 'raw_md5'               => ( is => 'ro', isa => 'Str', writer => '_set_md5'  );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  local $" = ','; #" # <-- this is to satisfy syntax highlighting that can't interpret $" as a variable name

  # Renames and simple transforms (strip/convert newlines, etc.)
  if(my $a = delete $args->{name}) { ($args->{item_name} = $a) =~ s/\n//g }
  if(my $a = delete $args->{type}) { $args->{item_type} = $a }
  if(my $a = delete $args->{description}) { ($args->{description} = $a) =~ s/\n/<br>/g }
  if(my $a = delete $args->{icon_file_signature}) { $args->{icon_signature} = $a }
  if(my $a = delete $args->{secondary_suffix_item_id}) { $args->{suffix_2_item_id} = $a }

  if (my $tdata = delete $args->{type_data}) {
    if(my $a = delete $tdata->{type}) { $args->{item_subtype} = $a }
    if(my $a = delete $tdata->{suffix_item_id}) { $args->{suffix_item_id} = $a }
    if(my $a = delete $tdata->{weight_class}) { $args->{armor_weight} = $a }
    if(my $a = delete $tdata->{defense}) { $args->{defense} = $a }
    if(my $a = delete $tdata->{size}) { $args->{bag_size} = $a }
    if(my $a = delete $tdata->{duration_ms}) { $args->{food_duration_sec} = $a / 1000 }
    if(my $a = delete $tdata->{description}) { ($args->{food_description} = $a) =~ s/\n/<br>/g }
    if(my $a = delete $tdata->{unlock_type}) { $args->{unlock_type} = $a }
    if(my $a = delete $tdata->{color_id}) { $args->{unlock_color_id} = $a }
    if(my $a = delete $tdata->{recipe_id}) { $args->{unlock_recipe_id} = $a }
    if(my $a = delete $tdata->{suffix}) { $args->{suffix} = $a }
    if(my $a = delete $tdata->{no_sell_or_sort}) { $args->{invisible} = $a }
    if(my $a = delete $tdata->{min_power}) { $args->{min_strength} = $a }
    if(my $a = delete $tdata->{max_power}) { $args->{max_strength} = $a }
    if(my $a = delete $tdata->{damage_type}) { $args->{damage_type} = $a }
    if(my $a = delete $tdata->{infusion_slots}) { $args->{infusion_slots} = $a }
    if(my $a = delete $tdata->{infusion_upgrade_flags}) { $args->{infusion_upgrade_flags} = $a }
    if(my $a = delete $tdata->{flags}) { $args->{upgrade_flags} = $a }
    if(my $a = delete $tdata->{bonuses}) { s/\n/<br>/g for @$a; $args->{rune_bonuses} = $a; }

    if (my $infix = delete $tdata->{infix_upgrade}) {
      if(my $a = delete $infix->{buff}->{skill_id})    { $args->{buff_skill_id} = $a }
      if(my $a = delete $infix->{buff}->{description}) { ($args->{buff_desc} = $a) =~ s/\n/<br>/g }
      if(my $attributes = delete $infix->{attributes}) {
        if (scalar @$attributes > 0) {
          foreach my $a (@$attributes) {
            $args->{item_attributes}->{$a->{attribute}} = $a->{modifier};
          }
        }
      }
    }
  }

  # Validation of enumerated fields
  _validate_enum($args, 'item_type');
  _validate_enum($args, 'item_subtype');
  _validate_enum($args, 'rarity');
  _validate_enum($args, 'armor_weight');
  _validate_enum($args, 'damage_type');
  _validate_enum($args, 'unlock_type');

  # Restrictions - returned as a list, only single value is meaningful
  # Two items (17012, 18165) have restrictions = [Guardian,Warrior]
  # Otherwise this element is only used to define racial armor restrictions
  if(my $r = delete $args->{restrictions}) {
    if (@$r == 1 && in($r->[0], $enum_map{'armor_race'})) {
      $args->{armor_race} = $r->[0];
    } elsif (@$r > 0) {
      $args->{item_warnings} .= "Unrecognized restrictions [@$r]\n";
    }
  }

  # Infusion slots - returned as a list of 'flag' lists
  #   'flags' list has never been seen with more than 1 value
  #   Agony type slots are returned as an empty 'flags' list, we assume all empty lists are Agony
  if(my $i = delete $args->{infusion_slots}) {
    my $x = 1;
    foreach my $s (@$i) {
      my $f = $s->{flags};
      if (@$f == 1 && in($f->[0], $enum_map{'infusion_slot_type'})) {
        $args->{"infusion_slot_".$x."_type"} = $f->[0];
      } elsif (@$f == 0) {
        $args->{"infusion_slot_".$x."_type"} = 'Agony';
      } else {
        $args->{item_warnings} .= "Unrecognized infusion_slot flags: [@$f]\n";
      }
      if (my $slot_item_id = delete $s->{item_id}) {
        $args->{"infusion_slot_".$x."_item"} = $slot_item_id;
      }
      $x++;
    }
  }

  # Infusion upgrade flags - returned as a list, only single value is meaningful
  # Omni infusions are returned as a list of ['Offense', 'Defense', 'Utility']
  #   so we translate that to a single value
  # Agony infusions have an empty list and are called '+<x> Agony Infusion'
  if(my $iuf = delete $args->{infusion_upgrade_flags}) {
    @$iuf = sort @$iuf;
    if (@$iuf == 1 && in($iuf->[0], $enum_map{'infusion_slot_type'})) {
      $args->{infusion_type} = $iuf->[0];
    } elsif (@$iuf == 3 && array_match( $iuf, $enum_map{'infusion_slot_type'})) {
      $args->{infusion_type} = 'Omni';
    } elsif (@$iuf == 0 && $args->{item_name} =~ /Agony Infusion/) {
      $args->{infusion_type} = 'Agony';
    } elsif (@$iuf > 0) {
      $args->{item_warnings} .= "Unrecognized infusion_upgrade_flags [@$iuf]\n";
    }
  }

  # UpgradeComponent flags
  if(my $uf = delete $args->{upgrade_flags}) {
    # Making assumptions about the only valid flag combinations
    for (scalar @$uf) {
      if ($_ == 1) {
        $args->{upgrade_type} = 'Trinket';
      } elsif ($_ == 3) {
        $args->{upgrade_type} = 'Armor';
      } elsif ($_ == 19) {
        $args->{upgrade_type} = 'Weapon';
      } elsif ($_ == 23) {
        $args->{upgrade_type} = 'All';
      } else {
        $args->{item_warnings} .= "Unrecognized upgrade flags [@$uf]\n";
      }
    }
  }

  # Transform from array[str] to hash[bool]
  if(my $gametypes = delete $args->{game_types}) {
    $args->{game_type_flags} = { map { $_ => 0 } @_default_gametypes };
    foreach my $g (@$gametypes) {
      $args->{item_warnings} .= "Unrecognized game_type [$g]\n" unless in($g, \@_default_gametypes);
      $args->{game_type_flags}->{$g} = 1;
    }
  }

  # Transform from array[str] to hash[bool]
  if(my $flags = delete $args->{flags}) {
    $args->{item_flags} = { map { $_ => 0 } @_default_flags };
    foreach my $f (@$flags) {
      $args->{item_warnings} .= "Unrecognized item flag [$f]\n" unless in($f, \@_default_flags);
      $args->{item_flags}->{$f} = 1;
    }
  }

  $class->$orig($args);
};

# Method to perform "soft" validations on enumerated fields
# Invalid values will add a warning to $args->{moose_warnings} and blank the output field
sub _validate_enum {
  my ($args, $field) = @_;
  my $a = $args->{$field};
  return if !$a;
  unless (in($a, $enum_map{$field})) {
    $args->{item_warnings} .= "Unrecognized $field: [$a].\n";
    $args->{$field} = '';
  }
}

# Method required to provide type and ID to Linkable role
sub _gl_data {
  my ($self) = @_;
  return (ITEM_LINK_TYPE, $self->item_id);
}

# Method for determining prefix based on attributes
# Private method, called by C<GuildWars2::API->prefix_lookup($item)>
sub _prefix_lookup {
  my ($self, $prefix_map) = @_;
  if (ref($self->item_attributes) eq 'HASH') {
    my $atts = $self->item_attributes;
    my @sorted_atts = sort { $atts->{$b} <=> $atts->{$a} or $a cmp $b } keys %$atts;
    tr/A-Z/a-z/ for @sorted_atts;

    # Giver's items are anomalous - weapons and armor give Condition and Boon
    # Duration, respectively, but as an infixed buff rather than as part of the
    # attributes list.
    if (defined($self->buff_skill_id)) {
      if ($self->buff_skill_id == 16631) {          # "+10% Condition Duration", Giver's weapons
        unshift(@sorted_atts,'conditionduration');  # Always a major attribute, so unshift onto front of list
      } elsif ($self->buff_skill_id == 16517) {     # "+1% Boon Duration", Giver's armor/trinkets
        splice(@sorted_atts,1,1,'boonduration');    # Always a minor attribute and first alphbetically, so splice it into the second position
      }
    }

    $atts = join(',', @sorted_atts);

    my $prefix = exists($prefix_map->{$atts}) ? $prefix_map->{$atts} : 'unknown';

    return $prefix;
  }
  else { return 'n/a' }
}


=pod

=head2 Item::Infixed

The Item::Infixed role defines the common features of "infixed" item types:
anything that is Equippable, as well as the UpgradeComponent type.

=head3 Attributes

=over

=item item_attributes

The character attributes that the item modifies, given as a hash with the
attribute names as the keys and the bonus amount as the values.

=item buff_skill_id

The internal ID of the buff effect that is placed on the character when the
item is equipped.

=item buff_desc

The description of the buff effect.

=back

=cut


=pod

=head2 Item::Equippable

The Item::Equippable role defines the common features of equippable item types:
Armor, Back, Trinket, and Weapon. It includes the Item::Infixed role.

=head3 Attributes

=over

=item infusion_slot

The type of infusion slot on the item, if it has one.

=item suffix_item_id

The internal ID of the upgrade component attached to the item.

=back

=cut



=pod

=head1 ROLES

=head2 Item::Armor

The Item::Armor role adds attributes specific to armor items. It includes the
Item::Equippable role.

=head3 Attributes

=over

=item armor_weight

The weight class of the armor.

 Clothing
 Heavy
 Light
 Medium

=item defense

The defense value of the armor.

=item race

The race that can equip the armor. Only applies to L<cultural
armor|http://wiki.guildwars2.com/wiki/Cultural_armor>.

 Asura
 Charr
 Human
 Norn
 Sylvari

=back

=cut




=pod

=head2 Item::Back

The Item::Back role adds attributes specific to back items. It includes the
Item::Equippable role, but does not add any attributes directly.

=cut

=pod

=head2 Item::Bag

The Item::Bag role adds attributes specific to bag items.

=head3 Attributes

=over

=item bag_size

The number of slots in the bag.

=item invisible

Boolean indicating whether the bag is "invisible," i.e. items in it do not
appear in vendor lists or the Trading Post and do not move when inventory is
sorted.

=back

=cut


=pod

=head2 Item::Consumable

The Item::Consumable role adds attributes specific to consumable items.

=head3 Attributes

=over

=item food_duration_sec

For Food subtypes, the duration in seconds of the food's Nourishment effect.

=item food_description

For Food subtypes, the description of the food's Nourishment effect.

=item unlock_type

For Unlock subtypes, the item's Unlock sub-subtype.

 BagSlot
 BankTab
 CraftingRecipe
 Dye
 Unknown

=item unlock_color_id

For Dye-type unlocks, the internal ID of the color unlocked by the item. This
can be used to look up the color data in the output of the C<<api->get_colors>>
method.

=item unlock_recipe_id

For CraftingRecipe-type unlocks, the internal ID of the recipe unlocked by the
item. This can be used to look up the recipe data with C<<$api-
>get_recipe($recipe_id)>>.

=back

=cut



=pod

=head2 Item::Tool

The Item::Tool role adds attributes specific to tool items.

=head3 Attributes

=over

=item charges

The number of charges the tool comes with.

=back

=cut




=pod

=head2 Item::Trinket

The Item::Trinket role adds attributes specific to trinket items. It includes
the Item::Equippable role, but does not add any attributes directly.

=cut


=pod

=head2 Item::UpgradeComponent

The Item::UpgradeComponent role adds attributes specific to upgrade
components. It includes the Item::Infixed role.

=head3 Attributes

=over

=item suffix

The suffix that the upgrade confers when it is attached to an item.

=item infusion_type

For C<item_subtype> of Infusion, the upgrade's infusion type.

 Defense
 Offense
 Omni
 Utility

=item rune_bonuses

For C<item_subtype> of Rune, the list of bonuses the rune confers, given as an
array.

=item applies_to

The type of equipment the upgrade can be applied to.

 All
 Armor
 Trinket
 Weapon

=back

=cut




=pod

=head2 Item::Weapon

The Item::Weapon role adds attributes specific to weapon items. It includes
the Item::Equippable role.

=head3 Attributes

=over

=item damage_type

The weapon's cosmetic damage type.

 Fire
 Ice
 Lightning
 Physical

=item min_strength
=item max_strength

The weapon's minimum and maximum strength ratings.

=item defense

For C<item_subtype> of Shield, the shield's defense value.

=back

=cut



1;
