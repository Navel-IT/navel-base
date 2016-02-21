# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Event::Serializer 0.1;

use Navel::Base;

use parent 'Exporter';

use Carp 'croak';

use Navel::Definition::Collector;
use Navel::Utils qw/
    :scalar
    :sereal
    isint
/;

#-> export

our @EXPORT_OK = qw/
    to
    from
/;

our %EXPORT_TAGS = (
    all => \@EXPORT_OK
);

#-> functions

sub to($@) {
    my %options = @_;

    croak('starting_time is invalid') unless isint($options{starting_time});
    croak('ending_time is invalid') unless isint($options{ending_time});

    $options{collector} = unblessed($options{collector}) if blessed($options{collector}) eq 'Navel::Definition::Collector';

    encode_sereal_constructor()->encode(
        {
            datas => $options{datas},
            starting_time => $options{starting_time},
            ending_time => $options{ending_time},
            collector => $options{collector},
            collection => defined $options{collection} ? sprintf '%s', $options{collection} : $options{collection}
        }
    );
}

sub from($) {
    my $deserialized = decode_sereal_constructor()->decode(shift);

    croak('deserialized datas are invalid') unless ref $deserialized eq 'HASH' && isint($deserialized->{starting_time}) && isint($deserialized->{ending_time}) && exists $deserialized->{datas} && exists $deserialized->{collection};

    my $collector;

    if (defined $deserialized->{collector}) {
        croak('deserialized datas are invalid: collector definition is invalid') if @{Navel::Definition::Collector->validate($deserialized->{collector})};

        $collector = Navel::Definition::Collector->new($deserialized->{collector});
    }

    $deserialized->{collection} = sprintf '%s', $deserialized->{collection} if defined $deserialized->{collection};

    {
        %{$deserialized},
        %{
            {
                collector => $collector
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

=encoding utf8

=head1 NAME

Navel::Event::Serializer

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
