# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

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
/;

#-> methods

sub new {
    my ($class, %options) = @_;

    croak('logger must be of Navel::Logger class') unless blessed($options{logger}) && $options{logger}->isa('Navel::Logger');

    croak('definition is invalid') unless blessed($options{definition}) and $options{definition}->isa('Navel::Definition::Publisher') || $options{definition}->isa('Navel::Definition::Consumer');

    my $self = bless {
        logger => $options{logger},
        definition => $options{definition},
        queue => []
    }, ref $class || $class;

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

    $self->{logger}->debug('spawned a new process for ' . $definition_class . '/' . $self->{definition}->{name} . '.');

    $self;
}

sub rpc {
    my ($self, %options) = @_;

    croak('method must be defined') unless defined $options{method};

    $options{options} = [] unless ref $options{options} eq 'ARRAY';

    $options{callback} = sub {
    } unless ref $options{callback} eq 'CODE';

    if (defined $self->{rpc}) {
        $self->{rpc}->(
            $options{namespace},
            $options{method},
            @{$options{options}},
            $options{callback}
        );
    }

    $self;
}

sub exit {
    shift->rpc(
        namespace => 'CORE',
        method => 'exit',
        options => \@_
    );
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
    my ($self, $event_definition) = @_;

    croak('event_definition must be a HASH reference') unless ref $event_definition eq 'HASH';

    my $event = Navel::Event->new(%{$event_definition});

    $self->auto_clean();

    push @{$self->{queue}}, $event;

    $self;
}

sub definition_class {
    [
        split /::/, blessed(shift->{definition})
    ];
}

sub wrapped_code {
    my $self = shift;

    my $role_relative_method = $self->definition_class()->[-1] eq 'Publisher' ? 'publish' : 'consume';

    my $wrapped_code .= "package Navel::Broker::Client::Fork::Worker;

BEGIN {
    open STDIN, '</dev/null';
    open STDOUT, '>/dev/null';
    open STDERR, '>&STDOUT';
}" . '

sub log {
    AnyEvent::Fork::RPC::event(@_);
}

sub run {
    my ($done, $namespace, $method, @options) = @_;

    if (defined $namespace) {
        $done->(($namespace . ' . "'::'" . ' . $method)->(@options));
    } else {
        local $@;

        eval {
            (' . "'" . $self->{definition}->{backend} . "::'" . ' . $method)->($done, @options);
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

    }

    return;
}

require ' . $self->{definition}->{backend} . ';

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

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
