# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

use strict;
use warnings;

use Test::More tests => 2;

BEGIN {
    use_ok('Navel::Logger');
}

#-> main

my $log_file = '/logger.log';

unlink $log_file if ok(Navel::Logger->new(
    default_severity => 'notice',
    severity => 'notice',
    file_path => $log_file
)->push_in_queue(
    message => __FILE__,
    severity => 'notice'
)->flush_queue(), 'new()->push_in_queue()->flush_queue(): push datas in ' . $log_file);

#-> END

__END__
