# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

use strict;
use warnings;

use Test::More tests => 3;

BEGIN {
    use_ok('Navel::Mojolicious::Plugin::Logger');
    use_ok('Navel::Mojolicious::Plugin::JSON::XS');
    use_ok('Navel::Mojolicious::Plugin::Swagger2::StdResponses');
}

#-> main

#-> END

__END__
