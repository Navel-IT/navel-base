# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Definition::RabbitMQ;

use strict;
use warnings;

use parent 'Navel::Base::Definition';

use DateTime::Event::Cron::Quartz;

use Navel::Utils qw/
    isint
    exclusive_none
/;

our $VERSION = 0.1;

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

    $class->SUPER::validate(
        on_errors => $options{on_errors},
        parameters => $options{parameters},
        definition_class => __PACKAGE__,
        if_possible_suffix_errors_with_key_value => 'name',
        validator_struct => {
            name => 'word',
            host => 'hostname',
            port => 'port',
            user => 'text',
            password => 'text',
            timeout => 'collector_positive_integer',
            vhost => 'text',
            tls => 'collector_boolean',
            heartbeat => 'collector_positive_integer',
            exchange => 'text',
            delivery_mode => 'collector_props_delivery_mode',
            scheduling => 'collector_cron',
            auto_connect => 'collector_boolean'
        },
        validator_types => {
            collector_positive_integer => sub {
                my $value = shift;

                isint($value) && $value >= 0;
            },
            collector_props_delivery_mode => sub {
                my $value = shift;

                $value == 1 || $value == 2 if isint($value);
            },
            collector_cron => sub {
                eval {
                    DateTime::Event::Cron::Quartz->new(@_);
                };
            },
            collector_boolean => sub {
                my $value = shift;

                $value == 0 || $value == 1 if isint($value);
            }
        },
        additional_validator => sub {
            my @errors;

            unless (ref $options{parameters} eq 'HASH' && exclusive_none([@{$PROPERTIES{persistant}}, @{$PROPERTIES{runtime}}], [keys %{$options{parameters}}])) {
                @errors = ('at least one unknown key has been detected');
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

=head1 NAME

Navel::Definition::RabbitMQ

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
