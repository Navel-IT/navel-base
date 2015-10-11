# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Definition::Connector;

use strict;
use warnings;

use parent 'Navel::Base::Definition';

use constant {
    CONNECTOR_TYPE_CODE => 'code',
    CONNECTOR_TYPE_JSON => 'json'
};

use Exporter::Easy (
    OK => [qw/
        :all
        connector_definition_validator
    /],
    TAGS => [
        all => [qw/
            connector_definition_validator
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

sub connector_definition_validator($) {
    my $parameters = shift;

    my $validator = Data::Validate::Struct->new(
        {
            name => 'word',
            collection => 'word',
            type => 'connector_type',
            singleton => 'connector_singleton',
            scheduling => 'connector_cron'
        }
    );

    $validator->type(
        connector_type => sub {
            my $value = shift;

            $value eq CONNECTOR_TYPE_CODE || $value eq CONNECTOR_TYPE_JSON;
        },
        connector_singleton => sub {
            my $value = shift;

            $value == 0 || $value == 1 if isint($value);
        },
        connector_cron => sub {
            eval {
                DateTime::Event::Cron::Quartz->new(@_);
            };
        }
    );

    $validator->validate($parameters) && exclusive_none([@{$PROPERTIES{persistant}}, @{$PROPERTIES{runtime}}], [keys %{$parameters}]) && (exists $parameters->{source} and ! defined $parameters->{source} || $parameters->{source} =~ /^[\w_\-]+$/) && exists $parameters->{input}; # unfortunately, Data::Validate::Struct doesn't work with undef (JSON's null) value
}

#-> methods

sub new {
    shift->SUPER::new(
        validator => \&connector_definition_validator,
        definition => shift
    );
}

sub merge {
   shift->SUPER::merge(
        validator => \&connector_definition_validator,
        values => shift
   );
}

sub persistant_properties {
    shift->SUPER::persistant_properties(
        runtime_properties => $PROPERTIES{runtime}
    );
}

sub is_type_code {
    shift->{type} eq CONNECTOR_TYPE_CODE;
}

sub is_type_json {
    shift->{type} eq CONNECTOR_TYPE_JSON;
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

Navel::Definition::Connector

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
