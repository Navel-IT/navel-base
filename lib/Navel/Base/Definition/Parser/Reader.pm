# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Base::Definition::Parser::Reader 0.1;

use Navel::Base;

use Navel::Utils qw/
    croak
    read_file
    decode_yaml
/;

#-> methods

sub read {
    my ($self, %options) = @_;

    croak('file_path must be defined') unless defined $options{file_path};

    local $@;

    my $deserialized = eval {
        decode_yaml(
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

=head1 COPYRIGHT

Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-base is licensed under the Apache License, Version 2.0

=cut
