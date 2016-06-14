# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Definition::Publisher 0.1;

use Navel::Base;

use parent 'Navel::Base::Definition';

#-> class variables

my %properties;

#-> methods

sub validate {
    my ($class, $raw_definition) = @_;

    $class->SUPER::validate(
        definition_class => __PACKAGE__,
        validator => {
            type => 'object',
            additionalProperties => 0,
            required => [
                @{$properties{persistant}},
                @{$properties{runtime}}
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
                connectable => {
                    type => [
                        qw/
                            integer
                            boolean
                        /
                    ],
                    minimum => 0,
                    maximum => 1
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
                },
                except_collections => {
                    type => 'array',
                    items => {
                        type => qw/
                            string
                            integer
                            number
                        /
                    }
                }
            }
        },
        raw_definition => $raw_definition,
        if_possible_suffix_errors_with_key_value => 'name'
    );
}

sub full_name {
    my $self = shift;

    __PACKAGE__ . '.' . $self->{backend} . '.' . $self->{name};
}

sub persistant_properties {
    shift->SUPER::persistant_properties($properties{runtime});
}

BEGIN {
    %properties = (
        persistant => [qw/
            name
            backend
            backend_input
            scheduling
            auto_clean
            connectable
            auto_connect
            except_collections
        /],
        runtime => [qw/
        /]
    );

    __PACKAGE__->create_setters(
        @{$properties{persistant}},
        @{$properties{runtime}}
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

=head1 COPYRIGHT

Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-base is licensed under the Apache License, Version 2.0

=cut
