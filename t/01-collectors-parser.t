# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

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

my $collectors_definitions_path = 't/01-collectors.yml';

lives_ok {
    Navel::Definition::Collector::Parser->new()->read(
        file_path => $collectors_definitions_path
    )->make();
} 'making configuration from ' . $collectors_definitions_path;

#-> END

__END__
