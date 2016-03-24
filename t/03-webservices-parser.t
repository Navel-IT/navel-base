# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

use strict;
use warnings;

use Test::More tests => 2;
use Test::Exception;

BEGIN {
    use_ok('Navel::Definition::WebService::Parser');
}

#-> main

my $web_services_definitions_path = 't/03-webservices.yml';

lives_ok {
    Navel::Definition::WebService::Parser->new()->read(
        file_path => $web_services_definitions_path
    )->make();
} 'making configuration from ' . $web_services_definitions_path;

#-> END

__END__
