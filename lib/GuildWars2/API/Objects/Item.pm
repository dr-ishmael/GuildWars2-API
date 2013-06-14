use Carp ();
use Modern::Perl '2012';

=pod

=head1 DESCRIPTION

This subclass of GuildWars2::API::Objects defines the different item objects.

=cut

####################
# Item->Base role
####################
package GuildWars2::API::Objects::Item::Base;
use Moose::Role;
use Moose::Util::TypeConstraints;

=pod

=head1 ROLES

=head2 Item::Base

The Item::Base role defines the common features of all item classes.

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

=item game_types

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

=cut

my %_default_gametypes = map { $_ => 0 } qw( Activity Dungeon Pve Pvp PvpLobby Wvw );

my %_default_flags = map { $_ => 0 } qw( AccountBound HideSuffix NoMysticForge NoSalvage NoSell NotUpgradeable NoUnderwater SoulBindOnAcquire SoulBindOnUse Unique );

enum 'ItemType', [qw(
    Armor Back Bag Consumable Container CraftingMaterial Gathering Gizmo MiniPet
    Tool Trinket Trophy UpgradeComponent Weapon
  )];

enum 'ItemRarity', [qw( Junk Basic Fine Masterwork Rare Exotic Ascended Legendary )];

has 'item_id'         => ( is => 'ro', isa => 'Int',            required => 1 );
has 'item_name'       => ( is => 'ro', isa => 'Str',            required => 1 );
has 'description'     => ( is => 'ro', isa => 'Str',            required => 1 );
has 'item_type'       => ( is => 'ro', isa => 'ItemType',       required => 1 );
has 'level'           => ( is => 'ro', isa => 'Int',            required => 1 );
has 'rarity'          => ( is => 'ro', isa => 'ItemRarity',     required => 1 );
has 'vendor_value'    => ( is => 'ro', isa => 'Int',            required => 1 );
has 'game_types'      => ( is => 'ro', isa => 'HashRef[Bool]',  required => 1 );
has 'item_flags'      => ( is => 'ro', isa => 'HashRef[Bool]',  required => 1 );


around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  # Renames
  if(my $a = delete $args->{type}) { $args->{item_type} = $a; } # type --> item_type
  if(my $a = delete $args->{name}) { $args->{item_name} = $a; } # name --> item_name

  if(my $gametypes = delete $args->{game_types}) {
    $args->{game_types} = \%_default_gametypes;
    foreach my $g (@$gametypes) {
      $args->{game_types}->{$g} = 1;
    }
  }

  if(my $flags = delete $args->{flags}) {
    $args->{item_flags} = \%_default_flags;
    foreach my $f (@$flags) {
      $args->{item_flags}->{$f} = 1;
    }
  }

  $class->$orig($args);
};

####################
# Item->Equippable role
####################
package GuildWars2::API::Objects::Item::Equippable;
use Moose::Role;
use Moose::Util::TypeConstraints;

=pod

=head2 Item::Equippable

The Item::Equippable role defines the common features of equippable item types:
Armor, Back, Trinket, and Weapon.

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

=item infusion_types

The types of infusion allowed in the item's infusion slot. If blank, then the
item does not have an infusion slot.

=item suffix_item_id

The internal ID of the upgrade component attached to the item.

=back

=cut

has 'item_attributes' => ( is => 'ro', isa => 'HashRef[Int]', required => 1 );
has 'buff_skill_id'   => ( is => 'ro', isa => 'Int' );
has 'buff_desc'       => ( is => 'ro', isa => 'Str' );
has 'infusion_types'  => ( is => 'ro', isa => 'Str' );
has 'suffix_item_id'  => ( is => 'ro', isa => 'Int' );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  if(my $i = delete $args->{infusion_slots}) {
    my $flags = $i->[0]->{flags};  # Cheat on the assumption that no item has more than 1 slot
    $args->{infusion_types} = join(',', @$flags);
  }

  if(my $infix = delete $args->{infix_upgrade}) {
    if(my $a = delete $infix->{buff}->{skill_id})    { $args->{buff_skill_id} = $a; }
    if(my $a = delete $infix->{buff}->{description}) { $args->{buff_desc}     = $a; }

    if(my $attributes = delete $infix->{attributes}) {
      foreach my $a (@$attributes) {
        $args->{attributes}->{$a->{attribute}} = $a->{modifier};
      }
    }
  }

  $class->$orig($args);
};

