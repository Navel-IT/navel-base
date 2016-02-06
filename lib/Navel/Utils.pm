# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Utils 0.1;

use Navel::Base;

use Exporter::Easy (
    OK => [qw/
        daemonize
        catch_warnings
        try_require_namespace
        isint
        isfloat
        blessed
        reftype
        exclusive_none
        unblessed
        privasize
        publicize
        flatten
        replace_key
        substitute_all_keys
        encode_json
        decode_json
        encode_json_pretty
        encode_sereal_constructor
        decode_sereal_constructor
        strftime
        :posix
        :warnings
        :namespace
        :numeric
        :scalar
        :list
        :hash
        :pripub
        :json
        :json_pretty
        :sereal
        :time
        :all
    /],
    TAGS => [
        posix => [qw/
            daemonize
        /],
        warnings => [qw/
            catch_warnings
        /],
        namespace => [qw/
            try_require_namespace
        /],
        numeric => [qw/
            isint
            isfloat
        /],
        scalar => [qw/
            blessed
            reftype
            unblessed
        /],
        list => [qw/
            exclusive_none
            flatten
        /],
        hash => [qw/
            replace_key
            substitute_all_keys
        /],
        pripub => [qw/
            privasize
            publicize
        /],
        json => [qw/
            encode_json
            decode_json
        /],
        json_pretty => [qw/
            encode_json_pretty
        /],
        sereal => [qw/
            encode_sereal_constructor
            decode_sereal_constructor
        /],
        time => [qw/
            strftime
        /],
        all => [qw/
            :posix
            :warnings
            :namespace
            :numeric
            :scalar
            :list
            :hash
            :pripub
            :json
            :json_pretty
            :sereal
            :time
        /]
    ]
);

use POSIX qw/
    setsid
    strftime
/;

use File::Slurp;

require Scalar::Util;

use Scalar::Util::Numeric qw/
    isint
    isfloat
/;

use List::MoreUtils 'none';

use JSON;
use Sereal;

#-> functions

sub daemonize {
    my %options = @_;

    $options{work_dir} = defined $options{work_dir} ? $options{work_dir} : '/';

    POSIX::setsid() or die 'setsid: ' . $!;

    my $pid = fork();

    if ($pid < 0) {
        die 'fork: ' . $!;
    } elsif ($pid) {
        exit 0;
    }

    chdir $options{work_dir};

    umask 0;

    write_file($options{pid_file}, $$) if defined $options{pid_file};

    if ($options{close_fh}) {
        POSIX::close $_ for (0..(POSIX::sysconf (&POSIX::_SC_OPEN_MAX) || 1024));
    }

    open STDIN, '< /dev/null';
    open STDOUT, '> /dev/null';
    open STDERR, '> &STDOUT';

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
        eval 'require ' . $class;

        if ($@) {
            @return[1] = $@;
        } else {
            @return[0] = 1;
        }
    } else {
        @return[1] = 'class must be defined';
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

sub unblessed($) {
    return { %{+shift} };
}

sub exclusive_none($$) {
    my ($reference, $difference) = @_;

    none {
        my $to_check = $_;

        none {
            $to_check eq $_
        } @{$reference};
    } @{$difference};
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

sub encode_json_pretty($) {
    JSON->new()->utf8()->pretty()->encode(shift);
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
