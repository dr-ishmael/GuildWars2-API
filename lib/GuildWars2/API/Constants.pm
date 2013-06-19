package GuildWars2::API::Constants;

use base 'Exporter';

use constant COIN_LINK_TYPE     =>  1;
use constant ITEM_LINK_TYPE     =>  2;
use constant TEXT_LINK_TYPE     =>  3;
use constant MAP_LINK_TYPE      =>  4;
use constant SKILL_LINK_TYPE    =>  7;
use constant TRAIT_LINK_TYPE    =>  8;
use constant RECIPE_LINK_TYPE   => 10;

use constant DISC_IDX => 0;
use constant AUTO_IDX => 1;
use constant ITEM_IDX => 2;

our @EXPORT = qw(
        COIN_LINK_TYPE ITEM_LINK_TYPE TEXT_LINK_TYPE MAP_LINK_TYPE SKILL_LINK_TYPE TRAIT_LINK_TYPE RECIPE_LINK_TYPE
        DISC_IDX AUTO_IDX ITEM_IDX
  );

1;
