use Modern::Perl '2014';

=pod

=head1 DESCRIPTION

This subclass of GuildWars2::API::Objects defines the Recipe object.

=cut

####################
# Recipe
####################
package GuildWars2::API::Objects::Recipe;
use namespace::autoclean;
use Moose;
use Moose::Util::TypeConstraints; # required for enum constraints

use GuildWars2::API::Constants;
use GuildWars2::API::Utils;

with 'GuildWars2::API::Objects::Linkable';


my @_default_disciplines = qw( Armorsmith Artificer Chef Huntsman Jeweler Leatherworker Tailor Weaponsmith );

my %enum_map = (
  'recipe_type' => [qw(
      Amulet Axe Backpack Bag Boots Bulk Coat Component Consumable Dagger Dessert
      Dye Earring Feast Focus Gloves Greatsword Hammer Harpoon Helm IngredientCooking
      Inscription Insignia Leggings LongBow Mace Meal Pistol Potion Refinement
      RefinementEctoplasm RefinementObsidian Rifle Ring Scepter Seasoning Shield
      ShortBow Shoulders Snack Soup Speargun Staff Sword Torch Trident
      UpgradeComponent Warhorn Unknown
    )],
);

enum 'RecipeType', $enum_map{'recipe_type'};

has 'recipe_id'         => ( is => 'ro', isa => 'Int',            required => 1 );
has 'recipe_type'       => ( is => 'ro', isa => 'Str',            required => 1 );
has 'output_item_id'    => ( is => 'ro', isa => 'Int',            required => 1 );
has 'output_item_count' => ( is => 'ro', isa => 'Int',            required => 1 );
has 'min_rating'        => ( is => 'ro', isa => 'Int',            required => 1 );
has 'time_to_craft_ms'  => ( is => 'ro', isa => 'Int',            required => 1 );
has 'disciplines'       => ( is => 'ro', isa => 'HashRef[Bool]',  required => 1 );
has 'unlock_method'     => ( is => 'ro', isa => 'Str',            required => 1 );
has 'ingredients'       => ( is => 'ro', isa => 'HashRef[Int]',   required => 1 );
has 'recipe_warnings'   => ( is => 'ro', isa => 'Str'                           );
has 'md5'               => ( is => 'ro', isa => 'Str', writer => '_set_md5'     );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  my $new_args;

  if(my $t = delete $args->{id}) { $new_args->{recipe_id} = $t; }
  if(my $t = delete $args->{type}) { $new_args->{recipe_type} = $t; }
  if(my $t = delete $args->{output_item_id}) { $new_args->{output_item_id} = $t; }
  if(my $t = delete $args->{output_item_count}) { $new_args->{output_item_count} = $t; }
  if(defined(my $t = delete $args->{min_rating})) { $new_args->{min_rating} = $t; }
  if(my $t = delete $args->{time_to_craft_ms}) { $new_args->{time_to_craft_ms} = $t; }

  if(my $disciplines = delete $args->{disciplines}) {
    $new_args->{disciplines} = { map { $_ => 0 } @_default_disciplines };
    foreach my $d (@$disciplines) {
      if (in($d, \@_default_disciplines)) {
        $new_args->{disciplines}->{$d} = 1;
      } else {
        $new_args->{recipe_warnings} .= "Unrecognized discipline [$d]\n";
      }
    }
  }

  if(my $flags = delete $args->{flags}) {
    if (@$flags == 1 && in($flags->[0], [ "AutoLearned", "LearnedFromItem" ])) {
      my $f = $flags->[0];
      $new_args->{unlock_method} =
          $f eq "AutoLearned" ? 'Automatic'
        : $f eq "LearnedFromItem" ? 'RecipeSheet'
        : 0;
    } elsif (@$flags == 0) {
      $new_args->{unlock_method} = 'Discovery';
    } else {
      $new_args->{unlock_method} = 'Unknown';
      $new_args->{recipe_warnings} .= "Unrecognized flags [@$flags]\n";
    }
  }

  if(my $ingredients = delete $args->{ingredients}) {
    foreach my $i (@$ingredients) {
      $new_args->{ingredients}->{$i->{item_id}} = $i->{count};
    }
  }

  # Validation of enumerated fields
  _validate_enum($new_args, 'recipe_type');

  # If there are any attributes left on the original $args, list them as warnings
  for my $a (keys %$args) {
    $new_args->{recipe_warnings} .= "Unprocessed attribute [$a]\n";
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
    $args->{recipe_warnings} .= "Unrecognized $field: [$a].\n";
    $args->{$field} = '';
  }
}

# Method required to provide type and ID to Linkable role
sub _gl_data {
  my ($self) = @_;
  return (RECIPE_LINK_TYPE, $self->recipe_id);
}


sub armorsmith    { return $_[0]->{disciplines}->{Armorsmith}; }
sub artificer     { return $_[0]->{disciplines}->{Artificer}; }
sub chef          { return $_[0]->{disciplines}->{Chef}; }
sub huntsman      { return $_[0]->{disciplines}->{Huntsman}; }
sub jeweler       { return $_[0]->{disciplines}->{Jeweler}; }
sub leatherworker { return $_[0]->{disciplines}->{Leatherworker}; }
sub tailor        { return $_[0]->{disciplines}->{Tailor}; }
sub weaponsmith   { return $_[0]->{disciplines}->{Weaponsmith}; }

1;
