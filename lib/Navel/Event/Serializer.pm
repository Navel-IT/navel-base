# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Event::Serializer 0.1;

use Navel::Base;

use Navel::Event;
use Navel::Definition::Collector;
use Navel::Utils qw/
    :scalar
    :sereal
    croak
    isint
/;

#-> functions

sub to {
    my %options = @_;

    croak('status must be of Navel::Event::Status class') unless blessed($options{status}) && $options{status}->isa('Navel::Event::Status');

    croak('starting_time is invalid') unless isint($options{starting_time});
    croak('ending_time is invalid') unless isint($options{ending_time});

    $options{collector} = unbless(
        clone($options{collector})
    ) if blessed($options{collector}) && $options{collector}->isa('Navel::Definition::Collector');

    encode_sereal_constructor()->encode(
        {
            collector => $options{collector},
            collection => defined $options{collection} ? sprintf '%s', $options{collection} : $options{collection},
            status => $options{status}->{status},
            starting_time => $options{starting_time},
            ending_time => $options{ending_time},
            data => $options{data}
        }
    );
}

sub from {
    my $deserialized = decode_sereal_constructor()->decode(shift);

    local $@;

    my $event;

    eval {
        $deserialized->{collector} = Navel::Definition::Collector->new($deserialized->{collector});

        $event = Navel::Event->new(
            (
                %{$deserialized},
                (
                    status => $deserialized->{status}
                )
            )
        );
    };

    croak($@) if $@;

    $event;
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Event::Serializer

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
