use Modern::Perl '2014';

package GuildWars2::API::Utils;

use base 'Exporter';

use List::MoreUtils qw(any each_arrayref);

# Shorthand for List::MoreUtils->any
sub in {
  my ($needle, $haystack) = @_;
  return any { $_ eq $needle } @$haystack;
}

# Use Lits::MoreUtils->each_arrayref to test element equality between arrays
sub array_match {
  my ($xref, $yref) = @_;
  return unless  @$xref == @$yref;

  my $it = each_arrayref($xref, $yref);
  while ( my ($x, $y) = $it->() ) {
      return unless $x eq $y;
  }
  return 1;
}

our @EXPORT = qw(in array_match);

1;
