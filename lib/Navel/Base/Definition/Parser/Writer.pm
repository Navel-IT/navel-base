# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Base::Definition::Parser::Writer;

use strict;
use warnings;

use parent 'Navel::Base';

use Carp 'croak';

use File::Slurp;

use AnyEvent::IO;

use Navel::Utils 'encode_json_pretty';

our $VERSION = 0.1;

#-> methods

sub write {
    my ($self, %options) = @_;

    croak('file_path must be defined') unless defined $options{file_path};

    croak('on_* must be defined') unless ref $options{on_success} eq 'CODE' && ref $options{on_error} eq 'CODE';

    if ($options{async}) {
        aio_open($options{file_path}, AnyEvent::IO::O_CREAT | AnyEvent::IO::O_WRONLY, 0, sub {
            my $filehandle = shift;

            if ($filehandle) {
                my $aio_close = sub {
                    aio_close(shift,
                        sub {
                            $options{on_error}->($options{file_path} . ': ' . $!) unless shift;
                        }
                    );
                };

                aio_truncate($filehandle, 0, sub {
                    if (@_) {
                        my $json_definitions = encode_json_pretty($options{definitions});

                        aio_write($filehandle, $json_definitions,
                            sub {
                                if (shift == length $json_definitions) {
                                    $options{on_success}->($options{file_path});
                                } else {
                                    $options{on_error}->($options{file_path} . ': the definitions have not been properly written, they are probably corrupt');
                                }

                                $aio_close->($filehandle);
                            }
                        );
                    } else {
                        $options{on_error}->($options{file_path} . ': ' . $!);

                        $aio_close->($filehandle);
                    }
                });
            } else {
                $options{on_error}->($options{file_path} . ': ' . $!);
            }
        });
    } else {
        eval {
            write_file(
                $options{file_path},
                {
                    err_mode => 'carp',
                    binmode => ':utf8'
                },
                \encode_json_pretty($options{definitions})
            );
        };

        unless ($@) {
            $options{on_success}->($options{file_path});
        } else {
            $options{on_error}->($options{file_path} . ': ' . $@);
        }
    }

    $self;
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=head1 NAME

Navel::Base::Definition::Parser::Writer

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
