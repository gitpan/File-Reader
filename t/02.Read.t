use Test::More tests => 1;
use File::Reader qw( Read );

open STDERR, ">>/dev/null" ;
ok(Read('Testing'));
close STDERR ;