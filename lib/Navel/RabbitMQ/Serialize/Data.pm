# Copyright 2015 Navel-IT
# Navel Scheduler is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::RabbitMQ::Serialize::Data;

use strict;
use warnings;

use Exporter::Easy (
    OK => [qw/
        $VERSION
        :all
        to
        from
    /],
    TAGS => [
        all => [qw/
            $VERSION
            to
            from
        /]
    ]
);

use Carp 'croak';

use Navel::Definition::Connector 'connector_definition_validator';
use Navel::Utils qw/
    :scalar
    :sereal
    isint
/;

our $VERSION = 0.1;

#-> functions

sub to($@) {
    my %options = @_;

    croak('starting_time is invalid') unless isint($options{starting_time});
    croak('ending_time is invalid') unless isint($options{ending_time});

    $options{connector} = unblessed($options{connector}) if blessed($options{connector}) eq 'Navel::Definition::Connector';

    encode_sereal_constructor()->encode(
        {
            datas => $options{datas},
            starting_time => $options{starting_time},
            ending_time => $options{ending_time},
            connector => $options{connector},
            collection => defined $options{collection} ? sprintf '%s', $options{collection} : $options{collection}
        }
    );
}

sub from($) {
    my $deserialized = decode_sereal_constructor()->decode(shift);

    croak('deserialized datas are invalid') unless reftype($deserialized) eq 'HASH' && isint($deserialized->{starting_time}) && isint($deserialized->{ending_time}) && exists $deserialized->{datas} && exists $deserialized->{collection};

    my $connector;

    if (defined $deserialized->{connector}) {
        croak('deserialized datas are invalid: connector definition is invalid') unless connector_definition_validator($deserialized->{connector});

        $connector = Navel::Definition::Connector->new($deserialized->{connector});
    }

    $deserialized->{collection} = sprintf '%s', $deserialized->{collection} if defined $deserialized->{collection};

    {
        %{$deserialized},
        %{
            {
                connector => $connector
            }
        }
    };
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=head1 NAME

Navel::RabbitMQ::Serialize::Data

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
