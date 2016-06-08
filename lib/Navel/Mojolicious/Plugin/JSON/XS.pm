# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Mojolicious::Plugin::JSON::XS 0.1;

use Navel::Base;

use Mojo::Base 'Mojolicious::Plugin';

use Mojo::Util 'monkey_patch';

use JSON::XS;

#-> class variables

my $json_binary_constructor = JSON::XS->new()->utf8()->allow_nonref()->allow_blessed()->convert_blessed();

my $json_text_constructor = JSON::XS->new()->utf8(0)->allow_nonref()->allow_blessed()->convert_blessed();

#-> methods

sub register {
    monkey_patch(
        'Mojo::JSON',
        decode_json => sub {
            $json_binary_constructor->decode(shift);
        },
        encode_json => sub {
            $json_binary_constructor->encode(shift);
        },
        from_json => sub {
            $json_text_constructor->decode(shift);
        },
        to_json => sub {
            $json_text_constructor->encode(shift);
        },
        true => sub () {
            JSON::XS::true();
        },
        false => sub () {
            JSON::XS::false();
        }
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

Navel::Mojolicious::Plugin::JSON::XS - based on Mojo::JSON_XS

=head1 COPYRIGHT

Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-base is licensed under the Apache License, Version 2.0

=cut
