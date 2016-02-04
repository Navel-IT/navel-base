# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

use strict;
use warnings;

use Test::More tests => 2;
use Test::Exception;

BEGIN {
    use_ok('Navel::Definition::Collector::Parser');
}

#-> main

my $collectors_definitions_path = 't/01-collectors.json';

lives_ok {
    Navel::Definition::Collector::Parser->new()->read(
        file_path => $collectors_definitions_path
    )->make();
} 'making configuration from ' . $collectors_definitions_path;

#-> END

__END__
