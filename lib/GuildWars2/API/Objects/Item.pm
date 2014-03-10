use Carp ();
use Modern::Perl '2012';

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

my @_default_flags = qw( AccountBound HideSuffix NoMysticForge NoSalvage NoSell NotUpgradeable NoUnderwater SoulBindOnAcquire SoulBindOnUse Unique );

enum 'ItemType', [qw(
    Armor Back Bag Consumable Container CraftingMaterial Gathering Gizmo MiniPet
    Tool Trinket Trophy UpgradeComponent Weapon
  )];

enum 'ItemSubtype', [
    # Common
    qw(null Default),
    # Armor
    qw(Boots Coat Gloves Helm HelmAquatic Leggings Shoulders),
    # Consumable
    qw(AppearanceChange Booze ContractNpc Food Generic Halloween Immediate Transmutation Unknown Unlock Utility),
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
  ];

enum 'ItemRarity', [qw( Junk Basic Fine Masterwork Rare Exotic Ascended Legendary )];

enum 'ArmorClass', [qw( Clothing Light Medium Heavy )];
enum 'ArmorRace', [qw( Asura Charr Human Norn Sylvari )];
enum 'DamageType', [qw( Fire Ice Lightning Physical )];
enum 'InfusionType', [qw( Defense Offense Omni Utility )];
enum 'UnlockType', [qw( BagSlot BankTab CraftingRecipe Dye Unknown )];
enum 'UpgradeAType', [qw( All Armor Trinket Weapon )];

