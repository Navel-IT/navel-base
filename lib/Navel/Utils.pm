# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

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

$YAML::XS::QuoteNumericStrings = 0;

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
    privasize
    publicize
    flatten
    replace_key
    substitute_all_keys
    encode_yaml
    decode_yaml
    encode_json
    decode_json
    encode_json_pretty
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
    hash => [
        qw/
            replace_key
            substitute_all_keys
        /
    ],
    pripub => [
        qw/
            privasize
            publicize
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
            encode_json
            decode_json
        /
    ],
    json_pretty => [
        qw/
            encode_json_pretty
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

    $options{work_dir} = defined $options{work_dir} ? $options{work_dir} : '/';

    my $pid = fork;

    if ($pid < 0) {
        die 'fork: ' . $! . "\n";
    } elsif ($pid) {
        exit 0;
    }

    POSIX::setsid() or die 'setsid: ' . $! . "\n";

    umask 0;

    chdir $options{work_dir};

    write_file($options{pid_file}, $$) if defined $options{pid_file};

    open STDIN, '</dev/null';
    open STDOUT, '>/dev/null';
    open STDERR, '>&STDOUT';

    $options{work_dir};
}

sub catch_warnings {
    my ($warning_callback, $code_callback) = @_;

    local $SIG{__WARN__} = sub {
        $warning_callback->(@_);
    };

    $code_callback->();
}

sub try_require_namespace {
    my $class = shift;

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

sub blessed($) {
   my $blessed = Scalar::Util::blessed(shift);

   defined $blessed ? $blessed : '';
}

sub reftype($) {
   my $reftype = Scalar::Util::reftype(shift);

   defined $reftype ? $reftype : '';
}

sub flatten {
    map {
        ref eq 'ARRAY' ? __SUB__->(@{$_}) : $_
    } @_;
}

sub replace_key($$$) {
    my ($hash, $key, $new_key) = @_;

    $hash->{$new_key} = delete $hash->{$key};
}

sub substitute_all_keys($$$@) {
    my ($hash, $old, $new, $recursive) = @_;

    local $@;

    for (keys %{$hash}) {
        my $new_key = $_;

        eval '$new_key =~ s/' . $old . '/' . $new . '/g';

        $@ ? return 0 : replace_key($hash, $_, $new_key);

        if ($recursive && reftype($hash->{$new_key}) eq 'HASH') {
            __SUB__->($hash->{$new_key}, $old, $new, $recursive) || return 0;
        }
    }

    1;
}

sub privasize($@) {
    substitute_all_keys(shift, '^(.*)', '__$1', shift);
}

sub publicize($@) {
    substitute_all_keys(shift, '^__', '', shift);
}

sub encode_yaml {
    Dump(@_);
}

sub decode_yaml {
    Load(@_);
}

sub encode_json {
    JSON->new()->allow_nonref()->utf8()->encode(@_);
}

sub decode_json {
    JSON->new()->allow_nonref()->utf8()->decode(@_);
}

sub encode_json_pretty {
    JSON->new()->allow_nonref()->utf8()->pretty()->encode(@_);
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

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
