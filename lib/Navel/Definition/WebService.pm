# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Definition::WebService 0.1;

use Navel::Base;

use parent 'Navel::Base::Definition';

use Carp 'croak';

use Navel::Utils 'exclusive_none';

use Mojo::URL;

our %PROPERTIES;

#-> methods

sub validate {
    my ($class, %options) = @_;

    croak('parameters must be a HASH reference') unless ref $options{parameters} eq 'HASH';

    $class->SUPER::validate(
        parameters => $options{parameters},
        definition_class => __PACKAGE__,
        if_possible_suffix_errors_with_key_value => 'name',
        validator_struct => {
            name => 'word',
            interface_mask => 'text',
            port => 'port',
            tls => 'webservice_0_or_1'
        },
        validator_types => {
            webservice_0_or_1 => qr/^[01]$/
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
                    ca
                    cert
                    ciphers
                    key
                    verify
                /) {
                    push @errors, 'required key ' . $_ . ' is missing' unless exists $options{parameters}->{$_};
                }
            }

            \@errors;
        }
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
        runtime_properties => $PROPERTIES{runtime}
    );
}

sub url {
    my $self = shift;

    my $url = Mojo::URL->new()->scheme(
        'http' . ($self->{tls} ? 's' : '')
    )->host(
        $self->{interface_mask}
    )->port(
        $self->{port}
    );

    for (qw/
        ca
        cert
        ciphers
        key
        verify
    /) {
        $url->query(
            $_ => $self->{$_}
        ) if defined $self->{$_};
    }

    $url;
}

BEGIN {
    %PROPERTIES = (
        persistant => [qw/
            name
            interface_mask
            port
            tls
            ca
            cert
            ciphers
            key
            verify
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

Navel::Definition::WebService

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
