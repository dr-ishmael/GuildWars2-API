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

=head1 Classes

=head2 Item

The Item class is the base for all types of items. It includes the Linkable role
for generating game links, defined in Linkable.pm.

For some types, additional roles are included into this base class which define
additional attributes.

=head3 Attributes

=over

=item item_id

The internal ID of the item.

=item item_type

The item's type. This determines the specific class of object that this module
builds. Possible values:

 Armor
 Back
 Bag
 Consumable
 Container
 CraftingMaterial
 Gathering
 Gizmo
 MiniPet
 Tool
 Trinket
 Trophy
 UpgradeComponent
 Weapon

=item item_name

The item's name.

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
 SoulbindOnAcquire  Item is soulbound to the character who acquired it, i.e. it
                      can only be equipped by that character (account bound
                      restrictions also apply).
 SoulBindOnUse      Item becomes soulbound when it is equipped.
 Unique             Only 1 copy of this item can be equipped on a character at
                      a time.

=back

=cut

my @_default_gametypes = qw( Activity Dungeon Pve Pvp PvpLobby Wvw );

my @_default_flags = qw( AccountBound HideSuffix NoMysticForge NoSalvage NoSell NotUpgradeable NoUnderwater SoulbindOnAcquire SoulBindOnUse Unique );

enum 'ItemType', [qw(
    Armor Back Bag Consumable Container CraftingMaterial Gathering Gizmo MiniPet
    Tool Trinket Trophy UpgradeComponent Weapon
  )];

enum 'ItemRarity', [qw( Junk Basic Fine Masterwork Rare Exotic Ascended Legendary )];

has 'item_id'         => ( is => 'ro', isa => 'Int',            required => 1 );
has 'item_name'       => ( is => 'ro', isa => 'Str',            required => 1 );
has 'item_type'       => ( is => 'ro', isa => 'ItemType',       required => 1 );
has 'item_subtype'    => ( is => 'ro', isa => 'Str' );
has 'description'     => ( is => 'ro', isa => 'Str',            required => 1 );
has 'level'           => ( is => 'ro', isa => 'Int',            required => 1 );
has 'rarity'          => ( is => 'ro', isa => 'ItemRarity',     required => 1 );
has 'vendor_value'    => ( is => 'ro', isa => 'Int',            required => 1 );
has 'game_type_flags' => ( is => 'ro', isa => 'HashRef[Bool]',  required => 1 );
has 'item_flags'      => ( is => 'ro', isa => 'HashRef[Bool]',  required => 1 );
has 'icon_file_id'    => ( is => 'ro', isa => 'Int',            required => 1 );
has 'icon_signature'  => ( is => 'ro', isa => 'Str',            required => 1 );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  # Renames
  if(my $a = delete $args->{name}) { $args->{item_name} = $a }
  if(my $a = delete $args->{type}) { $args->{item_type} = $a }
  if(my $a = delete $args->{type_data}->{type}) { $args->{item_subtype} = $a }
  if(my $a = delete $args->{icon_file_signature}) { $args->{icon_signature} = $a }

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

####################
# Item->Infixed role
####################
package GuildWars2::API::Objects::Item::Infixed;
use namespace::autoclean;
use Moose::Role;
use Moose::Util::TypeConstraints;

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

has 'item_attributes' => ( is => 'ro', isa => 'HashRef[Int]' );
has 'buff_skill_id'   => ( is => 'ro', isa => 'Int' );
has 'buff_desc'       => ( is => 'ro', isa => 'Str' );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  if(my $infix = delete $args->{type_data}->{infix_upgrade}) {
    if(my $a = delete $infix->{buff}->{skill_id})    { $args->{buff_skill_id} = $a; }
    if(my $a = delete $infix->{buff}->{description}) { $args->{buff_desc}     = $a; }

    if(my $attributes = delete $infix->{attributes}) {
      foreach my $a (@$attributes) {
        $args->{item_attributes}->{$a->{attribute}} = $a->{modifier};
      }
    }
  }

  $class->$orig($args);
};

####################
# Item->Equippable role
####################
package GuildWars2::API::Objects::Item::Equippable;
use namespace::autoclean;
use Moose::Role;
use Moose::Util::TypeConstraints;

