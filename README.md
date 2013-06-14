GuildWars2::API
===============

GuildWars2::API is a class module that provides a set of standard interfaces to
the [Guild Wars 2 API](https://forum-en.guildwars2.com/forum/community/api/API-
Documentation/).

GuildWars2::GameLink provides functions for encoding and decoding game links
(aka chat links).

Usage
-----

    use GuildWars2::API;
    my $api = GuildWars2::API->new();

Refer to the following POD files for full documentation:
* [GuildWars2-API.pod](doc/GuildWars2-API.pod)
    * [GuildWars2-API-Objects.pod](doc/GuildWars2-API-Objects.pod)
        * [GuildWars2-API-Objects-Color.pod](doc/GuildWars2-API-Objects-Color.pod)
        * [GuildWars2-API-Objects-Guild.pod](doc/GuildWars2-API-Objects-Guild.pod)
        * [GuildWars2-API-Objects-Item.pod](doc/GuildWars2-API-Objects-Item.pod)
        * [GuildWars2-API-Objects-Recipe.pod](doc/GuildWars2-API-Objects-Recipe.pod)
* [GuildWars2-GameLink.pod](doc/GuildWars2-GameLink.pod)

Prerequisites
-------------

GuildWars2::API was written using Perl 5.16.3 and requires at least Perl 5.14.0.

GuildWars2::API requires the following modules, available from CPAN:

* [CHI](http://search.cpan.org/perldoc?CHI)
* [LWP::UserAgent](http://search.cpan.org/perldoc?LWP%3A%3AUserAgent)
* [Modern::Perl](http://search.cpan.org/perldoc?Modern%3A%3APerl)

Optionally, [ImageMagick](http://www.imagemagick.org) and the Image::Magick
module are required if you wish to generate guild emblem images directly from
GuildWars2::API. The base textures required for this are available from this
repository in a zip archive.

COPYRIGHT AND LICENSE
---------------------

Copyright 2013 by Tony Tauer ([User:Dr
ishmael](http://wiki.guildwars2.com/wiki/User:Dr_ishmael) on [Guild Wars 2
Wiki](http://wiki.guildwars2.com/wiki/))

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

