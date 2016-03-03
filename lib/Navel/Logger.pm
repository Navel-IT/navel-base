# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Logger 0.1;

use Navel::Base;

use AnyEvent::IO;

use Navel::Logger::Message;
use Navel::Logger::Message::Severity;
use Navel::Utils qw/
    croak
    append_file
/;

#-> globals

binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

#-> methods

sub new {
    my ($class, %options) = @_;

    bless {
        datetime_format => $options{datetime_format},
        service => $options{service},
        service_pid => $options{service_pid} || $$,
        severity => Navel::Logger::Message::Severity->new($options{severity}),
        colored => defined $options{colored} ? $options{colored} : 1,
        file_path => $options{file_path},
        queue => []
    }, ref $class || $class;
}

sub push_in_queue {
    my ($self, %options) = @_;

    my $message = Navel::Logger::Message->new(
        (
            %options,
            (
                time => time,
                datetime_format => $self->{datetime_format},
                service => $self->{service},
                service_pid => $self->{service_pid}
            )
        )
    );

    push @{$self->{queue}}, $message if $self->{severity}->compare($message->{severity});

    $self;
}

sub format_queue {
    my ($self, %options) = @_;

    my @formatted_queue;

    if (my @queue = @{$self->{queue}}) {
        my $colored;

        if (exists $options{colored}) {
            $colored = delete $options{colored};
        } else {
            $colored = defined $self->{file_path} ? 0 : $self->{colored};
        }

        @formatted_queue = map {
            $_->to_string($colored);
        } @queue;
    }

    \@formatted_queue;
}

sub say_queue {
    my ($self, %options) = @_;

    say join "\n", @{$self->format_queue(%options)};

    $self;
}

sub clear_queue {
    my $self = shift;

    undef @{$self->{queue}};

    $self;
}

sub flush_queue {
    my ($self, %options) = @_;

    if (@{$self->{queue}}) {
        if (defined $self->{file_path}) {
            my $cannot_push_messages = 'cannot push messages into ' . $self->{file_path};

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
                        $self->crit($cannot_push_messages . ': ' . $! . '.')->say_queue(
                            colored => $self->{colored}
                        );
                    }
                });
            } else {
                local $@;

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
                    $self->crit($cannot_push_messages . ': ' . $! . '.')->say_queue(
                        colored => $self->{colored}
                    );
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

    for my $severity (@{Navel::Logger::Message::Severity->severities()}) {
        *{__PACKAGE__ . '::' . $severity} = sub {
            shift->push_in_queue(
                text => shift,
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

=encoding utf8

=head1 NAME

Navel::Logger

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