with 'GuildWars2::API::Objects::Item::Infixed';

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

has 'infusion_slot'   => ( is => 'ro', isa => 'Str' );
has 'suffix_item_id'  => ( is => 'ro', isa => 'Str' );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  $args->{infusion_slot} = "";
  if(my $i = delete $args->{type_data}->{infusion_slots}) {
    # Cheat on the assumption that no item has more than 1 slot and no slot has more than 1 type
    $args->{infusion_slot} = $i->[0]->{flags}->[0] || "";
  }

  if(my $a = delete $args->{type_data}->{suffix_item_id}) { $args->{suffix_item_id} = $a }

  $class->$orig($args);
};

####################
# Item->Armor
####################
package GuildWars2::API::Objects::Item::Armor;
use namespace::autoclean;
use Moose::Role;
use Moose::Util::TypeConstraints;

with 'GuildWars2::API::Objects::Item::Equippable';

=pod

=head1 ROLES

=head2 Item::Armor

The Item::Armor role adds attributes specific to armor items. It includes the
Item::Equippable role.

=head3 Attributes

=over

=item armor_type

The item's armor subtype.

 Boots
 Coat
 Gloves
 Helm
 HelmAquatic
 Leggings
 Shoulders

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

=back

=cut

enum 'ArmorType', [qw( Boots Coat Gloves Helm HelmAquatic Leggings Shoulders )];

has 'armor_type'      => ( is => 'ro', isa => 'ArmorType',      required => 1 );
has 'armor_class'     => ( is => 'ro', isa => 'Str',            required => 1 );
has 'defense'         => ( is => 'ro', isa => 'Int' );
has 'race'            => ( is => 'ro', isa => 'Str' );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  if(my $a = delete $args->{type_data}->{type})           { $args->{armor_type}     = $a; } # type --> armor_type
  if(my $a = delete $args->{type_data}->{weight_class})   { $args->{armor_class}    = $a; } # weight_class --> armor_class
  if(my $a = delete $args->{type_data}->{defense})        { $args->{defense}        = $a; }

  # The top-level attribute 'restrictions' actually applies only to armor
  if(my $r = delete $args->{restrictions}) {
    # A single item (17012) has restrictions = [Guardian,Warrior]
    # All others have a single racial restriction
    # This if block specifically ignores that one item
    if (@$r == 1) {
      $args->{race} = $r->[0];
    }
  }

  $class->$orig($args);
};

####################
# Item->Back
####################
package GuildWars2::API::Objects::Item::Back;
use namespace::autoclean;
use Moose::Role;

with 'GuildWars2::API::Objects::Item::Equippable';

=pod

=head2 Item::Back

The Item::Back role adds attributes specific to back items. It includes the
Item::Equippable role, but does not add any attributes directly.

=cut

####################
# Item->Bag
####################
package GuildWars2::API::Objects::Item::Bag;
use namespace::autoclean;
use Moose::Role;

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

has 'bag_size'     => ( is => 'ro', isa => 'Int',            required => 1 );
has 'invisible'    => ( is => 'ro', isa => 'Bool',            required => 1 );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  if(my $a = delete $args->{type_data}->{size})            { $args->{bag_size}  = $a; } # size --> bag_size

  $args->{invisible} = delete $args->{type_data}->{no_sell_or_sort} || 0;

  $class->$orig($args);
};

####################
# Item->Consumable
####################
package GuildWars2::API::Objects::Item::Consumable;
use namespace::autoclean;
use Moose::Role;
use Moose::Util::TypeConstraints;

=pod

=head2 Item::Consumable

The Item::Consumable role adds attributes specific to consumable items.

=head3 Attributes

=over

=item consumable_type

The item's consumable subtype.

 AppearanceChange
 Booze
 ContractNpc
 Food
 Generic
 Halloween
 Immediate
 Transmutation
 Unlock
 Utility

=item food_duration_ms

For Food subtypes, the duration in milliseconds of the food's Nourishment effect.

=item food_description

For Food subtypes, the description of the food's Nourishment effect.

=item unlock_type

