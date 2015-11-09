# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Definition::WebService;

use strict;
use warnings;

use parent qw/
    Navel::Base::Definition
/;

use Navel::Utils qw/
    isint
    exclusive_none
/;

use Mojo::URL;

our $VERSION = 0.1;

our %PROPERTIES;

#-> methods

sub new {
    shift->SUPER::new(
        definition => shift
    );
}

sub validate {
    my ($class, %options) = @_;

    $class->SUPER::validate(
        errors_callback => $options{errors_callback},
        parameters => $options{parameters},
        definition_class => __PACKAGE__,
        validator_struct => {
            name => 'word',
            interface_mask => 'text',
            port => 'port',
            tls => 'web_service_tls'
        },
        validator_types => {
            web_service_tls => sub {
                my $value = shift;

                $value == 0 or $value == 1 if isint($value);
            }
        },
        additional_validator => sub {
            if (exclusive_none([@{$PROPERTIES{persistant}}, @{$PROPERTIES{runtime}}], [keys %{$options{parameters}}])) {
                for (qw/ca cert ciphers key verify/) {
                    unless (exists $options{parameters}->{$_}) {
                        $options{errors_callback}->(__PACKAGE__, [$_ . ' key is missing']) if ref $options{errors_callback} eq 'CODE';

                        return 0;
                    }
                }

                return 1;
            } else {
                $options{errors_callback}->(__PACKAGE__, ['at least one unknown key has been detected']) if ref $options{errors_callback} eq 'CODE';
            }

            0;
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

sub url {
    my $self = shift;

    my $url = Mojo::URL->new()->scheme(
        'http' . ($self->{tls} ? 's' : '')
    )->host(
        $self->{interface_mask}
    )->port(
        $self->{port}
    );

    $url->query(ca => $self->{ca}) if defined $self->{ca};
    $url->query(cert => $self->{cert}) if defined $self->{cert};
    $url->query(ciphers => $self->{ciphers}) if defined $self->{ciphers};
    $url->query(key => $self->{key}) if defined $self->{key};
    $url->query(verify => $self->{verify}) if defined $self->{verify};

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

=head1 NAME

Navel::Definition::WebService

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
