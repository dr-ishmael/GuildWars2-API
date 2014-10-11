package GuildWars2::API::Constants;

use base 'Exporter';

# Chat link headers
use constant {
  COIN_LINK_TYPE     =>  1,
  ITEM_LINK_TYPE     =>  2,
  TEXT_LINK_TYPE     =>  3,
  MAP_LINK_TYPE      =>  4,
  SKILL_LINK_TYPE    =>  7,
  TRAIT_LINK_TYPE    =>  8,
  RECIPE_LINK_TYPE   => 10,
  SKIN_LINK_TYPE     => 11,
  OUTFIT_LINK_TYPE   => 12,
};

# Recipe "learned from" flags
use constant {
  DISC_IDX => 1,
  AUTO_IDX => 2,
  ITEM_IDX => 3,
};

our @EXPORT = qw(
        COIN_LINK_TYPE ITEM_LINK_TYPE TEXT_LINK_TYPE MAP_LINK_TYPE SKILL_LINK_TYPE TRAIT_LINK_TYPE RECIPE_LINK_TYPE
        DISC_IDX AUTO_IDX ITEM_IDX
  );

1;
