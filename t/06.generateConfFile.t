use Test::More tests => 1;
use File::Reader qw( generateConfFile );

open STDERR, ">>/dev/null" ;
ok(generateConfFile('PerlSource','PerlSource.conf'));
close STDERR ;