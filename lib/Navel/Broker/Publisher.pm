# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Broker::Publisher 0.1;

use Navel::Base;

use Navel::Event;
use Navel::Definition::Publisher;
use Navel::Utils qw/
    croak
    catch_warnings
    try_require_namespace
    blessed
/;

#-> functions

my $catch_warnings_wrapper = sub {
    my $callback = shift;

    catch_warnings(
        sub {
            die @_;
        },
        $callback
    );
};

#-> methods

sub new {
    my ($class, %options) = @_;

    croak('publisher definition is invalid') unless blessed($options{definition}) eq 'Navel::Definition::Publisher';

    my $self = bless {
        definition => $options{definition},
        net => undef,
        queue => []
    }, ref $class || $class;

    try_require_namespace($self->{definition}->{backend});

    $self->{seems_connectable} = $self->{definition}->seems_connectable();

    $self;
}

sub clear_queue {
    my $self = shift;

    undef @{$self->{queue}};

    $self;
}

sub auto_clean {
    my $self = shift;

    my @events;

    if ($self->{definition}->{auto_clean}) {
        my $difference = @{$self->{queue}} - $self->{definition}->{auto_clean} + 1;

        @events = splice @{$self->{queue}}, 0, $difference if $difference > 0;
    }

    \@events;
}

sub push_in_queue {
    my ($self, %options) = @_;

    croak('event_definition must be a HASH reference') unless ref $options{event_definition} eq 'HASH';

    $self->auto_clean();

    my $event = Navel::Event->new(%{$options{event_definition}});

    if (defined (my $status_method = delete $options{status_method})) {
        croak('unknown status method') unless $event->can($status_method);

        $event->$status_method();
    }

    push @{$self->{queue}}, $event;

    $self;
}

sub publish {
    my ($self, %options) = @_;

    $catch_warnings_wrapper->(
        sub {
            $self->{definition}->{backend}->publish(
                %{
                    {
                        %options,
                        %{
                            {
                                backend_input => $self->{definition}->{backend_input},
                                net => $self->{net}
                            }
                        }
                    }
                }
            );
        }
    );
}

sub connect {
    my ($self, %options) = @_;

    if ($self->{seems_connectable}) {
        $self->{net} = $catch_warnings_wrapper->(
            sub {
                $self->{definition}->{backend}->connect(
                    %{
                        {
                            %options,
                            %{
                                {
                                    backend_input => $self->{definition}->{backend_input}
                                }
                            }
                        }
                    }
                );
            }
        );
    }
}

sub disconnect {
    my ($self, %options) = @_;

    if ($self->{seems_connectable}) {
        local $@;

        $catch_warnings_wrapper->(
            sub {
                eval {
                    $self->{definition}->{backend}->disconnect(
                        %{
                            {
                                %options,
                                %{
                                    {
                                        backend_input => $self->{definition}->{backend_input},
                                        net => $self->{net}
                                    }
                                }
                            }
                        }
                    );
                };
            }
        );

        undef $self->{net};

        die $@ if $@;
    }
}

BEGIN {
    no strict 'refs';

    for my $is_method (qw/
        is_connected
        is_connecting
        is_disconnected
        is_disconnecting
    /) {
        *{__PACKAGE__ . '::' . $is_method} = sub {
            my $self = shift;

            if ($self->{seems_connectable}) {
                catch_warnings(
                    sub {
                    },
                    sub {
                        eval {
                            $self->{definition}->{backend}->$is_method(
                                backend_input => $self->{definition}->{backend_input},
                                net => $self->{net}
                            );
                        };
                    }
                );
            }
        };
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

Navel::Broker::Publisher

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
