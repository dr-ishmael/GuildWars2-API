use Carp ();
use Modern::Perl '2012';

=pod

=head1 DESCRIPTION

This subclass of GuildWars2::API::Objects defines the Recipe object.

=cut

####################
# Recipe
####################
package GuildWars2::API::Objects::Recipe;
use Moose;
use Moose::Util::TypeConstraints;

=pod

=head1 CLASSES

=head2 Recipe

The Recipe object represents a crafting recipe in Guild Wars 2. It is returned
by the $api->get_recipe() method.

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

Returns all 8 discipline booleans as an array, in English alphabetical order.

=item recipe_type

The recipe type - in-game this is the category it gets listed under in the
crafting screen.

=item unlock_method

The method by which the recipe is learned. Possible values are:

=over

=item * I<auto> - The recipe is automatically unlocked upon reaching the
min_rating in an associated discipline.

=item * I<discover> - The recipe is unlocked through the Discovery screen.

=item * I<item> - The recipe is unlocked by using a "recipe sheet" consumable
item.

=back

=item time_to_craft_ms

The base time, in milliseconds, that the recipe takes to complete. When crafting
multiples of a recipe at once, this time gradually reduces to about 1/3 of its
original value.

=head3 Type/Discipline matrix

This matrix shows all the possible recipe types and which disciplines have
access to those types. Not all disciplines can craft every recipe with that
type, however.

                      Arm Art Chf Hnt Jwl Lth Tlr Wep
                      --- --- --- --- --- --- --- ---
 Component             x   x   x   x   x   x   x   x
 Consumable            x   x   x   x   x   x   x   x
 Refinement            x   x   x   x   x   x   x   x
 UpgradeComponent      x   x   x   x   x   x   x   x
 Bag                   x                   x   x
 Boots                 x                   x   x
 Bulk                  x                   x   x
 Coat                  x                   x   x
 Gloves                x                   x   x
 Helm                  x                   x   x
 Insignia              x                   x   x
 Leggings              x                   x   x
 Shoulders             x                   x   x
 Inscription               x       x               x
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

use constant DISC_IDX => 0;
use constant AUTO_IDX => 1;
use constant ITEM_IDX => 2;

use constant ARMR_IDX => 0;
use constant ARTF_IDX => 1;
use constant CHEF_IDX => 2;
use constant HUNT_IDX => 3;
use constant JEWL_IDX => 4;
use constant LTHR_IDX => 5;
use constant TALR_IDX => 6;
use constant WEPN_IDX => 7;

enum 'RecipeType', [qw(
    Amulet Axe Bag Boots Bulk Coat Component Consumable Dagger Dessert Dye
    Earring Feast Focus Gloves Greatsword Hammer Harpoon Helm IngredientCooking
    Inscription Insignia Leggings LongBow Mace Meal Pistol Potion Refinement
    Rifle Ring Scepter Seasoning Shield ShortBow Shoulders Snack Soup Speargun
    Staff Sword Torch Trident UpgradeComponent Warhorn
  )];

has 'recipe_id'           => ( is => 'ro', isa => 'Int',            required => 1 );
has 'recipe_type'         => ( is => 'ro', isa => 'RecipeType',     required => 1 );
has 'output_item_id'      => ( is => 'ro', isa => 'Int',            required => 1 );
has 'output_item_count'   => ( is => 'ro', isa => 'Int',            required => 1 );
has 'min_rating'          => ( is => 'ro', isa => 'Int',            required => 1 );
has 'time_to_craft_ms'    => ( is => 'ro', isa => 'Int',            required => 1 );
has 'disciplines'         => ( is => 'ro', isa => 'ArrayRef[Bool]', required => 1 );
has '_unlock_method'      => ( is => 'ro', isa => 'Int',            required => 1 );
has 'ingredients'         => ( is => 'ro', isa => 'HashRef[Int]',   required => 1 );

around 'BUILDARGS', sub {
  my ($orig, $class, $args) = @_;

  if(my $disciplines = delete $args->{disciplines}) {
    $args->{disciplines}->[ARMR_IDX] = "Armorsmith"    ~~ @$disciplines ? 1 : 0;
    $args->{disciplines}->[ARTF_IDX] = "Artificer"     ~~ @$disciplines ? 1 : 0;
    $args->{disciplines}->[CHEF_IDX] = "Chef"          ~~ @$disciplines ? 1 : 0;
    $args->{disciplines}->[HUNT_IDX] = "Huntsman"      ~~ @$disciplines ? 1 : 0;
    $args->{disciplines}->[JEWL_IDX] = "Jeweler"       ~~ @$disciplines ? 1 : 0;
    $args->{disciplines}->[LTHR_IDX] = "Leatherworker" ~~ @$disciplines ? 1 : 0;
    $args->{disciplines}->[TALR_IDX] = "Tailor"        ~~ @$disciplines ? 1 : 0;
    $args->{disciplines}->[WEPN_IDX] = "Weaponsmith"   ~~ @$disciplines ? 1 : 0;
  }

  if(my $flags = delete $args->{flags}) {
    my $a = "AutoLearned"      ~~ @$flags ? 1 : 0;
    my $i = "LearnedFromItem"  ~~ @$flags ? 1 : 0;

    $args->{_unlock_method} = $a ? AUTO_IDX : $i ? ITEM_IDX : DISC_IDX;
  }

  if(my $ingredients = delete $args->{ingredients}) {
    foreach my $i (@$ingredients) {
      $args->{ingredients}->{$i->{item_id}} = $i->{count};
    }
  }

  if(my $t = delete $args->{type}) {
    $args->{recipe_type} = $t;
  }

  $class->$orig($args);
};

sub unlock_method {
  my ($self) = @_;
  for ($self->_unlock_method) {
    return 'auto'     when AUTO_IDX;
    return 'discover' when DISC_IDX;
    return 'item'     when ITEM_IDX;
  }
}

sub armorsmith    { return $_[0]->{disciplines}->[ARMR_IDX]; }
sub artificer     { return $_[0]->{disciplines}->[ARTF_IDX]; }
sub chef          { return $_[0]->{disciplines}->[CHEF_IDX]; }
sub huntsman      { return $_[0]->{disciplines}->[HUNT_IDX]; }
sub jeweler       { return $_[0]->{disciplines}->[JEWL_IDX]; }
sub leatherworker { return $_[0]->{disciplines}->[LTHR_IDX]; }
sub tailor        { return $_[0]->{disciplines}->[TALR_IDX]; }
sub weaponsmith   { return $_[0]->{disciplines}->[WEPN_IDX]; }

1;
