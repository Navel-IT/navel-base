# Copyright 2015 Navel-IT
# Navel Scheduler is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Utils;

use strict;
use warnings;

use subs 'substitute_all_keys';

use Exporter::Easy (
    OK => [qw/
        crunch
        isnum
        isfloat
        blessed
        reftype
        unblessed
        privasize
        publicize
        replace_key
        substitute_all_keys
        encode_json
        decode_json
        encode_json_pretty
        encode_sereal_constructor
        decode_sereal_constructor
        human_readable_localtime
        :string
        :numeric
        :scalar
        :pripub
        :hash
        :json
        :json_pretty
        :sereal
        :time
        :all
    /],
    TAGS => [
        string => [qw/
            crunch
        /],
        numeric => [qw/
            isnum
            isfloat
        /],
        scalar => [qw/
            blessed
            reftype
            unblessed
        /],
        pripub => [qw/
            privasize
            publicize
        /],
        hash => [qw/
            replace_key
            substitute_all_keys
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
            human_readable_localtime
        /],
        all => [qw/
            :string
            :numeric
            :scalar
            :pripub
            :hash
            :json
            :json_pretty
            :sereal
            :time
        /]
    ]
);

require Scalar::Util;
use String::Util 'crunch';

use Scalar::Util::Numeric qw/
    isint
    isfloat
/;

use JSON qw/
    encode_json
    decode_json
/;
use Sereal;

our $VERSION = 0.1;

#-> functions

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

sub privasize($@) {
    substitute_all_keys(shift, '^(.*)', '__$1', shift);
}

sub publicize($@) {
    substitute_all_keys(shift, '^__', '', shift);
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
            substitute_all_keys($hash->{$new_key}, $old, $new, $recursive) || return 0;
        }
    }

    1;
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

sub human_readable_localtime($) {
    my ($sec, $min, $hour, $mday, $mon, $year) = localtime shift;

    sprintf '%d/%02d/%02d %02d:%02d:%02d', $mday, $mon, 1900 + $year, $hour, $min, $sec;
}

1;

#-> END

__END__

=pod

=head1 NAME

Navel::Utils

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
