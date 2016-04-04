# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN {
    use_ok('Navel::Definition::Publisher::Parser');
    use_ok('Navel::Broker::Publisher');
    use_ok('Navel::Definition::Collector::Parser');
}

#-> main

my $valid_publishers_definitions_path = 't/02-valid-publishers.yml';

my $invalid_publishers_definitions_path = 't/02-invalid-publishers.yml';

my $collectors_definitions_path = 't/01-collectors.yml';

my ($valid_publishers, $collectors);

lives_ok {
    $valid_publishers = Navel::Definition::Publisher::Parser->new()->read(
        file_path => $valid_publishers_definitions_path
    )->make();
} 'making configuration from ' . $valid_publishers_definitions_path;

lives_ok {
    $collectors = Navel::Definition::Collector::Parser->new()->read(
        file_path => $collectors_definitions_path
    )->make();
} 'making configuration from ' . $collectors_definitions_path;

for my $valid_publisher (@{$valid_publishers->{definitions}}) {
    lives_ok {
        my $valid_publisher_runtime = Navel::Broker::Publisher->new(
            definition => $valid_publisher
        )->push_in_queue(
            {
                collector => $collectors->{definitions}->[0],
                status => 'OK'
            }
        );

        $_->deserialize($_->serialize()) for @{$valid_publisher_runtime->{queue}};

        $valid_publisher_runtime->clear_queue();
    } $valid_publisher->{name} . ': not connectable and push_in_queue() + (de)serialize events + clear_queue()';
}

dies_ok {
    Navel::Definition::Publisher::Parser->new()->read(
        file_path => $invalid_publishers_definitions_path
    )->make();
} 'making configuration from ' . $invalid_publishers_definitions_path;

done_testing();

#-> END

__END__
