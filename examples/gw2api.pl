#!perl -w

use strict;
use Modern::Perl '2014';

use GuildWars2::API;

my $api = GuildWars2::API->new();

#foreach my $item_id ($api->list_items) {
#  my $item = $api->get_item($item_id);
#
#  say $item->item_name;
#
#  exit;
#}

#my @item_ids = $api->list_items;

my $item = $api->get_item(117);
say $item->md5;
  if (defined($item->item_warnings)) {
    say $item->item_warnings;
  }

#say $api->build;
#
#foreach my $item ($api->get_item_page()) {
#  if (defined($item->item_warnings)) {
#    say $item->item_id.' '.$item->item_warnings;
#  }
#}

#while (my @items = $api->get_item_page(250)) {
#  last if ! defined $items[0];
#  foreach my $item ($api->get_item_page()) {
#    if (defined($item->item_warnings)) {
#      say $item->item_id.' '.$item->item_warnings;
#    }
#  }
#}
#
#say $api->api_error->text;
