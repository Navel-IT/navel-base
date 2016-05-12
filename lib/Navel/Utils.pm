# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
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

use File::Slurp qw/
    read_file
    write_file
    append_file
/;

use Scalar::Util qw//;

use Scalar::Util::Numeric qw/
    isint
    isfloat
/;

use Data::Structure::Util 'unbless';

use Clone 'clone';

use YAML::XS qw/
    Dump
    Load
/;
use JSON qw//;
use Sereal qw//;

#-> export

our @EXPORT_OK = qw/
    carp
    croak
    confess
    daemonize
    read_file
    write_file
    append_file
    catch_warnings
    try_require_namespace
    isint
    isfloat
    blessed
    reftype
    unbless
    clone
    flatten
    encode_yaml
    decode_yaml
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
    fileslurp => [
        qw/
            read_file
            write_file
            append_file
        /
    ],
    warnings => [
        qw/
            catch_warnings
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
            blessed
            reftype
            unbless
            clone
        /
    ],
    list => [
        qw/
            flatten
        /
    ],
    yaml => [
        qw/
            encode_yaml
            decode_yaml
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

    POSIX::setsid() || die 'setsid: ' . $! . "\n";

    umask 0;

    chdir $options{work_dir} || die 'cannot chdir to ' . $options{work_dir} . ': ' . $! . "\n" if defined $options{work_dir};

    write_file($options{pid_file}, $$) if defined $options{pid_file};

    open STDIN, '</dev/null';
    open STDOUT, '>/dev/null';
    open STDERR, '>&STDOUT';

    $options{work_dir};
}

sub catch_warnings {
    my ($warning_callback, $code_callback) = @_;

    croak('warning_callback and code_callback should be code reference') unless ref $warning_callback eq 'CODE' && ref $code_callback eq 'CODE';

    local $SIG{__WARN__} = sub {
        $warning_callback->(@_);
    };

    $code_callback->();
}

sub try_require_namespace {
    my $class = shift;

    croak('class must be defined') unless defined $class;

    my @return = (0, undef);

    if (defined $class) {
        local $@;

        eval 'require ' . $class;

        if ($@) {
            $return[1] = $@;
        } else {
            $return[0] = 1;
        }
    } else {
        $return[1] = 'class must be defined';
    }

    @return;
}

sub blessed {
   my $blessed = Scalar::Util::blessed(shift);

   defined $blessed ? $blessed : '';
}

sub reftype {
   my $reftype = Scalar::Util::reftype(shift);

   defined $reftype ? $reftype : '';
}

sub flatten {
    map {
        ref eq 'ARRAY' ? __SUB__->(@{$_}) : $_
    } @_;
}

sub encode_yaml {
    local $YAML::XS::QuoteNumericStrings = 0;

    Dump(@_);
}

sub decode_yaml {
    local $YAML::XS::QuoteNumericStrings = 0;

    Load(@_);
}

sub json_constructor {
    JSON->new()->allow_nonref()->utf8();
}

sub encode_sereal_constructor {
    Sereal::Encoder->new();
}

sub decode_sereal_constructor {
    Sereal::Decoder->new();
}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Utils

=head1 COPYRIGHT

Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-base is licensed under the Apache License, Version 2.0

=cut
