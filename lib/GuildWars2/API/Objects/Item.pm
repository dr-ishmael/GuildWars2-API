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
use Moose::Util::TypeConstraints; # required for enum constraints

use GuildWars2::API::Constants;
use GuildWars2::API::Utils;

with 'GuildWars2::API::Objects::Linkable';


my @_default_gametypes = qw( Activity Dungeon Pve Pvp PvpLobby Wvw );

my @_default_flags = qw( AccountBindOnUse AccountBound HideSuffix MonsterOnly NoMysticForge NoSalvage NoSell NotUpgradeable NoUnderwater SoulbindOnAcquire SoulBindOnUse Unique );

my %enum_map = (
  'item_type' => [qw(
      Armor Back Bag Consumable Container CraftingMaterial Gathering Gizmo MiniPet
      Tool Trait Trinket Trophy UpgradeComponent Weapon
    )],
  'item_subtype' => [
      # Common
      # Subtype is not used by (is null for): Back Bag CraftingMaterial MiniPet Trophy
      # Value 'Default' used by: Container Gizmo UpgradeComponent
      # Value 'Unknown' is API default when the type ID has no defined translation
      qw(null Default Unknown),
      # Armor
      qw(Boots Coat Gloves Helm HelmAquatic Leggings Shoulders),
      # Consumable
      qw(AppearanceChange Booze ContractNpc Food Generic Halloween Immediate Transmutation Unlock UpgradeRemoval Utility),
      # Container
      qw(GiftBox OpenUI),
      # Gathering
      qw(Foraging Logging Mining),
      # Gizmo
      qw(ContainerKey RentableContractNpc UnlimitedConsumable),
      # Tool
      qw(Salvage),
      # Trinket
      qw(Accessory Amulet Ring),
      # UpgradeComponent
      qw(Gem Rune Sigil),
      # Weapon
      qw(Axe Dagger Mace Pistol Scepter Sword),           # Main hand
      qw(Focus Shield Torch Warhorn),                     # Off hand
      qw(Greatsword Hammer LongBow Rifle ShortBow Staff), # Two hand
      qw(Harpoon Speargun Trident),                       # Aquatic
      qw(LargeBundle SmallBundle Toy TwoHandedToy)        # Other
    ],
  'rarity' => [qw( Junk Basic Fine Masterwork Rare Exotic Ascended Legendary )],
  'armor_weight' => [qw( Clothing Light Medium Heavy )],
  'armor_race' => [qw( Asura Charr Human Norn Sylvari )],
  'damage_type' => [qw( Choking Fire Ice Lightning Physical )],
  'infusion_type' => [qw( Agony Defense Offense Omni Utility )],
  'infusion_slot_type' => [qw( Defense Offense Utility )],
  'unlock_type' => [qw( BagSlot BankTab CollectibleCapacity Content CraftingRecipe Dye Unknown )],
  'upgrade_type' => [qw( Infusion Jewel Rune Sigil Universal )],
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
enum 'UpgradeType',       $enum_map{'upgrade_type'};


has 'item_id'               => ( is => 'ro', isa => 'Int', required => 1 );
has 'item_name'             => ( is => 'ro', isa => 'Str'           );
has 'item_type'             => ( is => 'ro', isa => 'ItemType'      );
has 'level'                 => ( is => 'ro', isa => 'Int'           );
has 'rarity'                => ( is => 'ro', isa => 'ItemRarity'    );
has 'vendor_value'          => ( is => 'ro', isa => 'Int'           );
has 'game_type_flags'       => ( is => 'ro', isa => 'GuildWars2::API::Objects::Item::GameTypes' );
has 'item_flags'            => ( is => 'ro', isa => 'GuildWars2::API::Objects::Item::Flags' );
has 'icon_url'              => ( is => 'ro', isa => 'Str'           );
has 'description'           => ( is => 'ro', isa => 'Str'           );
has 'default_skin'          => ( is => 'ro', isa => 'Int'           );
has 'item_subtype'          => ( is => 'ro', isa => 'ItemSubtype'   );
has 'item_attributes'       => ( is => 'ro', isa => 'HashRef[Int]'  );
has 'buff_skill_id'         => ( is => 'ro', isa => 'Int'           );
has 'buff_desc'             => ( is => 'ro', isa => 'Str'           );
has 'infusion_slot_1_type'  => ( is => 'ro', isa => 'Str'           );
has 'infusion_slot_1_item'  => ( is => 'ro', isa => 'Int'           );
has 'infusion_slot_2_type'  => ( is => 'ro', isa => 'Str'           );
has 'infusion_slot_2_item'  => ( is => 'ro', isa => 'Int'           );
has 'suffix_item_id'        => ( is => 'ro', isa => 'Str'           );
has 'second_suffix_item_id' => ( is => 'ro', isa => 'Str'           );
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
has 'upgrade_type'          => ( is => 'ro', isa => 'UpgradeType'   );
has 'suffix'                => ( is => 'ro', isa => 'Str'           );
has 'infusion_type'         => ( is => 'ro', isa => 'InfusionType'  );
has 'rune_bonuses'          => ( is => 'ro', isa => 'ArrayRef[Str]' );
has 'damage_type'           => ( is => 'ro', isa => 'DamageType'    );
has 'min_strength'          => ( is => 'ro', isa => 'Int'           );
has 'max_strength'          => ( is => 'ro', isa => 'Int'           );
has 'item_warnings'         => ( is => 'ro', isa => 'Str'           );
has 'md5'                   => ( is => 'ro', isa => 'Str', writer => '_set_md5'  );

around 'BUILDARGS', sub {
  # $args is a JSON object built from the API response
  my ($orig, $class, $args) = @_;

  my $new_args;

  local $" = ',';

  # Explicitly copy attributes from original $args to $new_args
  # Perform some renames and data hygiene on the way
  if(my $a = delete $args->{id}) { $new_args->{item_id} = $a }
  if(my $a = delete $args->{name}) { ($new_args->{item_name} = $a) =~ s/\n//g }
  if(my $a = delete $args->{type}) { $new_args->{item_type} = $a }
  if(defined(my $a = delete $args->{level})) { $new_args->{level} = $a }
  if(my $a = delete $args->{rarity}) { $new_args->{rarity} = $a }
  if(defined(my $a = delete $args->{vendor_value})) { $new_args->{vendor_value} = $a }
  if(my $a = delete $args->{icon}) { $new_args->{icon_url} = $a }
  if(my $a = delete $args->{description}) { ($new_args->{description} = $a) =~ s/\n/<br>/g }
  if(my $a = delete $args->{default_skin}) { ($new_args->{default_skin} = $a) =~ s/\n/<br>/g }

  # Restrictions - returned as a list, only single value is meaningful
  # Some armors have profession restrictions, but these are redundant with armor_weight
  # ###TODO### Trait guides
  # Otherwise this element is only used to define racial armor restrictions
  if(my $r = delete $args->{restrictions}) {
    if (@$r == 1 && in($r->[0], $enum_map{'armor_race'})) {
      $new_args->{armor_race} = $r->[0];
    } elsif (@$r > 0) {
      $new_args->{item_warnings} .= "Unrecognized restrictions [@$r]\n";
    }
  }

  # game_types - every item has at least one game_type defined
  if(my $gametypes = delete $args->{game_types}) {
    foreach my $g (@$gametypes) {
      $new_args->{item_warnings} .= "Unrecognized game_type [$g]\n" unless in($g, \@_default_gametypes);
    }
    $new_args->{game_type_flags} = GuildWars2::API::Objects::Item::GameTypes->new({ map { $_ => 1 } @$gametypes });
  }

  # flags - some items have no flags
  if(my $flags = delete $args->{flags}) {
    if (scalar @$flags > 0) {
      foreach my $f (@$flags) {
        $new_args->{item_warnings} .= "Unrecognized flag [$f]\n" unless in($f, \@_default_flags);
      }
      $new_args->{item_flags} = GuildWars2::API::Objects::Item::Flags->new({ map { $_ => 1 } @$flags });
    } else {
      $new_args->{item_flags} = GuildWars2::API::Objects::Item::Flags->new();
    }
  }

  # details subobject
  if (my $details = delete $args->{details}) {
    # Explicitly copy attributes from original $args->{type_date} to $new_args
    # Perform some renames and data hygiene on the way
    if(my $a = delete $details->{type}) { $new_args->{item_subtype} = $a }
    if(my $a = delete $details->{suffix_item_id}) { $new_args->{suffix_item_id} = $a }
    if(my $a = delete $details->{weight_class}) { $new_args->{armor_weight} = $a }
    if(my $a = delete $details->{defense}) { $new_args->{defense} = $a }
    if(my $a = delete $details->{size}) { $new_args->{bag_size} = $a }
    if(my $a = delete $details->{duration_ms}) { $new_args->{food_duration_sec} = $a / 1000 }
    if(my $a = delete $details->{description}) { ($new_args->{food_description} = $a) =~ s/\n/<br>/g }
    if(my $a = delete $details->{unlock_type}) { $new_args->{unlock_type} = $a }
    if(my $a = delete $details->{color_id}) { $new_args->{unlock_color_id} = $a }
    if(my $a = delete $details->{recipe_id}) { $new_args->{unlock_recipe_id} = $a }
    if(my $a = delete $details->{charges}) { $new_args->{charges} = $a }
    if(my $a = delete $details->{suffix}) { $new_args->{suffix} = $a }
    if(my $a = delete $details->{no_sell_or_sort}) { $new_args->{invisible} = $a }
    if(my $a = delete $details->{min_power}) { $new_args->{min_strength} = $a }
    if(my $a = delete $details->{max_power}) { $new_args->{max_strength} = $a }
    if(my $a = delete $details->{damage_type}) { $new_args->{damage_type} = $a }
    if(my $a = delete $details->{bonuses}) { s/\n/<br>/g for @$a; $new_args->{rune_bonuses} = $a; }
    if(my $a = delete $details->{suffix_item_id}) { $new_args->{suffix_item_id} = $a }
    if(my $a = delete $details->{secondary_suffix_item_id}) { $new_args->{second_suffix_item_id} = $a }

    if (my $infix = delete $details->{infix_upgrade}) {
      if(my $a = delete $infix->{buff}->{skill_id})    { $new_args->{buff_skill_id} = $a }
      if(my $a = delete $infix->{buff}->{description}) { ($new_args->{buff_desc} = $a) =~ s/\n/<br>/g }
      if(my $attributes = delete $infix->{attributes}) {
        if (scalar @$attributes > 0) {
          foreach my $a (@$attributes) {
            $new_args->{item_attributes}->{$a->{attribute}} = $a->{modifier};
          }
        }
      }
    }

    # Infusion slots - returned as a list of 'flag' lists
    #   'flags' list has never been seen with more than 1 value
    #   Agony type slots are returned as an empty 'flags' list, we assume all empty lists are Agony
    if(my $i = delete $details->{infusion_slots}) {
      my $x = 1;
      foreach my $s (@$i) {
        my $f = $s->{flags};
        if (@$f == 1 && in($f->[0], $enum_map{'infusion_slot_type'})) {
          $new_args->{"infusion_slot_".$x."_type"} = $f->[0];
        } elsif (@$f == 0) {
          $new_args->{"infusion_slot_".$x."_type"} = 'Agony';
        } else {
          $new_args->{item_warnings} .= "Unrecognized infusion_slot flags: [@$f]\n";
        }
        if (my $slot_item_id = delete $s->{item_id}) {
          $new_args->{"infusion_slot_".$x."_item"} = $slot_item_id;
        }
        $x++;
      }
    }

    # Flags - only on UpgradeComponent, returned as list of equipment subtypes
    # The only valid combinations are:
    #   ["Trinket"] = Jewel
    #   ["HeavyArmor","LightArmor","MediumArmor"] = Rune
    #   [<all 19 Weapon subtypes>] = Sigil
    #   [<all 23 of the above>] = Universal
    if(my $uf = delete $details->{flags}) {
      # Making assumptions about the only valid flag combinations
      for (scalar @$uf) {
        if ($_ == 1) {
          $new_args->{upgrade_type} = 'Jewel';
        } elsif ($_ == 3) {
          $new_args->{upgrade_type} = 'Rune';
        } elsif ($_ == 19) {
          $new_args->{upgrade_type} = 'Sigil';
        } elsif ($_ == 23) {
          $new_args->{upgrade_type} = 'Universal';
        } else {
          $new_args->{item_warnings} .= "Unrecognized upgrade flags [@$uf]\n";
        }
      }
    }

    # Infusion upgrade flags - returned as a list, only single value is meaningful
    # Omni infusions are returned as a list of ['Offense', 'Defense', 'Utility']
    #   so we translate that to a single value
    # Agony infusions have an empty list and are called '+<x> Agony Infusion'
    if(my $iuf = delete $details->{infusion_upgrade_flags}) {
      if (scalar @$iuf > 0 || $new_args->{item_name} =~ /Agony Infusion/) {
        # If this attribute is populated, or the item
        $new_args->{upgrade_type} = 'Infusion' ;

        @$iuf = sort @$iuf;
        if (@$iuf == 1 && in($iuf->[0], $enum_map{'infusion_slot_type'})) {
          $new_args->{infusion_type} = $iuf->[0];
        } elsif (@$iuf == 3 && array_match( $iuf, $enum_map{'infusion_slot_type'})) {
          $new_args->{infusion_type} = 'Omni';
        } elsif (@$iuf == 0 && $new_args->{item_name} =~ /Agony Infusion/) {
          $new_args->{infusion_type} = 'Agony';
        } elsif (@$iuf > 0) {
          $new_args->{item_warnings} .= "Unrecognized infusion_upgrade_flags [@$iuf]\n";
        }
      }
    }

    # If there are any attributes left on the original $args->{type_data}, list them as warnings
    for my $a (keys %$details) {
      $new_args->{item_warnings} .= "Unprocessed type attribute [$a]\n";
    }
  }

  # Validation of enumerated fields
  _validate_enum($new_args, 'item_type');
  _validate_enum($new_args, 'item_subtype');
  _validate_enum($new_args, 'rarity');
  _validate_enum($new_args, 'armor_race');
  _validate_enum($new_args, 'armor_weight');
  _validate_enum($new_args, 'damage_type');
  _validate_enum($new_args, 'unlock_type');

  # If there are any attributes left on the original $args, list them as warnings
  for my $a (keys %$args) {
    $new_args->{item_warnings} .= "Unprocessed attribute [$a]\n";
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
    $args->{item_warnings} .= "Unrecognized $field: [$a].\n";
    delete $args->{$field};
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

__PACKAGE__->meta->make_immutable;


####################
# Item->GameTypes
####################
package GuildWars2::API::Objects::Item::GameTypes;
use namespace::autoclean;
use Moose;

has 'Activity'        => ( is => 'ro', isa => 'Bool', default => 0 );
has 'Dungeon'         => ( is => 'ro', isa => 'Bool', default => 0 );
has 'Pve'             => ( is => 'ro', isa => 'Bool', default => 0 );
has 'Pvp'             => ( is => 'ro', isa => 'Bool', default => 0 );
has 'PvpLobby'        => ( is => 'ro', isa => 'Bool', default => 0 );
has 'Wvw'             => ( is => 'ro', isa => 'Bool', default => 0 );

__PACKAGE__->meta->make_immutable;


####################
# Item->Flags
####################
package GuildWars2::API::Objects::Item::Flags;
use namespace::autoclean;
use Moose;

has 'AccountBindOnUse'    => ( is => 'ro', isa => 'Bool', default => 0 );
has 'AccountBound'        => ( is => 'ro', isa => 'Bool', default => 0 );
has 'HideSuffix'          => ( is => 'ro', isa => 'Bool', default => 0 );
has 'MonsterOnly'         => ( is => 'ro', isa => 'Bool', default => 0 );
has 'NoMysticForge'       => ( is => 'ro', isa => 'Bool', default => 0 );
has 'NoSalvage'           => ( is => 'ro', isa => 'Bool', default => 0 );
has 'NoSell'              => ( is => 'ro', isa => 'Bool', default => 0 );
has 'NotUpgradeable'      => ( is => 'ro', isa => 'Bool', default => 0 );
has 'NoUnderwater'        => ( is => 'ro', isa => 'Bool', default => 0 );
has 'SoulbindOnAcquire'   => ( is => 'ro', isa => 'Bool', default => 0 );
has 'SoulBindOnUse'       => ( is => 'ro', isa => 'Bool', default => 0 );
has 'Unique'              => ( is => 'ro', isa => 'Bool', default => 0 );

__PACKAGE__->meta->make_immutable;


1;
