# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Base::Daemon 0.1;

use Navel::Base;

use Getopt::Long::Descriptive;

use Sys::Hostname;

use Navel::Definition::WebService::Parser;
use Navel::Logger;
use Navel::Logger::Message;
use Navel::Utils qw/
    croak
    blessed
    daemonize
    try_require_namespace
/;

#-> methods

sub Getopt::Long::Descriptive::Usage::exit {
    print shift->text();

    exit shift;
}

sub run {
    my ($class, %options) = @_;

    croak('program_name must be defined') unless defined $options{program_name};

    my $meta_argument = 'meta-configuration-file-path';

    my @describe_options = (
        [
            'validate-configuration',
            'validate the configuration and exit with the proper code'
        ],
        [
            'log-datetime-format=s',
            'set datetime format (default: %b %d %H:%M:%S)',
            {
                default => '%b %d %H:%M:%S'
            }
        ],
        [
            'log-facility=s',
            'set facility (syslog format (only local[0-7])) (default: local0)',
            {
                default => 'local0'
            }
        ],
        [
            'log-severity=s',
            'set severity (syslog format) (default: notice)',
            {
                default => 'notice'
            }
        ],
        [
            'log-no-color',
            'disable colored output'
        ],
        [
            'log-to-syslog',
            'log to syslog'
        ],
        [
            'log-file-path=s',
            'log output to a file'
        ],
        [],
        [
            'daemonize',
            'run as a standalone daemon'
        ],
        [
            'daemonize-pid-file=s',
            'write the PID to a file'
        ],
        [
            'daemonize-chdir=s',
            'change the current working directory to another'
        ],
        [],
        [
            'no-web-services',
            'disable the web services'
        ],
        [],
        [
            'version',
            'print version'
        ],
        [
            'help',
            'print help'
        ]
    );

    unshift @describe_options, @{$options{options}} if ref $options{options} eq 'ARRAY';

    my ($options, $usage) = describe_options(
        $options{program_name} . ' %o <' . $meta_argument . '>',
        @describe_options
    );

    $usage->exit(0) if $options->help();

    if ($options->version()) {
        say $class->VERSION();

        exit 0;
    }

    my $meta_configuration_file_path = shift @ARGV;

    unless (defined $meta_configuration_file_path) {
        say 'Missing argument: ' . $meta_argument . ' must be defined';

        $usage->exit(1);
    }

    local $@;

    my $logger = eval {
        Navel::Logger->new(
            datetime_format => $options->log_datetime_format(),
            hostname => eval {
                hostname();
            },
            service => $options{program_name},
            facility => $options->log_facility(),
            severity => $options->log_severity(),
            colored => ! $options->log_no_color(),
            syslog => $options->log_to_syslog(),
            file_path => $options->log_file_path()
        );
    };

    if ($@) {
        chomp $@;

        say 'Logger error: ' . $@;

        $usage->exit(1);
    }

    $options{before_daemonization}->($class, $options, $logger) if ref $options{before_daemonization} eq 'CODE';

    if ($options->daemonize() && ! $options->validate_configuration()) {
        $logger->info('daemonizing.')->flush_queue();

        eval {
            daemonize(
                work_dir => $options->daemonize_chdir(),
                pid_file => $options->daemonize_pid_file()
            );
        };

        unless ($@) {
            $logger->{service_pid} = $$;

            $logger->info('daemon successfully started.')->flush_queue();
        } else {
            $logger->emerg(
                Navel::Logger::Message->stepped_message('error while daemonizing.',
                    [
                        $@
                    ]
                )
            )->flush_queue();

            exit 1;
        }
    }

    my $daemon = eval {
        $class->new(
            logger => $logger,
            meta_configuration_file_path => $meta_configuration_file_path,
            enable_webservices => ! $options->no_web_services() && ! $options->validate_configuration()
        );
    };

    if ($@) {
        $logger->emerg(Navel::Logger::Message->stepped_message($@))->flush_queue();

        exit 1;
    }

    if ($options->validate_configuration()) {
        $logger->notice('configuration is valid.')->flush_queue();

        exit 0;
    }

    $options{before_starting}->($daemon, $options) if ref $options{before_starting} eq 'CODE';

    $logger->notice('initialization done.')->flush_queue();

    eval {
        $daemon->start();
    };

    if ($@) {
        $logger->emerg(Navel::Logger::Message->stepped_message($@))->flush_queue();

        exit 1;
    }
}

sub new {
    my ($class, %options) = @_;

    croak('meta option must be an object of the Navel::Base::Daemon::Parser class') unless blessed($options{meta}) && $options{meta}->isa('Navel::Base::Daemon::Parser');

    die "meta_configuration_file_path is missing\n" unless defined $options{meta_configuration_file_path};

    my $self = bless {
        meta_configuration_file_path => $options{meta_configuration_file_path},
        webserver => undef
    }, ref $class || $class;

    $options{meta}->read(
        file_path => $self->{meta_configuration_file_path}
    );

    $self->{webservices} = Navel::Definition::WebService::Parser->new()->read(
        file_path => $options{meta}->{definition}->{webservices}->{definitions_from_file}
    )->make();

    my $load_class_error = try_require_namespace($options{core_class});

    croak($load_class_error) if $load_class_error;

    $self->{core} = $options{core_class}->new(%options);

    croak('core_class must create an object of the Navel::Base::Daemon::Core class') unless blessed($self->{core}) && $self->{core}->isa('Navel::Base::Daemon::Core');

    if ($options{enable_webservices} && @{$self->{webservices}->{definitions}}) {
        $load_class_error = try_require_namespace($options{mojolicious_application_class});

        croak($load_class_error) if $load_class_error;

        $options{mojolicious_application_class}->import();

        require Mojo::Server::Daemon;
        Mojo::Server::Daemon->import();

        $self->{webserver} = Mojo::Server::Daemon->new(
            app => $options{mojolicious_application_class}->new(
                %options,
                daemon => $self,
            ),
            listen => $self->{webservices}->url()
        );
    }

    $self;
}

sub webserver {
    my ($self, $action) = @_;

    return blessed($self->{webserver}) && $self->{webserver}->isa('Mojo::Server::Daemon') unless defined $action;

    local $@;

    eval {
        if ($action) {
            $self->{core}->{logger}->notice('starting the webservices.');

            $self->{webserver}->silent(1)->start();
        } else {
            $self->{core}->{logger}->notice('stopping the webservices.');

            $self->{webserver}->stop();
        }
    };

    $self->{core}->{logger}->crit(Navel::Logger::Message->stepped_message($@)) if $@;

    $self->{core}->{logger}->flush_queue();

    $self;
}

sub start {
    my $self = shift;

    if ($self->webserver()) {
        local $@;

        while (my ($method, $value) = each %{$self->{core}->{meta}->{definition}->{webservices}->{mojo_server}}) {
            eval {
                $self->{webserver}->$method($value);
            };

            $self->{core}->{logger}->crit(Navel::Logger::Message->stepped_message($@))->flush_queue() if $@;
        }

        $self->webserver(1);
    }

    $self;
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Base::Daemon

=head1 COPYRIGHT

Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-base is licensed under the Apache License, Version 2.0

=cut
