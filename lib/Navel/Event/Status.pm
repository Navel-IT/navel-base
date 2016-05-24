# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

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
    std => 0,
    itl => -1
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
        if ($integer == $status{$_}) {
            $status = $_;

            last;
        }
    }

    $status;
}

sub new {
    my ($class, $status) = @_;

    my $self = bless {}, ref $class || $class;

    $self->set_status(defined $status ? $status : $status{std});

    $self;
}

sub set_status {
    my ($self, $status) = @_;

    if (isint($status)) {
        $status = $self->integer_to_status_key($status);

        die "invalid status\n" unless defined $status;
    } else {
        die "invalid status\n" unless defined $status && exists $status{$status};
    }

    $self->{status} = $status{$status};

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

=head1 COPYRIGHT

Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-base is licensed under the Apache License, Version 2.0

=cut