has 'item_id'           => ( is => 'ro', isa => 'Int',            required => 1 );
has 'item_name'         => ( is => 'ro', isa => 'Str',            required => 1 );
has 'item_type'         => ( is => 'ro', isa => 'ItemType',       required => 1 );
has 'level'             => ( is => 'ro', isa => 'Int',            required => 1 );
has 'rarity'            => ( is => 'ro', isa => 'ItemRarity',     required => 1 );
has 'vendor_value'      => ( is => 'ro', isa => 'Int',            required => 1 );
has 'game_type_flags'   => ( is => 'ro', isa => 'HashRef[Bool]',  required => 1 );
has 'item_flags'        => ( is => 'ro', isa => 'HashRef[Bool]',  required => 1 );
has 'icon_file_id'      => ( is => 'ro', isa => 'Int',            required => 1 );
has 'icon_signature'    => ( is => 'ro', isa => 'Str',            required => 1 );
has 'description'       => ( is => 'ro', isa => 'Str'           );
has 'item_subtype'      => ( is => 'ro', isa => 'ItemSubtype'   );
has 'item_attributes'   => ( is => 'ro', isa => 'HashRef[Int]'  );
has 'buff_skill_id'     => ( is => 'ro', isa => 'Int'           );
has 'buff_desc'         => ( is => 'ro', isa => 'Str'           );
has 'infusion_slot'     => ( is => 'ro', isa => 'Str'           );
has 'suffix_item_id'    => ( is => 'ro', isa => 'Str'           );
has 'armor_class'       => ( is => 'ro', isa => 'ArmorClass'    );
has 'defense'           => ( is => 'ro', isa => 'Int'           );
has 'armor_race'        => ( is => 'ro', isa => 'ArmorRace'     );
has 'bag_size'          => ( is => 'ro', isa => 'Int'           );
has 'invisible'         => ( is => 'ro', isa => 'Bool'          );
has 'food_duration_sec' => ( is => 'ro', isa => 'Str'           );
has 'food_description'  => ( is => 'ro', isa => 'Str'           );
has 'unlock_type'       => ( is => 'ro', isa => 'UnlockType'    );
has 'unlock_color_id'   => ( is => 'ro', isa => 'Str'           );
has 'unlock_recipe_id'  => ( is => 'ro', isa => 'Str'           );
has 'charges'           => ( is => 'ro', isa => 'Int'           );
has 'applies_to'        => ( is => 'ro', isa => 'UpgradeAType'  );
has 'suffix'            => ( is => 'ro', isa => 'Str'           );
has 'infusion_type'     => ( is => 'ro', isa => 'InfusionType'  );
has 'rune_bonuses'      => ( is => 'ro', isa => 'ArrayRef[Str]' );
has 'damage_type'       => ( is => 'ro', isa => 'DamageType'    );
has 'min_strength'      => ( is => 'ro', isa => 'Int'           );
has 'max_strength'      => ( is => 'ro', isa => 'Int'           );
has 'raw_json'          => ( is => 'ro', isa => 'Str', writer => '_set_json' );
has 'raw_md5'           => ( is => 'ro', isa => 'Str', writer => '_set_md5'  );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  # Rename and strip/replace embedded newlines
  if(my $a = delete $args->{name}) { ($args->{item_name} = $a) =~ s/\n//g }
  if(my $a = delete $args->{type}) { $args->{item_type} = $a }
  if(my $a = delete $args->{description}) { ($args->{description} = $a) =~ s/\n/<br>/g }
  if(my $a = delete $args->{type_data}->{type}) { $args->{item_subtype} = $a }
  if(my $a = delete $args->{icon_file_signature}) { $args->{icon_signature} = $a }
  if(my $a = delete $args->{type_data}->{suffix_item_id}) { $args->{suffix_item_id} = $a }
  if(my $a = delete $args->{type_data}->{weight_class}) { $args->{armor_class} = $a }
  if(my $a = delete $args->{type_data}->{defense}) { $args->{defense} = $a }
  if(my $a = delete $args->{type_data}->{size}) { $args->{bag_size} = $a }
  if(my $a = delete $args->{type_data}->{duration_ms}) { $args->{food_duration_sec} = $a / 1000 }
  if(my $a = delete $args->{type_data}->{description}) { ($args->{food_description} = $a) =~ s/\n/<br>/g }
  if(my $a = delete $args->{type_data}->{unlock_type}) { $args->{unlock_type} = $a }
  if(my $a = delete $args->{type_data}->{color_id}) { $args->{unlock_color_id} = $a }
  if(my $a = delete $args->{type_data}->{recipe_id}) { $args->{unlock_recipe_id} = $a }
  if(my $a = delete $args->{type_data}->{suffix}) { $args->{suffix} = $a }
  if(my $a = delete $args->{type_data}->{no_sell_or_sort}) { $args->{invisible} = $a }
  if(my $a = delete $args->{type_data}->{min_power}) { $args->{min_strength} = $a }
  if(my $a = delete $args->{type_data}->{max_power}) { $args->{max_strength} = $a }
  if(my $a = delete $args->{type_data}->{damage_type}) { $args->{damage_type} = $a }

  if(my $a = delete $args->{type_data}->{bonuses}) {
    s/\n/<br>/g for @$a;
    $args->{rune_bonuses} = $a;
  }

  # Restrictions --  Armor only
  if(my $r = delete $args->{restrictions}) {
    # A single item (17012) has restrictions = [Guardian,Warrior]
    # All others have a single race name as value
    # This filters any item with more than 1 value
    if (@$r == 1) {
      $args->{armor_race} = $r->[0];
    }
  }

  # Infusion slot -- equippable items (Armor/Trinket/Weapon) only
  $args->{infusion_slot} = "";
  if(my $i = delete $args->{type_data}->{infusion_slots}) {
    # Cheat on the assumption that no item has more than 1 slot and no slot has more than 1 type
    $args->{infusion_slot} = $i->[0]->{flags}->[0] || "";
  }

  # infusion_upgrade_flags -- UpgradeComponent->Default (infusion) only
  if(my $iuf = delete $args->{type_data}->{infusion_upgrade_flags}) {
    if (scalar @$iuf > 0) {
      $args->{infusion_type} = (@$iuf == 3) ? 'Omni' : $iuf->[0];
    }
  }

  # Attachment flags -- UpgradeComponent only
  if(my $flags = delete $args->{type_data}->{flags}) {
    # Making assumptions about the only valid flag combinations
    for (scalar @$flags) {
      $args->{applies_to} = 'Trinket' when 1;
      $args->{applies_to} = 'Armor'   when 3;
      $args->{applies_to} = 'Weapon'  when 19;
      $args->{applies_to} = 'All'     when 23;
    }
  }

  # infix_upgrade -- equippable items and UpgradeComponent only
  if(my $infix = delete $args->{type_data}->{infix_upgrade}) {
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

  # Transform from array[str] to hash[bool]
  if(my $gametypes = delete $args->{game_types}) {
    $args->{game_type_flags} = { map { $_ => 0 } @_default_gametypes };
    foreach my $g (@$gametypes) {
      $args->{game_type_flags}->{$g} = 1;
    }
  }

  # Transform from array[str] to hash[bool]
  if(my $flags = delete $args->{flags}) {
    $args->{item_flags} = { map { $_ => 0 } @_default_flags };
    foreach my $f (@$flags) {
      $f =~ s/Soulbind/SoulBind/; # for consistent sorting between SoulbindOnAcquire and SoulBindOnUse
      $args->{item_flags}->{$f} = 1;
    }
  }

  $class->$orig($args);
};

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

=item armor_class

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
