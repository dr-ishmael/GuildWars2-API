#!perl -w

use strict;

use GW2API;
use CGI;

my $api = GW2API->new;

$api->color_format("rgb255");

my $q = CGI->new;

#open(OMAIN, ">colors.csv") or die "unable to open file: $!\n";
open(OMAIN, ">colors.html") or die "unable to open file: $!\n";

#print OMAIN "color_id|color_name|default|cloth|leather|metal\n";
print OMAIN $q->start_html();

print OMAIN $q->start_table({-style=>"border-spacing: 0;"}) . "\n";

print OMAIN $q->Tr(
    $q->th("color_id"),
    $q->th("color_name"),
    $q->th({-style=>"width:5em"}, "default"),
    $q->th({-style=>"width:5em"}, "cloth"),
    $q->th({-style=>"width:5em"}, "leather"),
    $q->th({-style=>"width:5em"}, "metal")
) . "\n";

my %colors = $api->colors;

foreach my $color_id (sort { $a <=> $b } keys %colors) {

  my $color = $colors{$color_id};

  my $color_name = $color->{name};
  my $default    = $color->{default} || [];
  my $cloth      = $color->{cloth} || [];
  my $leather    = $color->{leather} || [];
  my $metal      = $color->{metal} || [];
  
  $default = join(",",@$default);
  $cloth = join(",",@$cloth);
  $leather = join(",",@$leather);
  $metal = join(",",@$metal);

#  print OMAIN "$color_id|$color_name|$default|$cloth|$leather|$metal\n";
  print OMAIN $q->Tr(
      $q->td("$color_id"),
      $q->td("$color_name"),
      $q->td({-style=>"background-color:rgb($default)",-title=>"rgb($default)"}),
      $q->td({-style=>"background-color:rgb($cloth)",-title=>"rgb($cloth)"}),
      $q->td({-style=>"background-color:rgb($leather)",-title=>"rgb($leather)"}),
      $q->td({-style=>"background-color:rgb($metal)",-title=>"rgb($metal)"})
  ) . "\n";
}

print OMAIN $q->end_table() . "\n";

print OMAIN $q->end_html();

close (OMAIN);

exit;
