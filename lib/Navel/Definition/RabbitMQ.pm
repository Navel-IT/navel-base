# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Definition::RabbitMQ 0.1;

use strict;
use warnings;

use parent 'Navel::Base::Definition';

use Carp 'croak';

use Navel::Utils qw/
    isint
    exclusive_none
/;

our %PROPERTIES;

#-> functions

#-> methods

sub new {
    shift->SUPER::new(
        definition => shift
    );
}

sub validate {
    my ($class, %options) = @_;

    croak('parameters must be a HASH reference') unless ref $options{parameters} eq 'HASH';

    $class->SUPER::validate(
        parameters => $options{parameters},
        definition_class => __PACKAGE__,
        if_possible_suffix_errors_with_key_value => 'name',
        validator_struct => {
            name => 'word',
            host => 'hostname',
            port => 'port',
            user => 'text',
            password => 'text',
            timeout => 'rabbitmq_positive_integer',
            vhost => 'text',
            tls => 'rabbitmq_0_or_1',
            heartbeat => 'rabbitmq_positive_integer',
            exchange => 'text',
            delivery_mode => 'rabbitmq_1_or_2',
            scheduling => 'rabbitmq_positive_integer',
            auto_connect => 'rabbitmq_0_or_1'
        },
        validator_types => {
            rabbitmq_positive_integer => sub {
                my $value = shift;

                isint($value) && $value >= 0;
            },
            rabbitmq_0_or_1 => qr/^[01]$/,
            rabbitmq_1_or_2 => qr/^[12]$/
        },
        additional_validator => sub {
            my @errors;

            if (ref $options{parameters} eq 'HASH') {
                @errors = ('at least one unknown key has been detected') unless exclusive_none(
                    [
                        @{$PROPERTIES{persistant}},
                        @{$PROPERTIES{runtime}}
                    ],
                    [
                        keys %{$options{parameters}}
                    ]
                );
            }

            \@errors;
        }
    );
}

sub merge {
    shift->SUPER::merge(
        values => shift
    );
}

sub persistant_properties {
    shift->SUPER::persistant_properties(
        runtime_properties => $PROPERTIES{runtime}
    );
}

BEGIN {
    %PROPERTIES = (
        persistant => [qw/
            name
            host
            port
            user
            password
            timeout
            vhost
            tls
            heartbeat
            exchange
            delivery_mode
            scheduling
            auto_connect
        /],
        runtime => [qw/
        /]
    );

    __PACKAGE__->create_setters(
        @{$PROPERTIES{persistant}},
        @{$PROPERTIES{runtime}}
    );
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Definition::RabbitMQ

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut


