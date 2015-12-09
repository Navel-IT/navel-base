# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Logger::Severity;

use strict;
use warnings;

use parent 'Navel::Base';

use Carp 'croak';

our $VERSION = 0.1;

#-> class variables

my %severities = (
    emerg => {
        priority => 0,
        color => 'magenta'
    },
    alert => {
        priority => 1,
        color => 'red'
    },
    crit => {
        priority => 2,
        color => 'red'
    },
    error => {
        priority => 3,
        color => 'red'
    },
    warning => {
        priority => 4,
        color => 'yellow'
    },
    notice => {
        priority => 5,
        color => 'white'
    },
    info => {
        priority => 6,
        color => 'green'
    },
    debug => {
        priority => 7,
        color => 'cyan'
    }
);

#-> methods

sub new {
    my ($class, $severity) = @_;

    croak('severity must be defined') unless defined $severity;

    $severity = lc $severity;

    croak('severity is invalid') unless exists $severities{$severity};

    bless {
        severity => $severity
    }, ref $class || $class;
}

sub does_it_log {
    my ($self, $severity) = @_;

    defined $severity && exists $severities{$severity} && $severities{$self->{severity}}->{priority} >= $severities{$severity}->{priority};
}

sub color {
    my ($self, $severity) = @_;

    defined $severity && exists $severities{$severity} && $severities{$severity}->{color};
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=head1 NAME

Navel::Logger::Severity

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
