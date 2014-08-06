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
  if(my $a = delete $args->{name}) { ($new_args->{skin_name} = $a) =~ s/\n//g }
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


1;
