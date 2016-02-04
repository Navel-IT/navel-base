# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Definition::Publisher 0.1;

use Navel::Base;

use parent 'Navel::Base::Definition';

use Carp 'croak';

use Navel::Utils qw/
    catch_warnings
    try_require_namespace
    isint
    exclusive_none
/;

our %PROPERTIES;

#-> methods

sub validate {
    my ($class, %options) = @_;

    croak('parameters must be a HASH reference') unless ref $options{parameters} eq 'HASH';

    $class->SUPER::validate(
        parameters => $options{parameters},
        definition_class => __PACKAGE__,
        if_possible_suffix_errors_with_key_value => 'name',
        validator_struct => {
            name => 'word',
            backend => 'text',
            scheduling => 'publisher_positive_integer',
            auto_connect => 'publisher_0_or_1'
        },
        validator_types => {
            publisher_positive_integer => sub {
                my $value = shift;

                isint($value) && $value >= 0;
            },
            publisher_0_or_1 => qr/^[01]$/
        },
        additional_validator => sub {
            my @errors;

            if (ref $options{parameters} eq 'HASH') {
                my @load_backend_class;

                @errors = ('at least one unknown key has been detected') unless exclusive_none(
                    [
                        @{$PROPERTIES{persistant}},
                        @{$PROPERTIES{runtime}}
                    ],
                    [
                        keys %{$options{parameters}}
                    ]
                );

                catch_warnings(
                    sub {
                        push @errors, @_;
                    },
                    sub {
                        @load_backend_class = try_require_namespace($options{parameters}->{backend});
                    }
                );

                if ($load_backend_class[0]) {
                    push @errors, 'the subroutine ' . $options{parameters}->{backend} . '::publish is missing' unless $options{parameters}->{backend}->can('publish');

                    if (__PACKAGE__->seems_connectable($options{parameters}->{backend})) {
                        for (qw/
                            connect
                            disconnect
                            is_connected
                            is_connecting
                            is_disconnected
                            is_disconnecting
                        /) {
                            push @errors, 'the subroutine ' . $options{parameters}->{backend} . '::' . $_ . ' is missing' unless $options{parameters}->{backend}->can($_);
                        }
                    }
                } else {
                    push @errors, $load_backend_class[1];
                }

                for (qw/
                    backend_input
                /) {
                    push @errors, 'required key ' . $_ . ' is missing' unless exists $options{parameters}->{$_};
                }

            }

            \@errors;
        }
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
