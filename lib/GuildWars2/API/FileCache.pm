use Modern::Perl '2014';

package CHI::Driver::File::GW2API;

use Moo;

extends 'CHI::Driver::File';

sub generate_temporary_filename {
    my ( $self, $dir, $file ) = @_;
    return undef;
}



package GuildWars2::API;

use Moose;
use Time::Duration::Parse;


sub clean_item_cache {
  my ($self) = @_;
  if ($self->nocache) {
    say "nocache specified, cannot clean cache";
    return;
  }

  my $now = time();
  my $AGE = parse_duration($self->{item_cache_age});
  my $wanted = sub { unlink $_ if -f $_ && $_ =~ /(item|recipe)_details/ && $now - (stat $_)[9] > $AGE; };
  find ( { no_chdir => 1, wanted => $wanted }, $self->{cache_dir} );
}

sub empty_item_cache {
  my ($self) = @_;
  if ($self->nocache) {
    say "nocache specified, cannot empty cache";
    return;
  }

  my $now = time();
  my $AGE = parse_duration($self->{item_cache_age});
  my $wanted = sub { unlink $_ if -f $_ && $_ =~ /(item|recipe)_details/; };
  find ( { no_chdir => 1, wanted => $wanted }, $self->{cache_dir} );
}

1;
