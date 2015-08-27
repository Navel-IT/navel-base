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
    my ($class, %options) = @_;

    bless {
        severity => eval {
            Navel::Logger::Severity->new($options{severity})
        } || Navel::Logger::Severity->new($options{default_severity}),
        file_path => $options{default_severity},
        queue => []
    }, ref $class || $class;
}

sub push_in_queue {
    my ($self, %options) = @_;

    $options{message} = crunch($options{message});

    push @{$self->{queue}}, '[' . human_readable_localtime(time) . '] [' . $options{severity} . '] ' . $options{message} if defined $options{message} && $self->{severity}->does_it_log(
        severity => $options{severity}
    );

    $self;
}

sub good {
    my ($self, %options) = @_;

    $options{message} = GOOD . ' ' . $options{message};

    $self->push_in_queue(%options);
}

sub bad {
    my ($self, %options) = @_;

    $options{message} = BAD . ' ' . $options{message};

    $self->push_in_queue(%options);
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

    $options{clear_queue} ? $self->clear_queue() : $self;
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
