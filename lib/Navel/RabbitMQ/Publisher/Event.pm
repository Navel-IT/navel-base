# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::RabbitMQ::Publisher::Event;

use strict;
use warnings;

use constant {
    OK => 0,
    KO_NO_SOURCE => 1,
    KO_EXCEPTION => 2
};

use parent 'Navel::Base';

use Carp 'croak';

use Navel::RabbitMQ::Serialize::Data 'to';
use Navel::Utils qw/
    blessed
    isint
 /;

our $VERSION = 0.1;

#-> methods

sub new {
    my ($class, %options) = @_;

    my $self = bless {}, ref $class || $class;

    if (blessed($options{collector}) eq 'Navel::Definition::Collector') {
        $self->{collector} = $options{collector};
        $self->{collection} = $self->{collector}->{collection};
    } else {
        croak('collection cannot be undefined') unless defined $options{collection};

        $self->{collector} = undef;
        $self->{collection} = $options{collection};
    }

    $self->set_ok();
    $self->{datas} = $options{datas};

    $self->{$_} = isint($options{$_}) ? $options{$_} : time for qw/starting_time ending_time/;

    $self;
}

sub set_ok {
    my $self = shift;

    $self->{status_code} = OK;

    $self;
}

sub set_ko_no_source {
    my $self = shift;

    $self->{status_code} = KO_NO_SOURCE;

    $self;
}

sub set_ko_exception {
    my $self = shift;

    $self->{status_code} = KO_EXCEPTION;

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

sub routing_key {
    my $self = shift;

    join '.', 'navel', $self->{collection}, $self->{status_code};
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=head1 NAME

Navel::RabbitMQ::Publisher::Event

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut

