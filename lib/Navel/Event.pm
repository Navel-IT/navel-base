# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Event 0.1;

use Navel::Base;

use Navel::Event::Serializer 'to';
use Navel::Utils qw/
    blessed
    croak
    isint
 /;

#-> methods

sub new {
    my ($class, %options) = @_;

    my $self = bless {}, ref $class || $class;

    if (blessed($options{collector}) eq 'Navel::Definition::Collector') {
        $self->{collector} = $options{collector};
        $self->{collection} = $self->{collector}->{collection};
    } else {
        croak('collection must be defined') unless defined $options{collection};

        $self->{collector} = undef;
        $self->{collection} = $options{collection};
    }

    $self->set_status_to_ok();
    $self->{datas} = $options{datas};

    $self->{$_} = isint($options{$_}) ? $options{$_} : time for qw/
        starting_time
        ending_time
    /;

    $self;
}

sub set_status_to_ok {
    my $self = shift;

    $self->{status_code} = 1;

    $self;
}

sub set_status_to_ko {
    my $self = shift;

    $self->{status_code} = -1;

    $self;
}

sub set_status_to_internal_ko {
    my $self = shift;

    $self->{status_code} = -2;

    $self;
}

sub serialized_datas {
    my $self = shift;

    to(
        datas => $self->{datas},
        starting_time => $self->{starting_time},
        ending_time => $self->{ending_time},
        collector => $self->{collector},
        collection => $self->{collection}
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

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
