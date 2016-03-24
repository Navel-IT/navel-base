# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Base::Definition 0.1;

use Navel::Base;

use JSON::Validator;

use Navel::Utils qw/
    clone
    unbless
/;

#-> methods

sub new {
    my ($class, %options) = @_;
    
    my $definition = unbless(clone($options{definition}));

    my $errors = $class->validate($options{definition});

    die $errors if @{$errors};

    bless clone($definition), ref $class || $class;
}

sub validate {
    my ($class, %options) = @_;

    my $definition_fullname;

    my @errors = JSON::Validator->new()->schema($options{validator})->validate($options{raw_definition});

    push @errors, @{$options{code_validator}->()} if ref $options{code_validator} eq 'CODE';

    if (defined $options{if_possible_suffix_errors_with_key_value}) {
        local $@;

        my $definition_name = eval {
            $options{raw_definition}->{$options{if_possible_suffix_errors_with_key_value}};
        };

        $definition_fullname = $definition_name if defined $definition_name;

        $definition_fullname = $options{definition_class} . '[' . $definition_fullname . ']';
    } else {
        $definition_fullname = $options{definition_class};
    }

    [
        map {
            $definition_fullname . ': ' . (defined $_  ? $_ : '?')
        } @errors
    ];
}

sub properties {
    unbless(copy(shift));
}

sub persistant_properties {
    my ($properties, %options) = (shift->properties(), @_);

    delete $properties->{$_} for @{$options{runtime_properties}};

    $properties;
}

sub merge {
    my ($self, %options) = @_;

    my $errors = $self->validate(
        {
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

=encoding utf8

=head1 NAME

Navel::Base::Definition

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
