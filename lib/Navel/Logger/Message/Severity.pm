# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Logger::Message::Severity 0.1;

use Navel::Base;

use Navel::Utils qw/
    croak
    blessed
/;

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

sub severities {
    [
        keys %severities
    ];
}

sub new {
    my ($class, $label) = @_;

    croak('label must be defined') unless defined $label;

    $label = lc $label;

    croak('severity is invalid') unless exists $severities{$label};

    bless {
        label => $label
    }, ref $class || $class;
}

sub color {
    $severities{shift->{label}}->{color};
}

sub compare {
    my ($self, $severity) = @_;

    croak('severity must be of ' . __PACKAGE__ . ' class') unless blessed($severity) && $severity->isa(__PACKAGE__);

    $severities{$self->{label}}->{priority} >= $severities{$severity->{label}}->{priority};
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Logger::Message::Severity

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
