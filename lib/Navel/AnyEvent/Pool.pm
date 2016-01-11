# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::AnyEvent::Pool 0.1;

use strict;
use warnings;

use parent 'Navel::Base';

use constant {
    TIMER_BACKEND_PACKAGE => 'Navel::AnyEvent::Pool::Timer'
};

use Carp 'croak';

use Navel::AnyEvent::Pool::Timer;

use Navel::Utils 'blessed';

#-> methods

sub new {
    my ($class, %options) = @_;

    my $self = {
        logger => blessed($options{logger}) eq 'Navel::Logger' ? $options{logger} : undef,
        splay_limit => $options{splay_limit},
        maximum => $options{maximum} || 0,
        maximum_simultaneous_jobs => $options{maximum_simultaneous_jobs} || 0,
        jobs => {
            timers => {}
        },
        on_callbacks => {}
    };

    if (defined $self->{logger}) {
        $self->{on_callbacks}->{on_disabled} = sub {
            $self->{logger}->info('job ' . shift() . ' is disabled.');
        };

        $self->{on_callbacks}->{on_maximum_simultaneous_jobs} = sub {
            $self->{logger}->warning('Cannot start job ' . shift() . ': there are too many jobs running (maximum of ' . $self->{maximum_simultaneous_jobs} . ').');
        };

        $self->{on_callbacks}->{on_singleton_already_running} = sub {
            $self->{logger}->warning('job ' . shift() . ' is already running.');
        };
    }

    bless $self, ref $class || $class;
}

sub attach_timer {
    my ($self, %options) = @_;

    my $timer = delete $options{timer};

    my $package = TIMER_BACKEND_PACKAGE;

    if (blessed($timer) eq TIMER_BACKEND_PACKAGE) {
        $options{name} = $timer->{name};

        $package = $timer;
    }

    croak('a name must be provided to add a timer') unless defined $options{name};

    croak('a timer named ' . $options{name} . ' already exists') if exists $self->{jobs}->{timers}->{$options{name}};
    croak('too many jobs already registered (maximum of ' . $self->{maximum} . ')') if $self->{maximum} && @{$self->jobs()} >= $self->{maximum};

    $self->{jobs}->{timers}->{$options{name}} = $package->new(
        (
            %{
                $self->{on_callbacks}
            },
            %options,
            (
                pool => $self
            )
        )
    );
}

sub detach_timer {
    my ($self, $name) = @_;

    croak('a name must be provided to detach a timer') unless defined $name;

    my $timer = $self->{jobs}->{timers}->{$name};

    $timer->detach_pool() if defined $timer;

    $timer;
}

sub timers {
    [
        grep {
            $_->isa(TIMER_BACKEND_PACKAGE)
        } @{shift->jobs()}
    ];
}

sub jobs {
    [
        map {
            values %{$_}
        } values %{shift->{jobs}}
    ];
}

sub jobs_running {
    [
        grep {
            $_->{running}
        } @{shift->jobs()}
    ];
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::AnyEvent::Pool

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut


