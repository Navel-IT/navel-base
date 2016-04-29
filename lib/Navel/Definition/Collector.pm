# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Definition::Collector 0.1;

use Navel::Base;

use parent 'Navel::Base::Definition';

use constant {
    COLLECTOR_TYPE_PM => 'package',
    COLLECTOR_TYPE_PL => 'script'
};

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
                type => {
                    type => 'string',
                    enum => [
                        COLLECTOR_TYPE_PM,
                        COLLECTOR_TYPE_PL
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
                source => {
                    type => [
                        qw/
                            null
                            string
                            integer
                            number
                        /
                    ]
                },
                input => {
                }
            }
        },
        raw_definition => $raw_definition,
        if_possible_suffix_errors_with_key_value => 'name'
    );
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
        runtime_properties => $properties{runtime}
    );
}

sub is_type_pm {
    shift->{type} eq COLLECTOR_TYPE_PM;
}

sub is_type_pl {
    shift->{type} eq COLLECTOR_TYPE_PL;
}

sub resolve_basename {
    my $self = shift;

    defined $self->{source} ? $self->{source} : $self->{name};
}

BEGIN {
    %properties = (
        persistant => [qw/
            name
            collection
            type
            scheduling
            source
            input
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

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
