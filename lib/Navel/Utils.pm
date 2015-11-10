# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Utils;

use strict;
use warnings;

use subs qw/
    flatten
    substitute_all_keys
/;

use Exporter::Easy (
    OK => [qw/
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
        human_readable_localtime
        :numeric
        :scalar
        :pripub
        :array
        :hash
        :json
        :json_pretty
        :sereal
        :time
        :all
    /],
    TAGS => [
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
        /],
        pripub => [qw/
            privasize
            publicize
        /],
        array => [qw/
            flatten
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
            :numeric
            :scalar
            :pripub
            :array
            :hash
            :json
            :json_pretty
            :sereal
            :time
        /]
    ]
);

require Scalar::Util;

use Scalar::Util::Numeric qw/
    isint
    isfloat
/;

use List::MoreUtils 'none';

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

sub exclusive_none($$) {
    my ($reference, $difference) = @_;

    none {
        my $to_check = $_;

        none { $to_check eq $_ } @{$reference};
    } @{$difference};
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

sub flatten {
    map {
        ref eq 'ARRAY' ? flatten(@{$_}) : $_
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

    sprintf '%02d-%02d-%02d %02d:%02d:%02d', $mday, $mon + 1, 1900 + $year, $hour, $min, $sec;
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
