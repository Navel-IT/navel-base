# Copyright 2015 Navel-IT
# Navel Scheduler is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Base::Definition::Parser;

use strict;
use warnings;

use parent qw/
    Navel::Base
    Navel::Base::Definition::Parser::Reader
    Navel::Base::Definition::Parser::Writer
/;

use Carp 'croak';

use Scalar::Util::Numeric 'isint';

use Navel::Utils 'reftype';

our $VERSION = 0.1;

#-> methods

sub new {
    my ($class, %options) = @_;

    my $self = bless {
        definition_class => $options{definition_class},
        do_not_need_at_least_one => $options{do_not_need_at_least_one},
        raw => [],
        definitions => []
    }, ref $class || $class;

    $self->set_maximum($options{maximum});
}

sub read {
    my $self = shift;

    $self->{raw} = $self->SUPER::read(@_);

    $self;
}

sub write {
    my $self = shift;

    $self->SUPER::write(
        definitions => [
            map {
                $_->original_properties()
            } @{$self->{definitions}}
        ],
        @_
    );

    $self;
}

sub make_definition {
    my ($self, $raw_definition) = @_;

    my $definition = eval {
        $self->{definition_class}->new($raw_definition);
    };

    $@ ? croak($self->{definition_class} . ': ' . $@) : $definition;
};

sub make {
    my ($self, %options) = @_;

    if (eval 'require ' . $self->{definition_class}) {
        if (reftype($self->{raw}) eq 'ARRAY' and @{$self->{raw}} || $self->{do_not_need_at_least_one}) {
            $self->add_definition(reftype($options{extra_parameters}) eq 'HASH'
            ?
                {
                    %{$_},
                    %{$options{extra_parameters}}
                }
            : $_
            ) for @{$self->{raw}};
        } else {
            croak($self->{definition_class} . ': raw datas need to exists and to be encapsulated in an array');
        }
    } else {
        croak($self->{definition_class} . ': require failed');
    }

    $self;
}

sub set_maximum {
    my ($self, $maximum) = @_;

    my $minimum = 0;

    $maximum = $maximum || $minimum;

    croak('maximum must be an integer equal or greater than ' . $minimum) unless isint($maximum) && $maximum >= $minimum;

    $self->{maximum} = $maximum;

    $self;
}

sub definition_by_name {
    my ($self, $name) = @_;

    for (@{$self->{definitions}}) {
        return $_ if $_->{name} eq $name;
    }

    undef;
}

sub definition_properties_by_name {
    my $definition = shift->definition_by_name(@_);

    defined $definition ? $definition->properties() : undef;
}

sub all_by_property_name {
    my ($self, $name) = @_;

    [
        map {
            $_->can($name) ? $_->$name() : $_->{$name}
        } @{$self->{definitions}}
    ];
}

sub add_definition {
    my ($self, $raw_definition) = @_;

    my $definition = $self->make_definition($raw_definition);

    croak($self->{definition_class} . ': the maximum number of definition (' . $self->{maximum} . ') has been reached') if $self->{maximum} && @{$self->{definitions}} > $self->{maximum};
    croak($self->{definition_class} . ': duplicate definition detected') if defined $self->definition_by_name($definition->{name});

    push @{$self->{definitions}}, $definition;

    $definition;
}

sub delete_definition {
    my ($self, %options) = @_;

    my $definition_to_delete_index = 0;

    my $finded;

    $definition_to_delete_index++ until $finded = $self->{definitions}->[$definition_to_delete_index]->{name} eq $options{definition_name};

    croak($self->{definition_class} . ': definition ' . $options{definition_name} . ' does not exists') unless $finded;

    $options{do_before_slice}->($self->{definitions}->[$definition_to_delete_index]) if ref $options{do_before_slice} eq 'CODE';

    splice @{$self->{definitions}}, $definition_to_delete_index, 1;

    $options{definition_name};
}

BEGIN {
    sub create_getters {
        my $class = shift;

        no strict 'refs';

        $class = ref $class || $class;

        for my $property (@_) {
            *{$class . '::' . $property} = sub {
                shift->all_by_property_name($property);
            };
        }
    }

    __PACKAGE__->create_getters('name');
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=head1 NAME

Navel::Base::Definition::Parser

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
