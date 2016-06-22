# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Event 0.1;

use Navel::Base;

use Navel::Definition::Collector;
use Navel::Event::Status;
use Navel::Utils qw/
    croak
    :sereal
    blessed
    isint
 /;
 
#-> class variables

my $decode_sereal_constructor = decode_sereal_constructor();

my $encode_sereal_constructor = encode_sereal_constructor();

#-> methods

sub deserialize {
    my ($class, $deserialized) = (shift, $decode_sereal_constructor->decode(shift));

    return $deserialized if blessed($deserialized) && $deserialized->isa(__PACKAGE__);

    local $@;

    eval {
        $deserialized->{collector} = Navel::Definition::Collector->new($deserialized->{collector});
    };

    my $event = eval {
        $class->new(%{$deserialized});
    };

    croak($@) if $@;

    $event;
}

sub new {
    my ($class, %options) = @_;

    my $self = bless {
    }, ref $class || $class;

    if (blessed($options{collector}) && $options{collector}->isa('Navel::Definition::Collector')) {
        $self->{collector} = $options{collector};
        $self->{collection} = $self->{collector}->{collection};
    } else {
        die "collection must be defined\n" unless defined $options{collection};

        $self->{collector} = undef;
        $self->{collection} = sprintf '%s', $options{collection};
    }

    $self->{status} = blessed($options{status}) && $options{status}->isa('Navel::Event::Status') ? $options{status} : Navel::Event::Status->new($options{status});

    $self->{data} = $options{data};

    $self->{time} = isint($options{time}) ? $options{time} : time;

    $self;
}

sub serialize {
    $encode_sereal_constructor->encode(shift);
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Event

=head1 COPYRIGHT

Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-base is licensed under the Apache License, Version 2.0

=cut
