# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 12 };
use File::Reader qw( Write listDir Read ReWrite ReadConfAdv ReadConf sReWrite sWrite sRead sReadConf sReadConfAdv ReadConfAdv2 sReadConf2 sReadConfAdv2 ReadConf2 generateConfFile);
ok(1); # If we made it this far, we're ok.
my $test="this is only a test !\n" ;
open STDERR, ">>/dev/null" ;
ok(Read('README'));
ok(Write('Testing',$test)) ;
ok(%c=ReadConfAdv('ex1.conf','=tSTART','=tSTOP')) ;
ok(%c=ReadConfAdv2('ex1.conf','=tSTART','=tSTOP','=')) ;
ok(%c=sReadConfAdv('ex1.conf','=tSTART','=tSTOP',1)) ;
ok(%c=sReadConfAdv2('ex1.conf','=tSTART','=tSTOP',1,'=')) ;
ok(%c=ReadConf('nofile.conf'));
ok(%c=sReadConf('nofile.conf'));
ok(%c=ReadConf2('nofile.conf','='));
ok(%c=ReadConf2('nofile.conf',1,'='));
ok(generateConfFile('PerlSource','PerlSource.conf'));
close STDERR ;
#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

