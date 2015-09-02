# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Definition::RabbitMQ;

use strict;
use warnings;

use parent 'Navel::Base::Definition';

use Exporter::Easy (
    OK => [qw/
        :all
        rabbitmq_definition_validator
    /],
    TAGS => [
        all => [qw/
            rabbitmq_definition_validator
        /]
    ]
);

use Data::Validate::Struct;

use DateTime::Event::Cron::Quartz;

use Navel::Utils 'isint';

our $VERSION = 0.1;

our @RUNTIME_PROPERTIES;

#-> functions

sub rabbitmq_definition_validator($) {
    my $parameters = shift;

    my $validator = Data::Validate::Struct->new(
        {
            name => 'word',
            host => 'hostname',
            port => 'port',
            user => 'text',
            password => 'text',
            timeout => 'connector_positive_integer',
            vhost => 'text',
            tls => 'connector_boolean',
            heartbeat => 'connector_positive_integer',
            exchange => 'text',
            delivery_mode => 'connector_props_delivery_mode',
            scheduling => 'connector_cron',
            auto_connect => 'connector_boolean'
        }
    );

    $validator->type(
        connector_positive_integer => sub {
            my $value = shift;

            isint($value) && $value >= 0;
        },
        connector_props_delivery_mode => sub {
            my $value = shift;

            $value == 1 || $value == 2 if isint($value);
        },
        connector_cron => sub {
            eval {
                DateTime::Event::Cron::Quartz->new(@_);
            };
        },
        connector_boolean => sub {
            my $value = shift;

            $value == 0 || $value == 1 if isint($value);
        }
    );

    $validator->validate($parameters);
}

#-> methods

sub new {
    shift->SUPER::new(
        validator => \&rabbitmq_definition_validator,
        definition => shift
    );
}

sub merge {
   shift->SUPER::merge(
        validator => \&rabbitmq_definition_validator,
        values => shift
   );
}

sub original_properties {
    shift->SUPER::original_properties(
        runtime_properties => \@RUNTIME_PROPERTIES
    );
}

BEGIN {
    __PACKAGE__->create_setters(qw/
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
    /);
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=head1 NAME

Navel::Definition::RabbitMQ

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
