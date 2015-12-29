# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Definition::Collector 0.1;

use strict;
use warnings;

use parent 'Navel::Base::Definition';

use Carp 'croak';

use constant {
    COLLECTOR_TYPE_PACKAGE => 'package',
    COLLECTOR_TYPE_SOURCE => 'source'
};

use Navel::Utils qw/
    isint
    exclusive_none
/;

our %PROPERTIES;

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
            collection => 'word',
            type => 'collector_type',
            singleton => 'collector_0_or_1',
            scheduling => 'collector_positive_integer'
        },
        validator_types => {
            collector_type => qr/^(@{[COLLECTOR_TYPE_PACKAGE]}|@{[COLLECTOR_TYPE_SOURCE]})$/,
            collector_0_or_1 => qr/^[01]$/,
            collector_positive_integer => sub {
                my $value = shift;

                isint($value) && $value >= 0;
            }
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

                for (qw/
                    source
                    input
                /) {
                    push @errors, 'required key ' . $_ . ' is missing' unless exists $options{parameters}->{$_};
                }
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

sub is_type_package {
    shift->{type} eq COLLECTOR_TYPE_PACKAGE;
}

sub is_type_source {
    shift->{type} eq COLLECTOR_TYPE_SOURCE;
}

sub resolve_basename {
    my $self = shift;

    defined $self->{source} ? $self->{source} : $self->{name};
}

BEGIN {
    %PROPERTIES = (
        persistant => [qw/
            name
            collection
            type
            singleton
            scheduling
            source
            input
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

Navel::Definition::Collector

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
