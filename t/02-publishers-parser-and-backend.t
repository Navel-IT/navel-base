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
    use_ok('Navel::Definition::Collector::Parser');
    use_ok('Navel::Broker::Client::Fork');
    use_ok('Navel::Logger');
}

#-> main

my $publishers_definitions_path = 't/02-publishers.yml';

my $collectors_definitions_path = 't/01-collectors.yml';

my ($publishers, $collectors);

lives_ok {
    $publishers = Navel::Definition::Publisher::Parser->new()->read(
        file_path => $publishers_definitions_path
    )->make();
} 'making configuration from ' . $publishers_definitions_path;

lives_ok {
    $collectors = Navel::Definition::Collector::Parser->new()->read(
        file_path => $collectors_definitions_path
    )->make();
} 'making configuration from ' . $collectors_definitions_path;

for my $publisher (@{$publishers->{definitions}}) {
    lives_ok {
        my $publisher_runtime = Navel::Broker::Client::Fork->new(
            logger => Navel::Logger->new(
                severity => 'notice',
                facility => 'local0'
            ),
            definition => $publisher
        )->push_in_queue(
            {
                collector => $collectors->{definitions}->[0],
                status => 'OK'
            }
        );

        $_->deserialize($_->serialize()) for @{$publisher_runtime->{queue}};

        $publisher_runtime->clear_queue();
    } $publisher->{name} . ': not connectable and push_in_queue() + (de)serialize events + clear_queue()';
}

done_testing();

#-> END

__END__
