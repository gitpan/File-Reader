# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl File-Reader.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';
use Test;
BEGIN { plan tests => 12 };
use File::Reader ':all';
ok(1); # If we made it this far, we're ok.
my $test="this is only a test !\n" ;
open STDERR, ">>/dev/null" ;
ok(Read('README'));
ok(Write('Testing',$test)) ;
ok(%c=ReadConfAdv('t/ex1.conf','=tSTART','=tSTOP')) ;
ok(%c=ReadConfAdv2('t/ex1.conf','=tSTART','=tSTOP','=')) ;
ok(%c=sReadConfAdv('t/ex1.conf','=tSTART','=tSTOP',1)) ;
ok(%c=sReadConfAdv2('t/ex1.conf','=tSTART','=tSTOP',1,'=')) ;
ok(%c=ReadConf('t/nofile.conf'));
ok(%c=sReadConf('t/nofile.conf'));
ok(%c=ReadConf2('t/nofile.conf','='));
ok(%c=ReadConf2('t/nofile.conf',1,'='));
ok(generateConfFile('t/PerlSource.pl','t/PerlSource.conf'));
close STDERR ;

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

