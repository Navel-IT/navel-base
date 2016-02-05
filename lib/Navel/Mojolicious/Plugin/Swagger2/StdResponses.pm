# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Mojolicious::Plugin::Swagger2::StdResponses 0.1;

use Navel::Base;

use Mojo::Base 'Mojolicious::Plugin';

#-> functions

my $generic_error = sub {
    my ($controller, $options) = @_;

    my $callback = delete $options->{callback};

    $controller->$callback(
        $options->{ok_ko},
        $options->{code}
    );
};

#-> methods

sub register {
    my ($self, $application, $register_options) = @_;

    $application->helper(
        resource_not_found => sub {
            my ($controller, $options) = @_;

            $generic_error->(
                $controller,
                {
                    %{$options},
                    %{
                        {
                            ok_ko => {
                                ok => [],
                                ko => [
                                    'the resource ' . (defined $options->{resource_name} ? $options->{resource_name} . ' ' : '') . 'could not be found.'
                                ]
                            },
                            code => 404
                        }
                    }
                }
            );
        }
    );

    $application->helper(
        resource_already_exists => sub {
            my ($controller, $options) = @_;

            $generic_error->(
                $controller,
                {
                    %{$options},
                    %{
                        {
                            ok_ko => {
                                ok => [],
                                ko => [
                                    'the resource ' . (defined $options->{resource_name} ? $options->{resource_name} . ' ' : '') . 'already exists.'
                                ]
                            },
                            code => 409
                        }
                    }
                }
            );
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

Navel::Mojolicious::Plugin::Swagger2::StdResponses

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut