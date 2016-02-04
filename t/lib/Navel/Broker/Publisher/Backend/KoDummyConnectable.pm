# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package t::lib::Navel::Broker::Publisher::Backend::KoDummyConnectable 0.1;

use Navel::Base;

our $IS_CONNECTABLE = 1;

#-> functions

sub publish {
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

t::lib::Navel::Broker::Publisher::Backend::KoDummyConnectable

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
