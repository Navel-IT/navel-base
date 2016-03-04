# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Logger::Message 0.1;

use Navel::Base;

use Navel::Logger::Message::Facility::Local;
use Navel::Logger::Message::Severity;
use Navel::Utils qw/
    flatten
    isint
    strftime
/;

#-> methods

sub stepped_message {
    my $class = shift;

    my $stepped_message;

    for (@_) {
        $stepped_message .= "\n" if defined $stepped_message;

        if (ref eq 'ARRAY') {
            $stepped_message .= (defined $stepped_message ? '' : "\n") . join "\n", map {
                (' ' x 4) . $_
            } flatten($_) if @{$_};
        } else {
            $stepped_message .= $_;
        }
    }

    chomp $stepped_message;

    $stepped_message;
}

sub new {
    my ($class, %options) = @_;

    my $self = bless {
        text => $options{text},
        time => $options{time},
        datetime_format => $options{datetime_format},
        hostname => $options{hostname},
        service => $options{service},
        service_pid => $options{service_pid}
    }, ref $class || $class;

    $self->set_facility($options{facility})->set_severity($options{severity});
}

sub set_facility {
    my $self = shift;

    $self->{facility} = Navel::Logger::Message::Facility::Local->new(shift);

    $self;
}

sub set_severity {
    my $self = shift;

    $self->{severity} = Navel::Logger::Message::Severity->new(shift);

    $self;
}

sub prepare_properties {
    my $self = shift;

    $self->{hostname} =~ s/\s//g if defined $self->{hostname};
    $self->{service} =~ s/\s//g if defined $self->{service};

    $self;
}

sub constructor_properties {
    my $self = shift;

    return {
        %{$self},
        %{
            {
                facility => $self->{facility}->{label},
                severity => $self->{severity}->{label}
            }
        }
    };
}

sub to_string {
    my $self = shift;

    $self->prepare_properties();

    (isint($self->{time}) && defined $self->{datetime_format} && length $self->{datetime_format} ? strftime($self->{datetime_format}, (localtime $self->{time})) . ' ' : '') . (length $self->{hostname} ? $self->{hostname} . ' ' : '') . (length $self->{service} ? $self->{service} . (isint($self->{service_pid}) ? '[' . $self->{service_pid} . ']' : '') : '') . ': [' . $self->{facility}->{label} . '.' . $self->{severity}->{label} . ']: ' . (defined $self->{text} ? $self->{text} : '');
}

sub to_syslog {
    my $self = shift;

    $self->prepare_properties();

    [
        $self->{facility}->{label} . '|' . $self->{severity}->{label},
        '%s',
        defined $self->{text} ? $self->{text} : ''
    ];
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Logger::Message

=head1 DESCRIPTION

The messsage format follow the specification provided by the RFC 3164

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
