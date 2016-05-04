# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Definition::Publisher::Parser 0.1;

use Navel::Base;

use parent 'Navel::Base::Definition::Parser';

#-> methods

sub new {
    shift->SUPER::new(
        definition_class => 'Navel::Definition::Publisher',
        do_not_need_at_least_one => 1,
        @_
    );
}

BEGIN {
    __PACKAGE__->create_getters(qw/
        backend
        backend_input
        scheduling
        auto_clean
        connectable
        auto_connect
    /);
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Definition::Publisher::Parser

=head1 COPYRIGHT

Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-base is licensed under the Apache License, Version 2.0

=cut
