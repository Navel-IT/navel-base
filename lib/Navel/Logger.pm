# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Logger;

use strict;
use warnings;

use feature 'say';

use parent 'Navel::Base';

use constant {
    GOOD_MESSAGE => 'Sounds perfect',
    BAD_MESSAGE => "Something going wrong around here",
    GOOD_COLOR => 'green',
    BAD_COLOR => 'red'
};

use File::Slurp;

use AnyEvent::IO;

use Term::ANSIColor;

use Navel::Logger::Severity;
use Navel::Utils qw/
    flatten
    human_readable_localtime
/;

our $VERSION = 0.1;

#-> globals

binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

#-> functions

sub stepped_log {
    my $stepped_log;

    for (@_) {
        if (ref $_ eq 'ARRAY') {
            if (@{$_}) {
                my %new_step_shift = (
                    character => ' ',
                    value => 4
                );

                $stepped_log = "\n" . join "\n", map {
                    ($new_step_shift{character} x $new_step_shift{value}) . $_
                } flatten($_);
            }
        } else {
            $stepped_log = $_;
        }

        chomp $stepped_log;
    }

    $stepped_log;
}

#-> methods

sub new {
    my ($class, %options) = @_;

    bless {
        severity => Navel::Logger::Severity->new(lc $options{severity}),
        file_path => $options{file_path},
        queue => []
    }, ref $class || $class;
}

sub push_in_queue {
    my ($self, %options) = @_;

    push @{$self->{queue}}, {
        time => time,
        severity => $options{severity},
        message => stepped_log($options{message}),
        message_color => $options{message_color},
    } if defined $options{message} && $self->{severity}->does_it_log(
        severity => $options{severity}
    );

    $self;
}

sub good {
    my ($self, %options) = @_;

    $options{message} = GOOD_MESSAGE . ' - ' . stepped_log($options{message});
    $options{message_color} = GOOD_COLOR;

    $self->push_in_queue(%options);
}

sub bad {
    my ($self, %options) = @_;

    $options{message} = BAD_MESSAGE . ' - ' . stepped_log($options{message});
    $options{message_color} = BAD_COLOR;

    $self->push_in_queue(%options);
}

sub queue_to_text {
    my ($self, %options) = @_;

    [
        map {
            my $message = '[' . human_readable_localtime($_->{time}) . '] ' . uc($_->{severity}) . ' - ' . $_->{message};

            $options{colored} && defined $_->{message_color} ? colored($message, $_->{message_color}) : $message;
        } @{$self->{queue}}
    ];
}

sub clear_queue {
    my $self = shift;

    undef @{$self->{queue}};

    $self;
}

sub say_queue {
    my $self = shift;

    if (@{$self->{queue}}) {
        say join "\n", @{$self->queue_to_text(
            colored => 1
        )};
    }

    $self;
}

sub flush_queue {
    my ($self, %options) = @_;

    if (@{$self->{queue}}) {
        if (defined $self->{file_path}) {
            my $queue_to_text = $self->queue_to_text();

            if ($options{async}) {
                aio_open($self->{file_path}, AnyEvent::IO::O_CREAT | AnyEvent::IO::O_WRONLY | AnyEvent::IO::O_APPEND, 0, sub {
                    my $filehandle = shift;

                    if ($filehandle) {
                        aio_write($filehandle, join("\n", @{$queue_to_text}) . "\n", sub {
                            aio_close($filehandle,
                                sub {
                                }
                            );
                        });
                    } else {
                        $self->bad(
                            message => 'Cannot push messages into ' . $self->{file_path} . ': ' . $! . '.',
                            severity => 'err'
                        );

                        $self->say_queue();
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
                            map { $_ . "\n" } @{$queue_to_text}
                        ]
                    );
                };

                if ($@) {
                    $self->bad(
                        message => 'Cannot push messages into ' . $self->{file_path} . ': ' . $! . '.',
                        severity => 'err'
                    );

                    $self->say_queue();
                }
            }
        } else {
            $self->say_queue();
        }
    }

    $self->clear_queue();
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
