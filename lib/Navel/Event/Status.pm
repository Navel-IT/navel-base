# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Event::Status 0.1;

use Navel::Base;

use Navel::Utils qw/
    croak
    isint
 /;

#-> class variables

my %status = (
    OK => {
        private => 0,
        value => 1
    },
    KO => {
        private => 0,
        value => -1
    },
    __KO => {
        private => 1,
        value => -2
    }
);

#-> methods

sub status {
    [
        keys %status
    ];
}

sub integer_to_status_key {
    my ($class, $integer) = @_;

    croak('status must be an integer') unless isint($integer);

    my $status;

    for (keys %status) {
        if ($integer == $status{$_}->{value}) {
            $status = $_;

            last;
        }
    }

    $status;
}

sub new {
    my ($class, %options) = @_;

    my $self = bless {}, ref $class || $class;

    $self->set_status(
        status => $options{status},
        public_interface => $options{public_interface}
    );

    $self;
}

sub set_status {
    my ($self, %options) = @_;

    my $status;

    if (isint($options{status})) {
        $status = $self->integer_to_status_key($options{status});

        die "invalid status\n" unless defined $status;
    } else {
        die "invalid status\n" unless defined $options{status} && exists $status{$options{status}};

        $status = $options{status};
    }

    die "this status is private\n" if $options{public_interface} && $status{$status}->{private};

    $self->{status} = $status{$status}->{value};

    $self;
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Event::Status

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
