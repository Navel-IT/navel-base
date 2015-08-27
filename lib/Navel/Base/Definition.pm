# Copyright 2015 Navel-IT
# Navel Scheduler is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Base::Definition;

use strict;
use warnings;

use parent 'Navel::Base';

use Carp 'croak';

use Storable 'dclone';

use Data::Validate::Struct;

use Navel::Utils qw/
    unblessed
/;

our $VERSION = 0.1;

#-> methods

sub new {
    my ($class, %options) = @_;

    croak('definition is invalid') unless $options{validator}->($options{definition});

    bless dclone($options{definition}), ref $class || $class;
}

sub properties {
    unblessed(shift);
}

sub original_properties {
    my ($properties, %options) = (shift->properties(), @_);

    delete $properties->{$_} for @{$options{runtime_properties}};

    $properties;
}

sub merge {
    my ($self, %options) = @_;

    if ($options{validator}->(
        {
            %{$self->properties()},
            %{$options{values}}
        }
    )) {
        while (my ($property, $value) = each %{$options{values}}) {
            $self->{$property} = $value;
        }

        1;
    }
}

BEGIN {
    sub create_setters { # only works for a subclass with SUPER::merge()
        my $class = shift;

        no strict 'refs';

        $class = ref $class || $class;

        for my $property (@_) {
            *{$class . '::set_' . $property} = sub {
                shift->merge(@_);
            };
        }
    }
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=head1 NAME

Navel::Base::Definition

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
