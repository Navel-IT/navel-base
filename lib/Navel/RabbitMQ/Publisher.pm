# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::RabbitMQ::Publisher;

use strict;
use warnings;

use parent 'Navel::Base';

use AnyEvent::RabbitMQ 1.19;

use Navel::RabbitMQ::Publisher::Event;
use Navel::Utils 'blessed';

our $VERSION = 0.1;

#-> methods

sub new {
    my ($class, %options) = @_;

    bless {
        definition => $options{rabbitmq_definition},
        net => undef,
        queue => []
    }, ref $class || $class;
}

sub connect {
    my ($self, %options) = @_;

    $self->{net} = AnyEvent::RabbitMQ->new()->load_xml_spec()->connect(
        host => $self->{definition}->{host},
        port => $self->{definition}->{port},
        user => $self->{definition}->{user},
        pass => $self->{definition}->{password},
        vhost => $self->{definition}->{vhost},
        timeout => $self->{definition}->{timeout},
        tls => $self->{definition}->{tls},
        tune => {
            heartbeat => $self->{definition}->{heartbeat}
        },
        on_success => $options{on_success},
        on_failure => $options{on_failure},
        on_read_failure => $options{on_read_failure},
        on_return => $options{on_return},
        on_close => $options{on_close}
    );

    $self;
}

sub disconnect {
    my $self = shift;

    undef $self->{net};

    $self;
}

sub is_connected {
    my $self = shift;

    blessed($self->{net}) eq 'AnyEvent::RabbitMQ' && $self->{net}->is_open();
}

sub is_connecting {
    my $self = shift;

    blessed($self->{net}) eq 'AnyEvent::RabbitMQ' && $self->{net}->{_state} == AnyEvent::RabbitMQ::_ST_OPENING; # Warning, may change
}

sub is_disconnecting {
    my $self = shift;

    blessed($self->{net}) eq 'AnyEvent::RabbitMQ' && $self->{net}->{_state} == AnyEvent::RabbitMQ::_ST_CLOSING; # Warning, may change
}

sub clear_queue {
    my $self = shift;

    undef @{$self->{queue}};

    $self;
}

sub push_in_queue {
    my ($self, %options) = @_;

    my $event = Navel::RabbitMQ::Publisher::Event->new(%{$options{event_definition}});

    $event->($options{status_method})() if defined $options{status_method};

    push @{$self->{queue}}, $event;

    $self;
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=head1 NAME

Navel::RabbitMQ::Publisher

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
