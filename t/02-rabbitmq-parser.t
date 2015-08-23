# Copyright 2015 Navel-IT
# Navel Scheduler is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

use strict;
use warnings;

use Test::More tests => 2;
use Test::Exception;

BEGIN {
    use_ok('Navel::Definition::RabbitMQ::Parser');
}

#-> main

my $rabbitmq_definitions_path = 't/02-rabbitmq.json';

lives_ok {
    Navel::Definition::RabbitMQ::Parser->new()->read($rabbitmq_definitions_path)->make();
} 'making configuration from ' . $rabbitmq_definitions_path;

#-> END

__END__
