use Test::More tests => 4;
use File::Reader qw( ReadConf ReadConf2 sReadConf sReadConf2);

open STDERR, ">>/dev/null" ;
ok(%c=ReadConf('ex1.conf'));
ok(%c=sReadConf('ex1.conf'));
ok(%c=ReadConf2('ex1.conf','='));
ok(%c=sReadConf2('ex1.conf',1,'='));
close STDERR ;