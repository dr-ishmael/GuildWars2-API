GW2API.pm
=========

GW2API.pm - A Perl library for accessing the Guild Wars 2 API

Synopsis
--------

    require GW2API;
    
    my $api = GW2API->new;
    
    # Check the current state of an event on all worlds
    
    my %event_states = $api->event_state_by_world($event_id);
    
    foreach my $world_id (keys %event_states) {
        my $state = $event_states{$world_id};
        
        print "$world_id : $state\n";
        
    }
    
    # Lookup the attribute bonuses on a weapon
    
    my %item_details = $api->item_details($item_id);
    
    my $attributes_ref = %item_details{weapon}->{attributes};
    
    foreach my $attribute (@$attributes_ref) {
        my ($attr_name, $attr_value) = 
             ($attribute->{attribute}, $attribute->{modifier});
        
        print "+$attr_value $attr_name\n";
        
    }

Description
-----------

GW2API is a class module that provides a set of standard interfaces to the Guild 
Wars 2 API.

Dependencies
------------

GW2API was written using Perl 5.16.  It uses the smartmatch operator (~~), thus 
it requires at least Perl 5.10.1. It should work with all versions after that, 
although this hasn't been tested.

GW2API requires the following modules, available from CPAN:

* [CHI](http://search.cpan.org/~jswartz/CHI-0.56/lib/CHI.pm)
* JSON::XS
* LWP::UserAgent

COPYRIGHT AND LICENSE
---------------------

Copyright 2013 by Tony Tauer

This library is free software; you can redistribute it and/or modify it under 
the same terms as Perl itself. 

