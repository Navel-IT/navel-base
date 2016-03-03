# Copyright 2015 Navel-IT
# navel-base is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

use strict;
use warnings;

use Test::More tests => 3;
use Test::Exception;

BEGIN {
    use_ok('Navel::Logger');
}

#-> main

my $log_file = './' . __FILE__ . '.log';

lives_ok {
    my $logger = Navel::Logger->new(
        severity => 'notice',
        file_path => $log_file
    )->notice($log_file)->flush_queue();
} 'Navel::Logger->new()->notice()->flush_queue(): push datas in ' . $log_file;

END {
    ok(-f $log_file, $log_file . ' created') && unlink $log_file;
}

#-> END

__END__
