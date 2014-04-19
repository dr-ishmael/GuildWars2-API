use Modern::Perl '2014';

=pod

=head1 DESCRIPTION

This subclass of GuildWars2::API::Objects defines the different skin objects.

=cut

####################
# Item
####################
package GuildWars2::API::Objects::Skin;
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

=item skin_warnings

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

my @_default_flags = qw( HideIfLocked NoCost ShowInWardrobe );

my %enum_map = (
  'skin_type' => [qw(
      Armor Back Outfit Weapon
    )],
  'skin_subtype' => [
      # Common
      # Subtype is not used by (is null for): Back Bag CraftingMaterial MiniPet Trophy
      # Default used by: Container Gizmo UpgradeComponent
      qw(null Default Unknown),
      # Armor
      qw(Boots Coat Gloves Helm HelmAquatic Leggings Shoulders),
      # Weapon
      qw(Axe Dagger Focus Greatsword Hammer Harpoon LargeBundle LongBow Mace Pistol Rifle
         Scepter Shield ShortBow Speargun Staff Sword Torch Toy Trident TwoHandedToy Warhorn)
    ],
  'armor_weight' => [qw( Clothing Light Medium Heavy )],
  'armor_race' => [qw( Asura Charr Human Norn Sylvari )],
  'damage_type' => [qw( Fire Ice Lightning Physical )],
);

enum 'SkinType',          $enum_map{'skin_type'};
enum 'SkinSubtype',       $enum_map{'skin_subtype'};
enum 'ArmorWeight',       $enum_map{'armor_weight'};
enum 'ArmorRace',         $enum_map{'armor_race'};
enum 'DamageType',        $enum_map{'damage_type'};


has 'skin_id'               => ( is => 'ro', isa => 'Int',            required => 1 );
has 'skin_name'             => ( is => 'ro', isa => 'Str',            required => 1 );
has 'skin_type'             => ( is => 'ro', isa => 'SkinType',       required => 1 );
has 'skin_flags'            => ( is => 'ro', isa => 'HashRef[Bool]',  required => 1 );
has 'icon_file_id'          => ( is => 'ro', isa => 'Int',            required => 1 );
has 'icon_signature'        => ( is => 'ro', isa => 'Str',            required => 1 );
has 'description'           => ( is => 'ro', isa => 'Str'           );
has 'skin_subtype'          => ( is => 'ro', isa => 'SkinSubtype'   );
has 'armor_weight'          => ( is => 'ro', isa => 'ArmorWeight'   );
has 'armor_race'            => ( is => 'ro', isa => 'ArmorRace'     );
has 'damage_type'           => ( is => 'ro', isa => 'DamageType'    );
has 'skin_warnings'         => ( is => 'ro', isa => 'Str'           );
has 'raw_json'              => ( is => 'ro', isa => 'Str', writer => '_set_json' );
has 'raw_md5'               => ( is => 'ro', isa => 'Str', writer => '_set_md5'  );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  my $new_args;

  local $" = ','; #" # <-- this is to satisfy syntax highlighting that can't interpret $" as a variable name

  # Explicitly copy attributes from original $args to $new_args
  # Perform some renames and data hygiene on the way
  if(my $a = delete $args->{skin_id}) { $new_args->{skin_id} = $a }
  if(defined(my $a = delete $args->{name})) { $new_args->{skin_name} = $a }
  if(my $a = delete $args->{type}) { $new_args->{skin_type} = $a }
  if(my $a = delete $args->{icon_file_id}) { $new_args->{icon_file_id} = $a }
  if(my $a = delete $args->{icon_file_signature}) { $new_args->{icon_signature} = $a }
  if(my $a = delete $args->{description}) { ($new_args->{description} = $a) =~ s/\n/<br>/g }

  # Restrictions - returned as a list, only single value is meaningful
  # Two items (17012, 18165) have restrictions = [Guardian,Warrior]
  # Otherwise this element is only used to define racial armor restrictions
  if(my $r = delete $args->{restrictions}) {
    if (@$r == 1 && in($r->[0], $enum_map{'armor_race'})) {
      $new_args->{armor_race} = $r->[0];
    } elsif (@$r > 0) {
      $new_args->{skin_warnings} .= "Unrecognized restrictions [@$r]\n";
    }
  }

  # Transform from array[str] to hash[bool]
  if(my $flags = delete $args->{flags}) {
    $new_args->{skin_flags} = { map { $_ => 0 } @_default_flags };
    foreach my $f (@$flags) {
      $new_args->{skin_warnings} .= "Unrecognized flag [$f]\n" unless in($f, \@_default_flags);
      $new_args->{skin_flags}->{$f} = 1;
    }
  }

  # Process type-specific data
  if (my $tdata = delete $args->{type_data}) {
    # Explicitly copy attributes from original $args->{type_date} to $new_args
    # Perform some renames and data hygiene on the way
    if(my $a = delete $tdata->{type}) { $new_args->{skin_subtype} = $a }
    if(my $a = delete $tdata->{weight_class}) { $new_args->{armor_weight} = $a }
    if(my $a = delete $tdata->{damage_type}) { $new_args->{damage_type} = $a }

    # If there are any attributes left on the original $args->{type_data}, list them as warnings
    for my $a (keys %$tdata) {
      $new_args->{skin_warnings} .= "Unprocessed type attribute [$a]\n";
    }
  }

  # Validation of enumerated fields
  _validate_enum($new_args, 'skin_type');
  _validate_enum($new_args, 'skin_subtype');
  _validate_enum($new_args, 'armor_race');
  _validate_enum($new_args, 'armor_weight');
  _validate_enum($new_args, 'damage_type');

  # If there are any attributes left on the original $args, list them as warnings
  for my $a (keys %$args) {
    $new_args->{skin_warnings} .= "Unprocessed attribute [$a]\n";
  }

  $class->$orig($new_args);
};

# Method to perform "soft" validations on enumerated fields
# Invalid values will add a warning to $args->{moose_warnings} and blank the output field
sub _validate_enum {
  my ($args, $field) = @_;
  my $a = $args->{$field};
  return if !$a;
  unless (in($a, $enum_map{$field})) {
    $args->{skin_warnings} .= "Unrecognized $field: [$a].\n";
    $args->{$field} = '';
  }
}

# Method required to provide type and ID to Linkable role
sub _gl_data {
  my ($self) = @_;
  return (ITEM_LINK_TYPE, $self->item_id);
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
