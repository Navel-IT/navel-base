# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Mojolicious::Plugin::Logger 0.1;

use Navel::Base;

use Mojo::Base 'Mojolicious::Plugin';

use Navel::Utils qw/
    croak
    blessed
/;

#-> methods

sub register {
    my ($self, $application, $register_options) = @_;

    croak('register_options must be a HASH') unless ref $register_options eq 'HASH';

    croak('logger must be of Navel::Logger class') unless blessed($register_options->{logger}) && $register_options->{logger}->isa('Navel::Logger');

    $application->helper(
        ok_ko => sub {
            my ($controller, $ok, $ko) = @_;

            croak('ok must be a ARRAY') unless ref $ok eq 'ARRAY';
            croak('ko must be a ARRAY') unless ref $ko eq 'ARRAY';

            $register_options->{logger}->info($_) for (
                @{$ok},
                @{$ko}
            );

            {
                ok => $ok,
                ko => $ko
            };
        }
    )
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Mojolicious::Plugin::Logger

=head1 COPYRIGHT

Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-base is licensed under the Apache License, Version 2.0

=cut
