#!/usr/bin/perl

use warnings;
use strict;
use File::Reader qw( generateConfFile ) ;

unless(defined($ARGV[0]) && defined($ARGV[0]))
{
	printf("
	Usage : $0 <source_file.pl> <destination_config_file.conf>
	");
}
else
{
	if(-e $ARGV[0])
	{
		generateConfFile($ARGV[0],$ARGV[1]) ;
	}
	else
	{
		print "$ARGV[0] : no such file.\n";
		exit(-1);
	}
}