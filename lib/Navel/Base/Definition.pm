# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Base::Definition;

use strict;
use warnings;

use parent 'Navel::Base';

use Storable 'dclone';

use Data::Validate::Struct 0.1;

use Navel::Utils qw/
    unblessed
/;

our $VERSION = 0.1;

#-> methods

sub new {
    my ($class, %options) = @_;

    my $errors = $class->validate(
        parameters => $options{definition}
    );

    die $errors if @{$errors};

    bless dclone($options{definition}), ref $class || $class;
}

sub validate {
    my ($class, %options) = @_;

    my @errors;

    my $definition_fullname;

    my $validator = Data::Validate::Struct->new($options{validator_struct});

    $validator->type(%{$options{validator_types}});

    @errors = @{$validator->{errors}} unless $validator->validate($options{parameters});

    push @errors, @{$options{additional_validator}->()} if ref $options{additional_validator} eq 'CODE';

    if (defined $options{if_possible_suffix_errors_with_key_value}) {
        my $definition_name = eval {
            $options{parameters}->{$options{if_possible_suffix_errors_with_key_value}};
        };

        $definition_fullname = $definition_name if defined $definition_name;

        $definition_fullname = $options{definition_class} . '[' . $definition_fullname . ']';
    } else {
        $definition_fullname = $options{definition_class};
    }

    [
        map {
            $definition_fullname . ': ' . $_ . '.'
        } @errors
    ];
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

    my $errors = $self->validate(
        parameters => {
            %{$self->properties()},
            %{$options{values}}
        }
    );

    unless (@{$errors}) {
        while (my ($property, $value) = each %{$options{values}}) {
            $self->{$property} = $value;
        }
    }

    $errors;
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
