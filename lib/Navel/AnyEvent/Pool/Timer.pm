# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::AnyEvent::Pool::Timer;

use strict;
use warnings;

use constant POOL_PACKAGE => 'Navel::AnyEvent::Pool';

use Carp 'croak';

use AnyEvent;

use Navel::Utils qw/
    isint
    blessed
/;

#-> methods

sub new {
    my ($class, %options) = @_;

    my $name = delete $options{name};
    my $callback = delete $options{callback};

    my %temp = (
        pool => delete $options{pool},
        enabled => delete $options{enabled},
        singleton => delete $options{singleton} || 0,
        on_disabled => delete $options{on_disabled},
        on_maximum_simultaneous_jobs => delete $options{on_maximum_simultaneous_jobs},
        on_singleton_already_running => delete $options{on_singleton_already_running}
    );

    my $self;

    if (ref $class) {
        $self = $class;

        $self->detach_pool() if blessed($temp{pool}) eq POOL_PACKAGE;

        while (my ($option_name, $option_value) = each %temp) {
            $self->{$option_name} = $option_value if defined $option_value;
        }
    } else {
        croak('callback must a CODE reference') unless ref $callback eq 'CODE';

        $self = bless {
            name => defined $name ? $name : croak('a name must be provided to add a timer'),
            pool => $temp{pool},
            enabled => defined $temp{enabled} ? $temp{enabled} : 1,
            singleton => $temp{singleton},
            running => 0,
            on_disabled => $temp{on_disabled},
            on_maximum_simultaneous_jobs => $temp{on_maximum_simultaneous_jobs},
            on_singleton_already_running => $temp{on_singleton_already_running},
        }, $class;

        my $wrapped_callback = sub {
            unless ($self->is_pooled() && $self->{pool}->{maximum_simultaneous_jobs} && @{$self->{pool}->jobs_running()} >= $self->{pool}->{maximum_simultaneous_jobs}) {
                $callback->($self);
            } else {
                $self->{on_maximum_simultaneous_jobs}->($self->{name}) if ref $self->{on_disabled} eq 'CODE';
            }
        };

        $self->{callback} = sub {
            if ($self->{enabled}) {
                if ($self->{singleton}) {
                    unless ($self->{running}) {
                        $wrapped_callback->();
                    } else {
                        $self->{on_singleton_already_running}->($self->{name}) if ref $self->{on_singleton_already_running} eq 'CODE';
                    }
                } else {
                    $wrapped_callback->();
                }
            } else {
                $self->{on_disabled}->($self->{name}) if ref $self->{on_disabled} eq 'CODE';
            }
        };
    }

    $self->{after} = delete $options{after};

    my $splay_limit = delete $options{splay_limit};

    unless (isint($self->{after})) {
        $self->{after} = $self->best_delay(
            defined $splay_limit ? $splay_limit : $self->{pool}->{splay_limit}
        );
    }

    $self->{anyevent_timer} = AnyEvent->timer(
        (
            %options,
            (
                cb => $self->{callback},
                after => $self->{after}
            )
        )
    );

    $self;
}

sub best_delay {
    my ($self, $splay_limit) = @_;

    croak('if defined, splay_limit must be an integer') if defined $splay_limit && ! isint($splay_limit);

    my $after = 0;

    if ($self->is_pooled()) {
        if ($splay_limit && (my @timers = @{$self->{pool}->timers()})) {
            my (%after_map, %limited_after_map);

            $after_map{$_->{after}}++ for @timers;

            $limited_after_map{$_} = $after_map{$_} || 0 for 0..$splay_limit;

            $after = [
                sort {
                    $limited_after_map{$a} <=> $limited_after_map{$b}
                } keys %limited_after_map
            ]->[0];
        }
    }

    $after;
}

sub detach_pool {
    my $self = shift;

    my $detached;

    if ($self->is_pooled()) {
        $detached = delete $self->{pool}->{jobs}->{timers}->{$self->{name}};

        undef $self->{pool};
    }

    $detached;
}

sub is_pooled {
    blessed(shift->{pool}) eq POOL_PACKAGE;
}

sub begin {
    shift->{running}++;
}

sub end {
    shift->{running}--;
}

sub exec {
    shift->{callback}->();
}

# sub AUTOLOAD {}

sub DESTROY {
    my $self = shift;

    $self->detach_pool();

    undef $self->{anyevent_timer};

    1;
}

1;

#-> END

__END__

=pod

=head1 NAME

Navel::AnyEvent::Pool::Timer

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
