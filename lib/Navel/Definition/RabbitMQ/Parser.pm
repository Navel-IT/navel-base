# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Definition::RabbitMQ::Parser 0.1;

use strict;
use warnings;

use parent 'Navel::Base::Definition::Parser';

#-> methods

sub new {
    shift->SUPER::new(
        definition_class => 'Navel::Definition::RabbitMQ',
        do_not_need_at_least_one => 1,
        @_
    );
}

BEGIN {
    __PACKAGE__->create_getters(qw/
        host
        port
        user
        password
        vhost
        tls
        heartbeat
        exchange
        delivery_mode
        scheduling
    /);
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Definition::RabbitMQ::Parser

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut

