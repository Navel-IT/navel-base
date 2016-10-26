# Copyright (C) 2015-2016 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Base 0.1;

use v5.20;

use strict;
use warnings;

use utf8;

use feature qw//;

use I18N::Langinfo qw/
    langinfo
    CODESET
/;

use Encode 'decode';

#-> class variables

my $codeset = langinfo(CODESET);

#-> ARGV

eval {
    @ARGV = map {
        decode($codeset, $_);
    } @ARGV;
};

#-> methods

sub import {
    $_->import for qw/
        v5.20
        strict
        warnings
        utf8
    /;

    feature->import(':5.20');
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

Copyright (C) 2015-2016 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-base is licensed under the Apache License, Version 2.0

=cut
