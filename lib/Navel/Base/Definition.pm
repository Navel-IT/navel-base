# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Base::Definition;

use strict;
use warnings;

use parent 'Navel::Base';

use Storable 'dclone';

use Data::Validate::Struct;

use Navel::Utils qw/
    unblessed
/;

our $VERSION = 0.1;

#-> methods

sub new {
    my ($class, %options) = @_;

    die "definition is invalid\n" unless $class->validate(
        parameters => $options{definition}
    );

    bless dclone($options{definition}), ref $class || $class;
}

sub validate {
    my ($class, %options) = @_;

    my $validator = Data::Validate::Struct->new($options{validator_struct});

    while (my ($type_name, $type_sub) = each %{$options{validator_types}}) {
        $validator->type(
            $type_name => $type_sub
        );
    }

    if ($validator->validate($options{parameters})) {
        return ref $options{additional_validator} eq 'CODE' ? $options{additional_validator}->() : 1;
    } else {
        $options{errors_callback}->($options{definition_class}, $validator->{errors}) if ref $options{errors_callback} eq 'CODE';
    }

    0;
}

sub properties {
    unblessed(shift);
}

sub persistant_properties {
    my ($properties, %options) = (shift->properties(), @_);

    delete $properties->{$_} for @{$options{runtime_properties}};

    $properties;
}

sub merge {
    my ($self, %options) = @_;

    if ($self->validate(
        parameters => {
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
