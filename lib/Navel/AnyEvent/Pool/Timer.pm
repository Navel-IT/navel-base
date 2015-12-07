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

    my $self = $class;

    my $name = delete $options{name};
    my $callback = delete $options{callback};

    my %temp = (
        pool => delete $options{pool},
        enable => delete $options{enable},
        singleton => delete $options{singleton} || 0,
        on_disabled => delete $options{on_disabled},
        on_maximum_simultaneous_jobs => delete $options{on_maximum_simultaneous_jobs},
        on_singleton_already_running => delete $options{on_singleton_already_running}
    );

    if (ref $class) {
        $self->detach_pool() if blessed $temp{pool} eq POOL_PACKAGE;

        while (my ($option_name, $option_value) = each %temp) {
            $self->{$option_name} = $option_value;
        }
    } else {
        croak('callback must a CODE reference') unless ref $callback eq 'CODE';

        $self = bless {
            name => defined $name ? $name : croak('a name must be provided to add a timer'),
            pool => $temp{pool},
            enable => defined $temp{enable} ? $temp{enable} : 1,
            singleton => $temp{singleton},
            running => 0,
            on_disabled => $temp{on_disabled},
            on_maximum_simultaneous_jobs => $temp{on_maximum_simultaneous_jobs},
            on_singleton_already_running => $temp{on_singleton_already_running},
        }, $class;

        my $wrapped_callback = sub {
            unless ($self->is_pooled() && $self->{pool}->{maximum_simultaneous_jobs} && $self->{pool}->jobs_running() >= $self->{pool}->{maximum_simultaneous_jobs}) {
                $self->{running} = 1;

                $callback->(@_);

                $self->{running} = 0;
            } else {
                $self->{on_maximum_simultaneous_jobs}->($self->{name}) if ref $self->{on_disabled} eq 'CODE';
            }
        };

        $self->{callback} = sub {
            if ($self->{enable}) {
                if ($self->{singleton}) {
                    unless ($self->{running}) {
                        $wrapped_callback->(@_);
                    } else {
                        $self->{on_singleton_already_running}->($self->{name}) if ref $self->{on_singleton_already_running} eq 'CODE';
                    }
                } else {
                    $wrapped_callback->(@_);
                }
            } else {
                $self->{on_disabled}->($self->{name}) if ref $self->{on_disabled} eq 'CODE';
            }
        };
    }

    $self->{after} = delete $options{after};

    my $splay_limit = delete $options{splay_limit};

    $self->{after} = $self->optimized_delay(
        defined $splay_limit ? $splay_limit : $self->{pool}->{splay_limit}
    ) if $self->is_pooled() && ! isint($self->{after});

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

sub optimized_delay {
    my ($self, $splay_limit) = @_;

    croak('if defined, splay_limit must be an integer') if defined $splay_limit && ! isint($splay_limit);

    my $after = 0;

    if ($self->is_pooled()) {
        if (my @timers = @{$self->{pool}->timers()}) {
            if ($splay_limit) {
                my (%after_map, %limited_after_map);

                $after_map{$_->{after}}++ for @timers;

                $limited_after_map{$_} = $after_map{$_} || 0 for 0..$splay_limit;

                $after = [
                    sort {
                        $limited_after_map{$a} <=> $limited_after_map{$b}
                    } keys %limited_after_map
                ]->[0];
            } else {
                $after = @timers + 1;
            }
        }
    }

    $after;
}

sub detach_pool {
    my $self = shift;

    if ($self->is_pooled()) {
        delete $self->{pool}->{timer}->{$self->{name}};

        undef $self->{pool};
    }

    $self;
}

sub exec {
    shift->{callback}->(@_);
}

sub is_pooled {
    blessed(shift->{pool}) eq POOL_PACKAGE;
}

# sub AUTOLOAD {}

# sub DESTROY {}

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
