#!/usr/bin/perl -w

my $VERSION = 0.1 ;
$PORT = 1337 ;
our $PROTO = 'tcp';
my $PORT_CONNECT = 80 ;

my @test = ($VERSION,$PORT,$PROTO) ;

for ($k=0 ; $k <= $#test; $k++)
{
	print "[+] $test[$k]\n";
}