# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Event::Serializer 0.1;

use Navel::Base;

use Navel::Event;
use Navel::Definition::Collector;
use Navel::Utils qw/
    blessed
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

        $event = Navel::Event->new(%{$deserialized});
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

=head1 COPYRIGHT

Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-base is licensed under the Apache License, Version 2.0

=cut