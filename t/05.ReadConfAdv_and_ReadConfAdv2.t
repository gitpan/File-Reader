use Test::More tests => 4;
use File::Reader qw( ReadConfAdv ReadConfAdv2 sReadConfAdv sReadConfAdv2);

open STDERR, ">>/dev/null" ;
ok(%c=ReadConfAdv('ex2.conf','=tSTART','=tSTOP')) ;
ok(%c=ReadConfAdv2('ex2.conf','=tSTART','=tSTOP','=')) ;
ok(%c=sReadConfAdv('ex2.conf','=tSTART','=tSTOP',1)) ;
ok(%c=sReadConfAdv2('ex2.conf','=tSTART','=tSTOP',1,'=')) ;
close STDERR ;