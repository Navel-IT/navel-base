# Copyright (C) 2015-2016 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-base is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

use strict;
use warnings;

use ExtUtils::MakeMaker;

#-> main

my $min_perl_version = '5.18.0';

WriteMakefile(
    NAME => 'Navel::Base',
    VERSION_FROM => 'lib/Navel/Base.pm',
    ABSTRACT => 'navel-base',
    AUTHOR => 'Yoann Le Garff, Nicolas Boquet and Yann Le Bras',
    LICENSE => 'apache_2_0',
    META_MERGE => {
        requires => {
            perl => $min_perl_version
        },
        resources => {
            license => 'http://www.apache.org/licenses/LICENSE-2.0.html',
            repository => 'http://github.com/Navel-IT/navel-base'
        }
    },
    MIN_PERL_VERSION => $min_perl_version,
    PREREQ_PM => {
        'Exporter' => 0,
        'Carp' => 0,
        'POSIX' => 0,
        'Path::Tiny' => 0,
        'Scalar::Util' => 0,
        'Scalar::Util::Numeric' => 0,
        'Clone' => 0,
        'List::MoreUtils' => 0,
        'Cpanel::JSON::XS' => 0,
        'Sereal' => 0,
        'I18N::Langinfo' => 0,
        'Encode' => 0
    },
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 6.64
    },
    TEST_REQUIRES => {
        'Test::More' => 0
    },
    test => {
        TESTS => 't/*.t'
    }
);

#-> END

__END__
