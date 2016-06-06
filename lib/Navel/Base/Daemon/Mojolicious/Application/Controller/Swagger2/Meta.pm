# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Base::Daemon::Mojolicious::Application::Controller::Swagger2::Meta 0.1;

use Navel::Base;

use Mojo::Base 'Mojolicious::Controller';

use Mojo::JSON 'decode_json';

#-> methods

sub show_meta {
    my ($controller, $arguments, $callback) = @_;

    $controller->$callback(
        $controller->daemon()->{core}->{meta}->{definition},
        200
    );
}

sub modify_webservices_credentials {
    my ($controller, $arguments, $callback) = @_;

    my (@ok, @ko);

    local $@;

    my $body = eval {
        decode_json($controller->req()->body());
    };

    unless ($@) {
        if (ref $body eq 'HASH') {
            my $meta_definition = $controller->daemon()->{core}->{meta}->{definition};

            eval {
                $controller->daemon()->{core}->{meta}->set_definition(
                    {
                        %{$meta_definition},
                        %{
                            {
                                webservices => {
                                    %{$meta_definition->{webservices}},
                                    credentials => {
                                        %{$meta_definition->{webservices}->{credentials}},
                                        %{$body}
                                    }
                                }
                            }
                        }
                    }
                );
            };

            unless ($@) {
                push @ok, 'changing credentials of webservices.';
            } else {
                push @ko, $@;
            }
        } else {
            push @ko, 'body need to represent a hashtable.';
        }
    } else {
        push @ko, $@;
    }

    $controller->$callback(
        $controller->ok_ko(\@ok, \@ko),
        @ko ? 400 : 200
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

Navel::Base::Daemon::Mojolicious::Application::Controller::Swagger2::Meta

=head1 COPYRIGHT

Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-base is licensed under the Apache License, Version 2.0

=cut
