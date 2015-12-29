# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Mojolicious::Plugin::Logger 0.1;

use strict;
use warnings;

use parent 'Navel::Base';

use Carp 'croak';

use Mojo::Base 'Mojolicious::Plugin';

use Navel::Utils 'blessed';

#-> methods

sub register {
    my ($self, $application, $register_options) = @_;

    croak('register_options must be a HASH') unless ref $register_options eq 'HASH';

    croak('logger must be of Navel::Logger class') unless blessed($register_options->{logger}) eq 'Navel::Logger';

    $application->helper(
        ok_ko => sub {
            my ($controller, $options) = @_;

            croak('options must be a HASH') unless ref $options eq 'HASH';

            for my $state (qw/ok ko/) {
                if (ref $options->{$state} eq 'ARRAY') {
                    for (@{$options->{$state}}) {
                        $register_options->{logger}->info($register_options->{logger}->stepped_log($_)) if defined;
                    }
                }
            }

            {
                ok => $options->{ok},
                ko => $options->{ko}
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

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
