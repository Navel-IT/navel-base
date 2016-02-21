# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Definition::Publisher 0.1;

use Navel::Base;

use parent 'Navel::Base::Definition';

use Navel::Utils qw/
    catch_warnings
    try_require_namespace
/;

our %PROPERTIES;

#-> methods

sub validate {
    my ($class, $raw_definition) = @_;

    $class->SUPER::validate(
        definition_class => __PACKAGE__,
        validator => {
            type => 'object',
            required => [
                @{$PROPERTIES{persistant}},
                @{$PROPERTIES{runtime}}
            ],
            properties => {
                name => {
                    type => [
                        qw/
                            string
                            integer
                            number
                        /
                    ]
                },
                backend => {
                    type => [
                        qw/
                            string
                            integer
                            number
                        /
                    ]
                },
                backend_input => {
                },
                scheduling => {
                    type => 'integer',
                    minimum => 5
                },
                auto_clean => {
                    type => 'integer',
                    minimum => 0
                },
                auto_connect => {
                    type => [
                        qw/
                            integer
                            boolean
                        /
                    ],
                    minimum => 0,
                    maximum => 1
                }
            }
        },
        code_validator => sub {
            my @errors;

            if (ref $raw_definition eq 'HASH') {
                my @load_backend_class;

                catch_warnings(
                    sub {
                        push @errors, @_;
                    },
                    sub {
                        @load_backend_class = try_require_namespace($raw_definition->{backend});
                    }
                );

                if ($load_backend_class[0]) {
                    push @errors, 'the subroutine ' . $raw_definition->{backend} . '::publish is missing' unless $raw_definition->{backend}->can('publish');

                    if (__PACKAGE__->seems_connectable($raw_definition->{backend})) {
                        for (qw/
                            connect
                            disconnect
                            is_connected
                            is_connecting
                            is_disconnected
                            is_disconnecting
                        /) {
                            push @errors, 'the subroutine ' . $raw_definition->{backend} . '::' . $_ . ' is missing' unless $raw_definition->{backend}->can($_);
                        }
                    }
                } else {
                    push @errors, $load_backend_class[1];
                }
            }

            \@errors;
        },
        raw_definition => $raw_definition,
        if_possible_suffix_errors_with_key_value => 'name'
    );
}

sub seems_connectable {
    my ($class, $backend_class) = @_;

    eval '$' . (defined $backend_class ? $backend_class : $class->{backend}) . '::IS_CONNECTABLE' or 0;
}

sub new {
    shift->SUPER::new(
        definition => shift
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
            backend
            backend_input
            scheduling
            auto_clean
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

Navel::Definition::Publisher

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
