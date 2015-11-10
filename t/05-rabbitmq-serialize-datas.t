# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN {
    use_ok('Navel::RabbitMQ::Serialize::Data', ':all');
}

#-> main

my $serialized;

if (lives_ok {
    $serialized = to(
        datas => {
            a => 0,
            b => 1
        },
        collector => Navel::Definition::Collector->new(
            {
                name => 'test-1',
                collection => 'test',
                type => 'source',
                singleton => 1,
                scheduling => '0 * * * * ?',
                source => undef,
                input => undef
            }
        ),
        starting_time => time,
        ending_time => time
    );
} 'to(): serialize') {
    lives_ok {
        from($serialized);
    } 'from(): deserialize';
}

done_testing();

#-> END

__END__
