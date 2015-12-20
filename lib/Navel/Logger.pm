# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Logger;

use strict;
use warnings;

use feature 'say';

use parent 'Navel::Base';

use Carp 'croak';

use File::Slurp;

use AnyEvent::IO;

use Term::ANSIColor;

use Navel::Logger::Severity;
use Navel::Utils qw/
    flatten
    strftime
/;

our $VERSION = 0.1;

#-> globals

binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

#-> methods

sub stepped_log {
    my $class = shift;

    my $stepped_log;

    for (@_) {
        $stepped_log .= "\n" if defined $stepped_log;

        if (ref eq 'ARRAY') {
            if (@{$_}) {
                my %new_step_shift = (
                    character => ' ',
                    value => 4
                );

                $stepped_log .= (defined $stepped_log ? '' : "\n") . join "\n", map {
                    ($new_step_shift{character} x $new_step_shift{value}) . $_
                } flatten($_);
            }
        } else {
            $stepped_log .= $_;
        }
    }

    chomp $stepped_log;

    $stepped_log;
}

sub new {
    my ($class, %options) = @_;

    bless {
        severity => Navel::Logger::Severity->new($options{severity}),
        file_path => $options{file_path},
        colored => defined $options{colored} ? $options{colored} : 1,
        datetime_format => $options{datetime_format},
        show_severity => defined $options{show_severity} ? $options{show_severity} : 1,
        queue => []
    }, ref $class || $class;
}

sub push_in_queue {
    my ($self, %options) = @_;

    croak('message must be defined') unless defined $options{message};

    push @{$self->{queue}}, {
        time => time,
        severity => $options{severity},
        message => $options{message}
    } if $self->{severity}->does_it_log($options{severity});

    $self;
}

sub format_queue {
    my $self = shift;

    my @formatted_queue;

    if (my @queue = @{$self->{queue}}) {
        my $colored = defined $self->{file_path} ? 0 : $self->{colored};

        @formatted_queue = map {
            my $message = (defined $self->{datetime_format} && length $self->{datetime_format} ? '[' . strftime($self->{datetime_format}, localtime $_->{time}) . '] ' : '') . ($self->{show_severity} ? ucfirst($_->{severity}) . ': ' : '') . $_->{message};

            $colored ? colored($message, $self->{severity}->color($_->{severity})) : $message;
        } @queue;
    }

    \@formatted_queue;
}

sub clear_queue {
    my $self = shift;

    undef @{$self->{queue}};

    $self;
}

sub say_queue {
    my $self = shift;

    say join "\n", @{$self->format_queue()};

    $self;
}

sub flush_queue {
    my ($self, %options) = @_;

    if (@{$self->{queue}}) {
        if (defined $self->{file_path}) {
            my $queue_to_text = $self->format_queue();

            if ($options{async}) {
                aio_open($self->{file_path}, AnyEvent::IO::O_CREAT | AnyEvent::IO::O_WRONLY | AnyEvent::IO::O_APPEND, 0, sub {
                    my $filehandle = shift;

                    if ($filehandle) {
                        aio_write($filehandle, (join "\n", @{$queue_to_text}) . "\n", sub {
                            aio_close($filehandle,
                                sub {
                                }
                            );
                        });
                    } else {
                        $self->crit('cannot push messages into ' . $self->{file_path} . ': ' . $! . '.')->say_queue();
                    }
                });
            } else {
                eval {
                    append_file(
                        $self->{file_path},
                        {
                            binmode => ':utf8'
                        },
                        [
                            map {
                                $_ . "\n"
                            } @{$queue_to_text}
                        ]
                    );
                };

                if ($@) {
                    $self->crit('cannot push messages into ' . $self->{file_path} . ': ' . $! . '.')->say_queue();
                }
            }
        } else {
            $self->say_queue();
        }

        $self->clear_queue();
    }
}

BEGIN {
    no strict 'refs';

    for my $severity (@{Navel::Logger::Severity->severities()}) {
        *{__PACKAGE__ . '::' . $severity} = sub {
            shift->push_in_queue(
                message => shift,
                severity => $severity
            );
        };
    }
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=head1 NAME

Navel::Logger

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
