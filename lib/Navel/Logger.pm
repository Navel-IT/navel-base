# Copyright 2015 Navel-IT
# Navel Scheduler is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Logger;

use strict;
use warnings;

use feature 'say';

use parent 'Navel::Base';

use constant {
    GOOD => ':)',
    BAD => ':('
};

use File::Slurp 'append_file';

use Navel::Logger::Severity;
use Navel::Utils qw/
    human_readable_localtime
    crunch
/;

our $VERSION = 0.1;

#-> globals

binmode STDOUT, ':utf8';

binmode STDERR, ':utf8';

#-> methods

sub new {
    my ($class, $default_severity, $severity, $file_path) = @_;

    bless {
        severity => eval {
            Navel::Logger::Severity->new($severity)
        } || Navel::Logger::Severity->new($default_severity),
        file_path => $file_path,
        queue => []
    }, ref $class || $class;
}

sub push_in_queue {
    my ($self, $message, $severity) = @_;

    push @{$self->{queue}}, '[' . human_readable_localtime(time) . '] [' . $severity . '] ' . crunch($message) if defined $messages && $self->{severity}->does_it_log($severity);

    $self;
}

sub good {
    shift->push_in_queue(GOOD . ' ' . shift, shift);
}

sub bad {
    shift->push_in_queue(BAD . ' ' . shift, shift);
}

sub clear_queue {
    my $self = shift;

    undef @{$self->{queue}};

    $self;
}

sub flush_queue {
    my ($self, $clear_queue) = @_;

    if (@{$self->{queue}}) {
        if (defined $self->{file_path}) {
            eval {
                append_file(
                    $self->{file_path},
                    {
                        binmode => ':utf8'
                    },
                    [
                        map { $_ . "\n" } @{$self->{queue}}
                    ]
                );
            };
        } else {
            say join "\n", @{$self->{queue}};;
        }
    }

    $clear_queue ? $self->clear_queue() : $self;
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
