# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Base 0.1;

use v5.18;

use strict;
use warnings;

use utf8;

use open qw/
    :std
    :utf8
/;

use feature qw//;

#-> methods

sub import {
    $_->import() for qw/
        v5.18
        strict
        warnings
        utf8
    /;

    feature->import(':5.18');
}

# sub AUTOLOAD {}

sub DESTROY {
}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Base

=head1 DESCRIPTION

This is a base class for Navel projects.

This automatically turn on 'v5.18' (with related features), 'strict', 'warnings' and 'utf8'.

=head1 COPYRIGHT

Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-base is licensed under the Apache License, Version 2.0

=cut
