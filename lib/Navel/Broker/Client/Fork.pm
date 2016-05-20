# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Broker::Client::Fork 0.1;

use Navel::Base;

use AnyEvent::Fork;
use AnyEvent::Fork::RPC;

use Navel::AnyEvent::Fork::RPC::Serializer::Sereal;
use Navel::Event;
use Navel::Utils qw/
    croak
    blessed
    any
/;

#-> methods

sub new {
    my ($class, %options) = @_;

    my $self;

    if (ref $class) {
        $self = $class;
    } else {
        croak('logger must be of Navel::Logger class') unless blessed($options{logger}) && $options{logger}->isa('Navel::Logger');

        croak('definition is invalid') unless blessed($options{definition}) and $options{definition}->isa('Navel::Definition::Publisher') || $options{definition}->isa('Navel::Definition::Consumer');

        $self = bless {
            logger => $options{logger},
            meta_configuration => $options{meta_configuration},
            definition => $options{definition},
            queue => []
        }, $class;
    }

    my $definition_class = join '::', @{$self->definition_class()};

    my $wrapped_code = $self->wrapped_code();

    $self->{logger}->debug(
        Navel::Logger::Message->stepped_message('dump of the source of the ' . $definition_class . ' wrapper for ' . $self->{definition}->{backend} . '/' . $self->{definition}->{name} . '.',
            [
                split /\n/, $wrapped_code
            ]
        )
    );

    $self->{rpc} = (blessed($options{ae_fork}) && $options{ae_fork}->isa('AnyEvent::Fork') ? $options{ae_fork} : AnyEvent::Fork->new())->fork()->eval($wrapped_code)->AnyEvent::Fork::RPC::run(
        'Navel::Broker::Client::Fork::Worker::run',
        async => 1,
        on_event => $options{on_event},
        on_error => $options{on_error},
        on_destroy => $options{on_destroy},
        serialiser => Navel::AnyEvent::Fork::RPC::Serializer::Sereal::SERIALIZER
    );

    $self->{logger}->info('spawned a new process for ' . $definition_class . '.' . $self->{definition}->{name} . '.');

    $self;
}

sub rpc {
    my ($self, %options) = @_;

    croak('method must be defined') unless defined $options{method} || $options{exit};

    if (defined $self->{rpc}) {
        $self->{rpc}->(
            $options{exit},
            $options{method},
            $self->{meta_configuration},
            $self->{definition}->properties(),
            @{
                ref $options{options} eq 'ARRAY' ? $options{options} : []
            },
            ref $options{callback} eq 'CODE' ? $options{callback} : sub {}
        );
    }

    $self;
}

sub clear_queue {
    my $self = shift;

    undef @{$self->{queue}};

    $self;
}

sub auto_clean {
    my $self = shift;

    my @events;

    if ($self->{definition}->{auto_clean}) {
        my $difference = @{$self->{queue}} - $self->{definition}->{auto_clean} + 1;

        @events = splice @{$self->{queue}}, 0, $difference if $difference > 0;
    }

    \@events;
}

sub push_in_queue {
    my ($self, $event) = @_;

    unless (blessed($event) && $event->isa('Navel::Event')) {
        croak('event must be a HASH reference or an object of Navel::Event class') unless ref $event eq 'HASH';

        $event = Navel::Event->new(%{$event});
    }

    $self->auto_clean();

    any {
        $_ eq $event->{collection};
    } @{$self->{definition}->{except_collections}} and return 0;
    
    push @{$self->{queue}}, $event;
}

sub definition_class {
    [
        split /::/, blessed(shift->{definition})
    ];
}

sub wrapped_code {
    my $self = shift;

    my $wrapped_code .= "package Navel::Broker::Client::Fork::Worker;

{
    use Navel::Event;

    BEGIN {
        open STDIN, '</dev/null';
        open STDOUT, '>/dev/null';
        open STDERR, '>&STDOUT';
    }" . '

    our $stopping;

    sub log {
        AnyEvent::Fork::RPC::event(@_);
    }
};

{
    sub run {
        my ($done, $exit, $method, $meta_configuration, $definition, @options) = @_;

        local $@;

        if ($Navel::Broker::Client::Fork::Worker::stopping) {
            $done->();

            return;
        }

        if ($exit) {
            $Navel::Broker::Client::Fork::Worker::stopping = 1;

            $done->();

            exit;
        }

        eval {
            (' . "'" . $self->{definition}->{backend} . "::'" . ' . $method)->($done, $meta_configuration, $definition, @options);
        }; ' . "

        if (\$@) {
            Navel::Broker::Client::Fork::Worker::log(
                [
                    'err',
                    'an error occured on a backend call: ' . \$@
                ] " . '
            );

            $done->();
        }

        return;
    }

    require ' . $self->{definition}->{backend} . ';
};

1;';

    $wrapped_code;
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Broker::Client::Fork

=head1 COPYRIGHT

Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-base is licensed under the Apache License, Version 2.0

=cut
