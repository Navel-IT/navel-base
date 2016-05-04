# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Event 0.1;

use Navel::Base;

use Navel::Event::Serializer;
use Navel::Event::Status;
use Navel::Utils qw/
    blessed
    isint
 /;

#-> methods

sub deserialize {
    my $class = shift;

    Navel::Event::Serializer::from(@_);
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
        $self->{collection} = $options{collection};
    }

    $self->{status} = Navel::Event::Status->new(
        status => $options{status},
        public_interface => $options{public_interface}
    );

    $self->{data} = $options{data};

    $self->{$_} = isint($options{$_}) ? $options{$_} : time for qw/
        starting_time
        ending_time
    /;

    $self;
}

sub serialize {
    my $self = shift;

    Navel::Event::Serializer::to(
        collection => $self->{collection},
        collector => $self->{collector},
        status => $self->{status},
        starting_time => $self->{starting_time},
        ending_time => $self->{ending_time},
        data => $self->{data}
    );
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
