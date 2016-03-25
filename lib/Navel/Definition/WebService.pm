# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Definition::WebService 0.1;

use Navel::Base;

use parent 'Navel::Base::Definition';

use Mojo::URL;

our %PROPERTIES;

#-> methods

sub validate {
    my ($class, $raw_definition) = @_;

    $class->SUPER::validate(
        definition_class => __PACKAGE__,
        validator => {
            type => 'object',
            additionalProperties => 0,
            required => [
                @{$PROPERTIES{persistant}},
                @{$PROPERTIES{runtime}}
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
                interface_mask => {
                    type => [
                        qw/
                            string
                            integer
                            number
                        /
                    ]
                },
                port => {
                    type => 'integer',
                    minimum => 0,
                    maximum => 65535
                },
                tls => {
                    type => [
                        qw/
                            integer
                            boolean
                        /
                    ],
                    minimum => 0,
                    maximum => 1
                },
                ca => {
                    type => [
                        qw/
                            null
                            string
                            integer
                            number
                        /
                    ]
                },
                cert => {
                    type => [
                        qw/
                            null
                            string
                            integer
                            number
                        /
                    ]
                },
                ciphers => {
                    type => [
                        qw/
                            null
                            string
                            integer
                            number
                        /
                    ]
                },
                key => {
                    type => [
                        qw/
                            null
                            string
                            integer
                            number
                        /
                    ]
                },
                verify => {
                    type => [
                        qw/
                            null
                            string
                            integer
                            number
                        /
                    ]
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
        $url->query()->merge(
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
