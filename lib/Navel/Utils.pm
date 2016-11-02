# Copyright (C) 2015-2016 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Utils 0.1;

use Navel::Base;

use parent 'Exporter';

use Carp qw/
    carp
    croak
    confess
/;

use POSIX 'strftime';

use Path::Tiny;

use Scalar::Util qw/
    weaken
    unweaken
/;

use Scalar::Util::Numeric qw/
    isint
    isfloat
/;

use Clone 'clone';

use List::MoreUtils 'any';

BEGIN {
    require Cpanel::JSON::XS;
    require Sereal;
}

#-> export

our @EXPORT_OK = qw/
    carp
    croak
    confess
    daemonize
    path
    try_require_namespace
    isint
    isfloat
    weaken
    unweaken
    blessed
    clone
    any
    flatten
    json_constructor
    encode_sereal_constructor
    decode_sereal_constructor
    strftime
/;

our %EXPORT_TAGS = (
    carp => [
        qw/
            carp
            croak
            confess
        /
    ],
    posix => [
        qw/
            daemonize
        /
    ],
    io => [
        qw/
            path
        /
    ],
    namespace => [
        qw/
            try_require_namespace
        /
    ],
    numeric => [
        qw/
            isint
            isfloat
        /
    ],
    scalar => [
        qw/
            weaken
            unweaken
            blessed
            clone
        /
    ],
    list => [
        qw/
            any
            flatten
        /
    ],
    json => [
        qw/
            json_constructor
        /
    ],
    sereal => [
        qw/
            encode_sereal_constructor
            decode_sereal_constructor
        /
    ],
    time => [
        qw/
            strftime
        /
    ],
    all => \@EXPORT_OK
);

#-> functions

sub daemonize { # http://www.netzmafia.de/skripten/unix/linux-daemon-howto.html
    my %options = @_;

    local $!;

    my $pid = fork;

    if ($pid < 0) {
        die 'fork: ' . $! . "\n";
    } elsif ($pid) {
        exit 0;
    }

    POSIX::setsid || die 'setsid: ' . $! . "\n";

    umask 0;

    chdir $options{work_dir} || die 'cannot chdir to ' . $options{work_dir} . ': ' . $! . "\n" if defined $options{work_dir};

    path($options{pid_file})->spew($$) if defined $options{pid_file};

    open STDIN, '</dev/null';
    open STDOUT, '>/dev/null';
    open STDERR, '>&STDOUT';

    $options{work_dir};
}

sub try_require_namespace {
    my $class = shift;

    croak('class must be defined') unless defined $class;

    local $@;

    eval 'require ' . $class;

    $@;
}

sub blessed {
    Scalar::Util::blessed(shift) // '';
}

sub flatten {
    map {
        ref eq 'ARRAY' ? __SUB__->(@{$_}) : $_
    } @_;
}

sub json_constructor {
    Cpanel::JSON::XS->new->allow_nonref->utf8;
}

sub encode_sereal_constructor {
    Sereal::Encoder->new(@_);
}

sub decode_sereal_constructor {
    Sereal::Decoder->new(@_);
}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Utils

=head1 COPYRIGHT

Copyright (C) 2015-2016 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-base is licensed under the Apache License, Version 2.0

=cut