For Unlock subtypes, the item's Unlock sub-subtype.

 BagSlot
 BankTab
 CraftingRecipe
 Dye

=item unlock_color_id

For Dye-type unlocks, the internal ID of the color unlocked by the item. This
can be used to look up the color data in the output of the $api->get_colors
method.

=item unlock_recipe_id

For CraftingRecipe-type unlocks, the internal ID of the recipe unlocked by the
item. This can be used to look up the recipe data with $api-
>get_recipe($recipe_id).

=back

=cut

enum 'ConsType', [qw( AppearanceChange Booze ContractNpc Food Generic Halloween Immediate Transmutation Unlock Utility )];
enum 'UnlockType', [qw( BagSlot BankTab CraftingRecipe Dye )];

has 'consumable_type'     => ( is => 'ro', isa => 'ConsType',   required => 1 );
has 'food_duration_ms'    => ( is => 'ro', isa => 'Str' );
has 'food_description'    => ( is => 'ro', isa => 'Str' );
has 'unlock_type'         => ( is => 'ro', isa => 'UnlockType' );
has 'unlock_color_id'     => ( is => 'ro', isa => 'Str' );
has 'unlock_recipe_id'    => ( is => 'ro', isa => 'Str' );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  if(my $a = delete $args->{type_data}->{type})         { $args->{consumable_type} = $a; } # type --> consumable_type
  if(my $a = delete $args->{type_data}->{duration_ms})  { $args->{food_duration_ms} = $a; } # duration_ms --> food_duration_ms
  if(my $a = delete $args->{type_data}->{description})  { $args->{food_description} = $a; } # description --> food_description
  if(my $a = delete $args->{type_data}->{unlock_type})  { $args->{unlock_type} = $a; }
  if(my $a = delete $args->{type_data}->{color_id})     { $args->{unlock_color_id} = $a; }
  if(my $a = delete $args->{type_data}->{recipe_id})    { $args->{unlock_recipe_id} = $a; }

  $class->$orig($args);
};

####################
# Item->Tool
####################
package GuildWars2::API::Objects::Item::Tool;
use namespace::autoclean;
use Moose::Role;
use Moose::Util::TypeConstraints;

=pod

=head2 Item::Tool

The Item::Tool role adds attributes specific to tool items.

=head3 Attributes

=over

=item tool_type

The item's tool subtype.

 Salvage

=back

=cut

enum 'ToolType', [qw( Salvage xxDUMMYxx )]; # enum requires 2 values

has 'tool_type'  => ( is => 'ro', isa => 'ToolType',   required => 1 );
has 'charges'    => ( is => 'ro', isa => 'Int',        required => 1 );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  if(my $a = delete $args->{type_data}->{type})     { $args->{tool_type} = $a; } # type --> tool_type
  if(my $a = delete $args->{type_data}->{charges})  { $args->{charges} = $a; }

  $class->$orig($args);
};


####################
# Item->Trinket
####################
package GuildWars2::API::Objects::Item::Trinket;
use namespace::autoclean;
use Moose::Role;
use Moose::Util::TypeConstraints;

with 'GuildWars2::API::Objects::Item::Equippable';

=pod

=head2 Item::Trinket

The Item::Trinket role adds attributes specific to trinket items. It includes
the Item::Equippable role.

=head3 Attributes

=over

=item trinket_type

The item's trinket subtype.

 Accessory
 Amulet
 Ring

=back

=cut

enum 'TrinketType', [qw( Accessory Amulet Ring )];

has 'trinket_type'    => ( is => 'ro', isa => 'TrinketType',   required => 1 );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  if(my $a = delete $args->{type_data}->{type}) { $args->{trinket_type} = $a; } # type --> trinket_type

  $class->$orig($args);
};

####################
# Item->UpgradeComponent
####################
package GuildWars2::API::Objects::Item::UpgradeComponent;
use namespace::autoclean;
use Moose::Role;
use Moose::Util::TypeConstraints;

with 'GuildWars2::API::Objects::Item::Infixed';

=pod

=head2 Item::UpgradeComponent

The Item::UpgradeComponent role adds attributes specific to upgrade
components. It includes the Item::Infixed role.

