# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

use strict;
use warnings;

use Test::More tests => 2;
use Test::Exception;

BEGIN {
    use_ok('Navel::Definition::Connector::Parser');
}

#-> main

my $connectors_definitions_path = 't/01-connectors.json';

lives_ok {
    Navel::Definition::Connector::Parser->new()->read(
        file_path => $connectors_definitions_path
    )->make(
        extra_parameters => {
            exec_directory_path => 't/'
        }
    );
} 'making configuration from ' . $connectors_definitions_path;

#-> END

__END__
