# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Base::Definition::Parser::Reader 0.1;

use Navel::Base;

use Carp 'croak';

use File::Slurp;

use Navel::Utils 'decode_json';

#-> methods

sub read {
    my ($self, %options) = @_;

    croak('file_path must be defined') unless defined $options{file_path};

    local $@;

    my $deserialized = eval {
        decode_json(
            scalar read_file(
                $options{file_path},
                binmode => ':utf8'
            )
        );
    };

    die $options{file_path} . ': ' . $@ . "\n" if $@;

    $deserialized;
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Base::Definition::Parser::Reader

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