=head3 Attributes

=over

=item upgrade_type

The item's updgrade component subtype.

=item suffix

The suffix that the upgrade confers when it is attached to an item.

=item infusion_type

The upgrade's infusion type.

=item rune_bonuses

For upgrade_type = Rune, the list of bonuses the rune confers, given as an
array.

=item applies_to

The type of equipment the upgrade can be applied to.

 All
 Armor
 Trinket
 Weapon

=back

=cut

enum 'UpgradeType', [qw( Default Gem Rune Sigil )];

enum 'InfusionType', [qw( Defense Offense Omni Utility )];

has 'upgrade_type'    => ( is => 'ro', isa => 'UpgradeType',    required => 1 );
has 'applies_to'      => ( is => 'ro', isa => 'Str',            required => 1 );
has 'suffix'          => ( is => 'ro', isa => 'Str', default => "" );
has 'infusion_type'   => ( is => 'ro', isa => 'Maybe[InfusionType]' );
has 'rune_bonuses'    => ( is => 'ro', isa => 'ArrayRef[Str]' );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  if(my $a = delete $args->{type_data}->{type})         { $args->{upgrade_type} = $a; }
  if(my $a = delete $args->{type_data}->{suffix})       { $args->{suffix} = $a; }
  if(my $a = delete $args->{type_data}->{bonuses})      { $args->{rune_bonuses} = $a; }

  if(my $flags = delete $args->{type_data}->{flags}) {
    # Making assumptions about the only valid flag combinations
    for (scalar @$flags) {
      $args->{applies_to} = 'Trinket' when 1;
      $args->{applies_to} = 'Armor'   when 3;
      $args->{applies_to} = 'Weapon'  when 19;
      $args->{applies_to} = 'All'     when 23;
    }
  }

  if(my $iuf = delete $args->{type_data}->{infusion_upgrade_flags}) {
    $args->{infusion_type} = (@$iuf == 3) ? 'Omni' : $iuf->[0];
  }

  $class->$orig($args);
};

####################
# Item->Weapon
####################
package GuildWars2::API::Objects::Item::Weapon;
use namespace::autoclean;
use Moose::Role;
use Moose::Util::TypeConstraints;

with 'GuildWars2::API::Objects::Item::Equippable';

=pod

=head2 Item::Weapon

The Item::Weapon role adds attributes specific to weapon items. It includes
the Item::Equippable role.

=head3 Attributes

=over

=item weapon_type

The item's weapon subtype.

 Axe
 Dagger
 Focus
 Greatsword
 Hammer
 Harpoon
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

=item damage_type

The weapon's (cosmetic) damage type.

=item min_strength
=item max_strength

The weapon's minimum and maximum strength ratings.

=item defense

The weapon's defense value. Only for weapon_type = 'shield'.

=back

=cut

enum 'WeaponType', [qw( Axe Dagger Focus Greatsword Hammer Harpoon LargeBundle LongBow Mace Pistol Rifle
                        Scepter Shield ShortBow Speargun Staff Sword Torch Toy Trident TwoHandedToy Warhorn )];

has 'weapon_type'     => ( is => 'ro', isa => 'WeaponType',   required => 1 );
has 'damage_type'     => ( is => 'ro', isa => 'Str',          required => 1 );
has 'min_strength'    => ( is => 'ro', isa => 'Int' );
has 'max_strength'    => ( is => 'ro', isa => 'Int' );
has 'defense'         => ( is => 'ro', isa => 'Int' );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  if(my $a = delete $args->{type_data}->{type})         { $args->{weapon_type}  = $a; } # type --> weapon_type
  if(my $a = delete $args->{type_data}->{min_power})    { $args->{min_strength} = $a; } # min_power --> min_strength
  if(my $a = delete $args->{type_data}->{max_power})    { $args->{max_strength} = $a; } # max_power --> max_strength
  if(my $a = delete $args->{type_data}->{damage_type})  { $args->{damage_type} = $a; }
  if(my $a = delete $args->{type_data}->{defense})      { $args->{defense} = $a; }

  $class->$orig($args);
};


1;
