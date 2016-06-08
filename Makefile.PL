# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

use strict;
use warnings;

use ExtUtils::MakeMaker 6.64;

#-> main

my $min_perl_version = '5.18.0';

WriteMakefile(
    NAME => 'Navel::Base',
    VERSION_FROM => 'lib/Navel/Base.pm',
    ABSTRACT => 'navel-base',
    AUTHOR => 'Yoann Le Garff, Nicolas Boquet and Yann Le Bras',
    LICENSE => 'Apache License, Version 2.0',
    META_MERGE => {
        requires => {
            perl => $min_perl_version
        },
        resources => {
            license => 'http://www.apache.org/licenses/LICENSE-2.0.html',
            repository => 'http://github.com/Navel-IT/navel-base'
        },
        no_index => {
            directory => ['t']
        }
    },
    MIN_PERL_VERSION => $min_perl_version,
    PREREQ_PM => {
        'Exporter' => 0,
        'AnyEvent' => 0,
        'AnyEvent::Fork' => 0,
        'AnyEvent::Fork::RPC' => 0,
        'AnyEvent::IO' => 0,
        'AnyEvent::AIO' => 0,
        'IO::AIO' => 0,
        'Carp' => 0,
        'JSON::Validator' => 0,
        'Scalar::Util' => 0,
        'Scalar::Util::Numeric' => 0,
        'List::MoreUtils' => 0,
        'Term::ANSIColor' => 0,
        'Sys::Syslog' => 0,
        'Path::Tiny' => 0,
        'Mojo::Base' => 0,
        'Mojo::URL' => 0,
        'YAML::XS' => 0,
        'JSON::XS' => 0,
        'Sereal' => 0,
        'POSIX' => 0,
        'Clone' => 0,
        'Data::Structure::Util' => 0,
        'Mojolicious' => 0,
        'Getopt::Long::Descriptive' => 0,
        'Sys::Hostname' => 0,
        'I18N::Langinfo' => 0,
        'Encode' => 0
    },
    TEST_REQUIRES => {
        'Test::More' => 0,
        'Test::Exception' => 0,
        'AnyEvent' => 0
    },
    test => {
        TESTS => 't/*.t'
    }
);

#-> END

__END__
