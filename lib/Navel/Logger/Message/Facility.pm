# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Logger::Message::Facility 0.1;

use Navel::Base;

use Navel::Utils qw/
    isint
    croak
/;

#-> class variables

my %facilities = (
    0 => 'kern',
    1 => 'user',
    2 => 'mail',
    3 => 'daemon',
    4 => 'auth',
    5 => 'syslog',
    6 => 'lpr',
    7 => 'news',
    8 => 'uucp',
    9 => undef,
    10 => 'authpriv',
    11 => 'ftp',
    12 => undef,
    13 => undef,
    14 => undef,
    15 => 'cron',
    16 => 'local0',
    17 => 'local1',
    18 => 'local2',
    19 => 'local3',
    20 => 'local4',
    21 => 'local5',
    22 => 'local6',
    23 => 'local7'
);

#-> methods

sub facilities {
    [
        keys %facilities
    ];
}

sub new {
    my ($class, $code) = @_;

    croak('code must be an integer') unless isint($code);

    croak('facility is invalid') unless exists $facilities{$code};

    bless {
        code => $code
    }, ref $class || $class;
}

sub keyword {
    my $self = shift;

    defined $facilities{$self->{code}} ? $facilities{$self->{code}} : $self->{code};
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Logger::Message::Facility

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
