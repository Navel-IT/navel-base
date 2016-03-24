# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

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
    LICENSE => 'GNU GPL v3',
    META_MERGE => {
        requires => {
            perl => $min_perl_version
        },
        resources => {
            license => 'http://www.gnu.org/copyleft/gpl.html',
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
        'AnyEvent::IO' => 0,
        'AnyEvent::AIO' => 0,
        'IO::AIO' => 0,
        'Carp' => 0,
        'JSON::Validator' => 0,
        'Scalar::Util' => 0,
        'Scalar::Util::Numeric' => 0,
        'Term::ANSIColor' => 0,
        'Sys::Syslog' => 0,
        'File::Slurp' => 0,
        'Mojo::Base' => 0,
        'Mojo::URL' => 0,
        'YAML::XS' => 0,
        'JSON' => 0,
        'Sereal' => 0,
        'POSIX' => 0,
        'Clone' => 0,
        'Data::Structure::Util' => 0
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
