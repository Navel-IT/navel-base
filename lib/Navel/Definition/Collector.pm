# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Definition::Collector 0.1;

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
                collection => {
                    type => [
                        qw/
                            string
                            integer
                            number
                        /
                    ]
                },
                async => {
                    type => [
                        qw/
                            integer
                            boolean
                        /
                    ],
                    minimum => 0,
                    maximum => 1
                },
                scheduling => {
                    type => 'integer',
                    minimum => 5
                },
                execution_timeout => {
                    type => 'integer',
                    minimum => 0
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
            collection
            scheduling
            execution_timeout
            backend
            backend_input
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

Navel::Definition::Collector

=head1 COPYRIGHT

Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-base is licensed under the Apache License, Version 2.0

=cut
