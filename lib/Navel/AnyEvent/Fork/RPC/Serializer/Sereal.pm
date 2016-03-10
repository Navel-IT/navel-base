# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::AnyEvent::Fork::RPC::Serializer::Sereal 0.1;

use Navel::Base;

use constant {
    SERIALIZER => '
use Sereal;

(
    sub {
        Sereal::Encoder->new(
            {
                no_shared_hashkeys => 1
            }
        )->encode(\@_);
    },
    sub {
        @{Sereal::Decoder->new()->decode(shift)};
    }
);
'
};

#-> methods

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::AnyEvent::Fork::RPC::Serializer::Sereal

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
