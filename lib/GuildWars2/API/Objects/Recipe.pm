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
use Moose::Util::TypeConstraints;

use GuildWars2::API::Constants;
use GuildWars2::API::Utils;

with 'GuildWars2::API::Objects::Linkable';

=pod

=head1 CLASSES

=head2 Recipe

The Recipe object represents a crafting recipe in Guild Wars 2. It is returned
by the C<$api->get_recipe()> method.

=head3 Attributes

=over

=item recipe_id

The internal ID for the recipe.

=item ingredients

The ingredients required for the recipe, given as a hash with the item IDs as
the keys and the requried quantity of each as the values. Maximum of 4 entries.

=item output_item_id

The internal ID of the item that the recipe produces.

=item output_item_count

The quantity of the output item that is produced.

=item min_rating

The minimum rating required in one of the associated disciplines to craft the
recipe.

=item armorsmith
=item artificer
=item chef
=item huntsman
=item jeweler
=item leatherworker
=item tailor
=item weaponsmith

Booleans that indicate which crafting disciplines can craft the recipe.

=item disciplines

Returns all 8 discipline booleans as a hash, keyed on discipline name.

=item recipe_type

The recipe type - in-game this is the category it gets listed under in the
crafting screen.

=item unlock_method

The method by which the recipe is learned. Possible values are:

=over

=item * I<Automatic> - The recipe is automatically unlocked upon reaching the
min_rating in an associated discipline.

=item * I<Discovery> - The recipe is unlocked through the Discovery screen.

=item * I<Sheet> - The recipe is unlocked by using a "recipe sheet" consumable
item.

=back

=item time_to_craft_ms

The base time, in milliseconds, that the recipe takes to complete. When crafting
multiples of a recipe at once, this time gradually reduces to about 1/3 of its
original value.

=item recipe_warnings

If any inconsistencies or unknown values are encountered while parsing the API
response, a warning message will be returned in this attribute.

=back

=head3 Methods

=over

=item $recipe->game_link

Encodes and returns a game link using the recipe's C<recipe_id>. This link can
be copied and pasted into the in-game chat window to generate a chat link for
the recipe. Hovering on the chat link will produce a tooltip with the recipe's
details.

=back

=head3 Type/Discipline matrix

This matrix shows all the possible recipe types and which disciplines have
access to those types. Not all disciplines can craft every recipe with that
type, however.

                      Arm Art Chf Hnt Jwl Lth Tlr Wep
                      --- --- --- --- --- --- --- ---
 Component             x   x   x   x   x   x   x   x
 Consumable            x   x       x   x   x   x   x
 Inscription               x       x               x
 Insignia              x                   x   x
 Refinement            x   x       x   x   x   x   x
 UpgradeComponent      x   x       x   x   x   x   x
 Bag                   x                   x   x
 Boots                 x                   x   x
 Bulk                  x                   x   x
 Coat                  x                   x   x
 Gloves                x                   x   x
 Helm                  x                   x   x
 Leggings              x                   x   x
 Shoulders             x                   x   x
 Focus                     x
 Potion                    x
 Scepter                   x
 Staff                     x
 Trident                   x
 Dessert                       x
 Dye                           x
 Feast                         x
 IngredientCooking             x
 Meal                          x
 Seasoning                     x
 Snack                         x
 Soup                          x
 LongBow                           x
 Pistol                            x
 Rifle                             x
 ShortBow                          x
 Speargun                          x
 Torch                             x
 Warhorn                           x
 Amulet                                x
 Earring                               x
 Ring                                  x
 Axe                                               x
 Dagger                                            x
 Greatsword                                        x
 Hammer                                            x
 Harpoon                                           x
 Mace                                              x
 Shield                                            x
 Sword                                             x

=back

=cut

my @_default_disciplines = qw( Armorsmith Artificer Chef Huntsman Jeweler Leatherworker Tailor Weaponsmith );

my %enum_map = (
  'recipe_type' => [qw(
      Amulet Axe Bag Boots Bulk Coat Component Consumable Dagger Dessert Dye
      Earring Feast Focus Gloves Greatsword Hammer Harpoon Helm IngredientCooking
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
has '_unlock_method'    => ( is => 'ro', isa => 'Int',            required => 1 );
has 'ingredients'       => ( is => 'ro', isa => 'HashRef[Int]',   required => 1 );
has 'raw_json'          => ( is => 'ro', isa => 'Str', writer => '_set_json' );
has 'raw_md5'           => ( is => 'ro', isa => 'Str', writer => '_set_md5'  );
has 'recipe_warnings'   => ( is => 'ro', isa => 'Str' );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  my $new_args;

  if(my $t = delete $args->{recipe_id}) { $new_args->{recipe_id} = $t; }
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
      $new_args->{_unlock_method} =
          $f eq "AutoLearned" ? AUTO_IDX
        : $f eq "LearnedFromItem" ? ITEM_IDX
        : 0;
    } elsif (@$flags == 0) {
      $new_args->{_unlock_method} = DISC_IDX;
    } else {
      $new_args->{_unlock_method} = 0;
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
    $args->{recipe  _warnings} .= "Unrecognized $field: [$a].\n";
    $args->{$field} = '';
  }
}

# Method required to provide type and ID to Linkable role
sub _gl_data {
  my ($self) = @_;
  return (RECIPE_LINK_TYPE, $self->recipe_id);
}

sub unlock_method {
  my ($self) = @_;
  for ($self->_unlock_method) {
    return 'Automatic'    if $_ == AUTO_IDX;
    return 'Discovery'    if $_ == DISC_IDX;
    return 'RecipeSheet'  if $_ == ITEM_IDX;
    return 'Unknown';
  }
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
