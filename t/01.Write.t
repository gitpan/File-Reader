use Test::More tests => 3;
use File::Reader qw( Write );

my $test="this is only a test !\n" ;
my $source = "#!/usr/bin/perl -w\n\nmy \$VERSION = 0.1 ;\n\$PORT = 1337 ;\nour \$PROTO = 'tcp';\nmy \$PORT_CONNECT = 80 ;\n\nmy \@test = (\$VERSION,\$PORT,\$PROTO) ;\n\nfor (\$k=0 ; \$k <= \$#test; \$k++)\n{\n\tprint \"[+] \$test[\$k]\\n\";\n}\n";
my $conf = "=tSTART\ntest1 = ok\ntest2 = is it ok ?\n=tSTOP\n\n<start>\ntest3 = test is boring\ntest4 = really ?\n<stop>\n";
open STDERR, ">>/dev/null" ;
ok(Write('Testing',$test)) ;
ok(Write('PerlSource',$source)) ;
ok(Write('ex2.conf',$conf)) ;
close STDERR ;