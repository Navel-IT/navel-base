# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Logger::Message::Facility::Local 0.1;

use Navel::Base;

use Navel::Utils qw/
    isint
    croak
/;

#-> class variables

my %facilities = (
    'local0' => 16,
    'local1' => 17,
    'local2' => 18,
    'local3' => 19,
    'local4' => 20,
    'local5' => 21,
    'local6' => 22,
    'local7' => 23
);

#-> methods

sub facilities {
    [
        keys %facilities
    ];
}

sub new {
    my ($class, $label) = @_;

    croak('label must be defined') unless defined $label;

    croak('facility is invalid') unless exists $facilities{$label};

    bless {
        label => $label
    }, ref $class || $class;
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Logger::Message::Facility::Local

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
