# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Definition::Collector;

use strict;
use warnings;

use parent 'Navel::Base::Definition';

use constant {
    COLLECTOR_TYPE_PACKAGE => 'package',
    COLLECTOR_TYPE_SOURCE => 'source'
};

use Exporter::Easy (
    OK => [qw/
        :all
        collector_definition_validator
    /],
    TAGS => [
        all => [qw/
            collector_definition_validator
        /]
    ]
);

use Data::Validate::Struct;

use DateTime::Event::Cron::Quartz;

use Navel::Utils qw/
    isint
    exclusive_none
/;

our $VERSION = 0.1;

our %PROPERTIES;

#-> functions

sub collector_definition_validator($) {
    my $parameters = shift;

    my $validator = Data::Validate::Struct->new(
        {
            name => 'word',
            collection => 'word',
            type => 'collector_type',
            singleton => 'collector_singleton',
            scheduling => 'collector_cron'
        }
    );

    $validator->type(
        collector_type => sub {
            my $value = shift;

            $value eq COLLECTOR_TYPE_PACKAGE || $value eq COLLECTOR_TYPE_SOURCE;
        },
        collector_singleton => sub {
            my $value = shift;

            $value == 0 || $value == 1 if isint($value);
        },
        collector_cron => sub {
            eval {
                DateTime::Event::Cron::Quartz->new(@_);
            };
        }
    );

    $validator->validate($parameters) && exclusive_none([@{$PROPERTIES{persistant}}, @{$PROPERTIES{runtime}}], [keys %{$parameters}]) && exists $parameters->{source} && exists $parameters->{input}; # unfortunately, Data::Validate::Struct doesn't work with undef (JSON's null) value
}

#-> methods

sub new {
    shift->SUPER::new(
        validator => \&collector_definition_validator,
        definition => shift
    );
}

sub merge {
   shift->SUPER::merge(
        validator => \&collector_definition_validator,
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

=head1 NAME

Navel::Definition::Collector

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
