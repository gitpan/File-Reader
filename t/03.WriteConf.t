use Test::More tests => 1;
use File::Reader qw( WriteConf );
my %conf = (
	test1 => 'this Rocks 1 time dude',
	test2 => 'this Rocks 2 times dude',
	test3 => 'this Rocks 3 times dude',
	test4 => 'this Rocks 4 times dude',
);
open STDERR, ">>/dev/null" ;
ok(WriteConf('ex1.conf',%conf)) ;
close STDERR ;