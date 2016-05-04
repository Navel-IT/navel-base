# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Logger 0.1;

use Navel::Base;

use AnyEvent::IO;

use Term::ANSIColor 'colored';

use Sys::Syslog 'syslog';

use Navel::Logger::Message;
use Navel::Logger::Message::Facility::Local;
use Navel::Logger::Message::Severity;
use Navel::Utils qw/
    blessed
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
        hostname => $options{hostname},
        service => $options{service},
        service_pid => $options{service_pid} || $$,
        facility => Navel::Logger::Message::Facility::Local->new($options{facility}),
        severity => Navel::Logger::Message::Severity->new($options{severity}),
        colored => defined $options{colored} ? $options{colored} : 1,
        syslog => $options{syslog} || 0,
        file_path => $options{file_path},
        queue => []
    }, ref $class || $class;
}

sub queue {
    my $self = shift;

    [
        grep {
            $self->{severity}->compare($_->{severity});
        } @{$self->{queue}}
    ];
}

sub queue_to_string {
    my ($self, %options) = @_;

    my $colored = exists $options{colored} ? $options{colored} : $self->{colored};

    [
        map {
            $colored ? colored($_->to_string(), $_->{severity}->color()) : $_->to_string();
        } @{$self->queue()}
    ];
}

sub queue_to_syslog {
    my $self = shift;

    [
        map {
            $_->to_syslog();
        } @{$self->queue()}
    ];
}

sub say_queue {
    my ($self, %options) = @_;

    my $queue_to_string = $self->queue_to_string(%options);

    say join "\n", @{$queue_to_string} if @{$queue_to_string};

    $self;
}

sub push_in_queue {
    my ($self, %options) = @_;

    my $message;

    if (blessed($options{message})) {
        croak('message must be of Navel::Logger::Message class') unless $options{message}->isa('Navel::Logger::Message');

        $message = $options{message};
    } else {
        $message = Navel::Logger::Message->new(
            (
                %options,
                (
                    time => time,
                    datetime_format => $self->{datetime_format},
                    hostname => $self->{hostname},
                    service => $self->{service},
                    service_pid => $self->{service_pid},
                    facility => $self->{facility}->{label}
                )
            )
        );
    }

    push @{$self->{queue}}, $message;

    $self;
}

sub clear_queue {
    my $self = shift;

    undef @{$self->{queue}};

    $self;
}

sub flush_queue {
    my ($self, %options) = @_;

    if ($self->{syslog}) {
        local $@;

        for (@{$self->queue_to_syslog()}) {
            eval {
                syslog(@{$_});
            };

            if ($@) {
                $self->crit(
                    Navel::Logger::Message->stepped_message('cannot push messages into syslog.',
                        [
                            $@
                        ]
                    )
                )->say_queue();
            }
        }
    } elsif (defined $self->{file_path}) {
        my $cannot_push_messages = 'cannot push messages into ' . $self->{file_path};

        my $queue_to_string = $self->queue_to_string(
            colored => 0
        );

        if (@{$queue_to_string}) {
            if ($options{async}) {
                aio_open($self->{file_path}, AnyEvent::IO::O_CREAT | AnyEvent::IO::O_WRONLY | AnyEvent::IO::O_APPEND, 0, sub {
                    my $filehandle = shift;

                    if ($filehandle) {
                        aio_write($filehandle, (join "\n", @{$queue_to_string}) . "\n", sub {
                            aio_close($filehandle,
                                sub {
                                }
                            );
                        });
                    } else {
                        $self->crit(
                            Navel::Logger::Message->stepped_message($cannot_push_messages . '.',
                                [
                                    $!
                                ]
                            )
                        )->say_queue();
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
                            } @{$queue_to_string}
                        ]
                    );
                };

                if ($@) {
                    $self->crit(
                        Navel::Logger::Message->stepped_message($cannot_push_messages . '.',
                            [
                                $!
                            ]
                        )
                    )->say_queue();
                }
            }
        }
    } else {
        $self->say_queue();
    }

    $self->clear_queue();
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

=head1 COPYRIGHT

Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-base is licensed under the Apache License, Version 2.0

=cut