####################
# Item->Armor
####################
package GuildWars2::API::Objects::Item::Armor;
use Moose;
use Moose::Util::TypeConstraints;

with 'GuildWars2::API::Objects::Item::Base';
with 'GuildWars2::API::Objects::Item::Equippable';

=pod

=head1 CLASSES

=head2 Item::Armor

The Item::Armor object represents an item of type Armor. It uses the roles
Item::Base and Item::Equippable.

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
has 'defense'         => ( is => 'ro', isa => 'Int',            required => 1 );
has 'race'            => ( is => 'ro', isa => 'Str' );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  # Promote values from JSON subobject and some renames
  if(my $armor = delete $args->{armor}) {
    if(my $a = delete $armor->{type})           { $args->{armor_type}     = $a; } # type --> armor_type
    if(my $a = delete $armor->{weight_class})   { $args->{armor_class}    = $a; } # weight_class --> armor_class
    if(my $a = delete $armor->{defense})        { $args->{defense}        = $a; }
    if(my $a = delete $armor->{infusion_slots}) { $args->{infusion_slots} = $a; }
    if(my $a = delete $armor->{infix_upgrade})  { $args->{infix_upgrade}  = $a; }
    if(my $a = delete $armor->{suffix_item_id}) { $args->{suffix_item_id} = $a; }
  }

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
use Moose;

with 'GuildWars2::API::Objects::Item::Base';
with 'GuildWars2::API::Objects::Item::Equippable';

=pod

=head2 Item::Back

The Item::Back object represents an item of type Back. It uses the roles
Item::Base and Item::Equippable.

=head3 Attributes

The Item::Back object does not have any additional attributes.

=cut




=pod

   bag =>
     {
       no_sell_or_sort => [BOOL],   # Items in bag are not sorted or shown to merchants
       size            => [INT],    # Number of slots
     }

   consumable =>
     {
       duration_ms  => [INT],       # Duration of nourishment effect
       description  => [STRING],    # Description of nourishment effect
                                    # (Nourishment effects are only on Food and Utility consumables)
       unlock_type  => [STRING],    # Unlock subtype (BagSlot, BankTab, CraftingRecipe, Dye)
       color_id     => [INT],       # Color_id unlocked by a Dye (cf. $api->colors)
       recipe_id    => [INT],       # Recipe_id unlocked by a CraftingRecipe (cf. $api->recipe_details)
     }

   trinket =>
     {
       infusion_slots => @( ),      # Infusion slots***
       infix_upgrade  => %( ),      # Infix upgrade***
       suffix_item_id => [INT],     # Item ID of attached upgrade component
     }

   upgrade_component =>
     {
       flags          => @([STRING],...), # Upgrade flags***
       infusion_upgrade_flags => @([STRING],...), # Infusion flags (Defense, Offense, Utility)
       bonuses        => @([STRING],...), # Rune bonuses
       infix_upgrade  => %( ),            # Infix upgrade***
       suffix         => [STRING],        # Suffix bestowed by the upgrade
     }

   weapon =>
     {
       damage_type => [STRING],     # Damage type (Physical, Fire, Ice, Lightning)
       min_power   => [INT],        # Minimum weapon strength value
       max_power   => [INT],        # Maximum weapon strength value
       defense     => [INT],        # Defense value
       infusion_slots => @( ),      # Infusion slots***
       infix_upgrade  => %( ),      # Infix upgrade***
       suffix_item_id => [INT],     # Item ID of attached upgrade component
     }
 )


=cut

1;

__END__

{
enum 'ItemSubType', [qw(
    Default
# consumable
    AppearanceChange ContractNpc Food Generic Halloween Immediate Transmutation Unlock Utility
# container
    GiftBox
# gathering
    Foraging Logging Mining
# gizmo
    RentableContractNpc UnlimitedConsumable
# tool
    Salvage
# trinket
    Accessory Amulet Ring
# upgrade_component
    Gem Rune Sigil
# weapon
    Axe Dagger Focus Greatsword Hammer Harpoon LongBow Mace Pistol Rifle Scepter
    Shield ShortBow Speargun Staff Sword Torch Toy Trident TwoHandedToy Warhorn
  )];
}

