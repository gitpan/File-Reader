package File::Reader;

use 5.006001;
use strict;
use warnings;
use Term::ANSIColor;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use File::Reader ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	&Write &listDir &Read &ReWrite &ReadConfAdv &ReadConf &sReWrite &sWrite &sRead &sReadConf &sReadConfAdv &ReadConfAdv2 &sReadConf2 &sReadConfAdv2 &ReadConf2 &generateConfFile &WriteConf
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.8';

sub WriteConf
{
	my ($file,%conf) = @_;
	my @ff=();
	unlink $file;
	foreach my $key (keys(%conf))
	{
		chomp $conf{$key};
		push @ff, "$key = $conf{$key}\n";
	}
	Write($file,@ff);
}

sub Write
{
	my ($name,@data)=@_;
	if(open (FILE, ">$name"))
	{
		foreach my $a (@data)
		{
			print FILE $a;
		}
		close (FILE);
	}
	else
	{
		warn "[ File::Reader ] unable to write '$name' : $!\n";
		return undef;
	}
	return 1;
}
sub Read
{
        my ($nom_fichier)=@_;
	unless ( -e $nom_fichier or -R $nom_fichier)
	{
		warn "[ File::Reader ] unable to read $nom_fichier : $!\n";
		return undef ;
	}
        my $tmp="";
        my $p=0;
	my @file=();
        open (F2,"<$nom_fichier");
        while (defined($tmp=<F2>))
        {
                #chomp $tmp;
		unless($tmp=~ /^$/)
		{
                	$file[$p]=$tmp;
		}
		else
		{
			$file[$p]="\n";
		}
                $p++;
        }
        close (F2);
        return (@file);
}
sub ReWrite
{
        my ($name,@data)=@_;
        open (FILE, ">>$name");
	foreach my $a (@data)
	{
        	print FILE $a;
	}
        close (FILE);
}

sub supprComment
{
	my ($line)=@_;
	my ($real_line,$comment)=split(/#/,$line);
	return $real_line;
}

sub findStartTag
{
	my ($r_tab,$start_tag)=@_;
	my $k=0;
	while (defined(my $tmp=$$r_tab[$k]))
	{
		chomp $tmp;
		#print "[ findStartTag ] : \$tmp = '$tmp' et \$start_tag = '$start_tag'\n";
		if ($tmp eq $start_tag)
		{
			$k++;
			return $k;
		}
		$k++;
	}
	return undef;
}
sub ReadConfAdv2
{
	my ($conf_fln,$conf_start,$conf_stop,$sep)=@_;
	#print "[ File::Reader dev Tracer ]\n\$conf_fln : $conf_fln\n\$conf_start : $conf_start\n\$conf_stop : $conf_stop\n";
	unless ( -e $conf_fln or -R $conf_fln)
	{
		warn "[ File::Reader ] unable to read $conf_fln : $!\n";
		return undef ;
	}
	my @cfg=Read("$conf_fln");
	my $k=0;
	my $fin='non';
	my %conf=();
	$k=findStartTag(\@cfg,$conf_start);
	unless (defined($k))
	{
		return 0;
	}
	while ($fin eq 'non')
	{
		#print "$k\n";
		if (defined($cfg[$k]))
		{
			unless ($cfg[$k]=~ /^$/i)
			{
				$cfg[$k]=supprComment($cfg[$k]);
				$cfg[$k]=~ s/\s?$sep\s?/$sep/;
				chomp $cfg[$k] ;
				if ($cfg[$k] eq $conf_stop)
				{
					$fin='oui';
					return %conf;
				}
				if ($cfg[$k]=~ /$sep/i && $cfg[$k] ne $conf_start)
				{
						my ($key,$value)=split(/$sep/,$cfg[$k]);
						#print "'$key' : '$value'\n";
						$conf{$key}=$value;
				}
			}
		}
		$k++;
		if ($k>=$#cfg)
		{
			$fin='oui';
		}
	}
	return %conf;
}

sub ReadConfAdv
{
	my ($conf_fln,$conf_start,$conf_stop) = @_ ;
	#print "[ Battosai dev Tracer ]\n\$conf_fln : $conf_fln\n\$conf_start : $conf_start\n\$conf_stop : $conf_stop\n";
	unless ( -e $conf_fln or -R $conf_fln)
	{
		warn "[ File::Reader ] unable to read $conf_fln : $!\n";
		return undef ;
	}
	my @cfg=Read("$conf_fln");
	my $k=0;
	my $fin='non';
	my %conf=();
	$k=findStartTag(\@cfg,$conf_start);
	unless (defined($k))
	{
		#print "[ UNLESS ] \$k => $k\n";
		return undef;
	}
	while ($fin eq 'non')
	{
		#print "$k\n";
		if (defined($cfg[$k]))
		{
			unless ($cfg[$k]=~ /^$/i)
			{
				$cfg[$k]=supprComment($cfg[$k]);
				$cfg[$k]=~ s/\s?=\s?/=/;
				chomp $cfg[$k] ;
				#print "  + $cfg[$k]\n" ;
				if ($cfg[$k] eq $conf_stop)
				{
					$fin='oui';
					return %conf;
				}
				elsif ($cfg[$k]=~ /=/i && $cfg[$k] ne $conf_start)
				{
						my ($key,$value)=split(/=/,$cfg[$k]);
						#print "\t=> '$key' : '$value'\n";
						$conf{$key}=$value;
				}
			}
		}
		$k++;
		if ($k>=$#cfg)
		{
			$fin='oui';
		}
	}
	return %conf;
}
sub ReadConf
{
	my ($conf_fln)=@_;
	unless ( -e $conf_fln or -R $conf_fln)
	{
		warn "[ File::Reader ] unable to read $conf_fln : $!\n";
		return undef ;
	}
	my @cfg=Read("$conf_fln");
	my %conf=();
	for (my $k=0;$k<=$#cfg;$k++)
	{
		unless ($cfg[$k]=~ /^$/i)
		{
			$cfg[$k]=~ s/\s?=\s?/=/;
			my @tmp=split(//,$cfg[$k]);
			if ($tmp[0] ne '#')
			{
				$cfg[$k]=supprComment($cfg[$k]);
				my($key,$value)=split(/=/,"$cfg[$k]");
				$conf{$key}=$value;
			}
		}
	}
	return %conf;
}

sub ReadConf2
{
	my ($conf_fln,$sep)=@_;
	unless ( -e $conf_fln or -R $conf_fln)
	{
		warn "[ File::Reader ] unable to read $conf_fln : $!\n";
		return undef ;
	}
	my @cfg=Read("$conf_fln");
	my %conf;
	for (my $k=0;$k<=$#cfg;$k++)
	{
		unless ($cfg[$k]=~ /^$/i)
		{
			$cfg[$k]=~ s/\s?$sep\s?/$sep/;
			my @tmp=split(//,$cfg[$k]);
			if ($tmp[0] ne '#')
			{
				$cfg[$k]=supprComment($cfg[$k]);
				my($key,$value)=split(/$sep/,"$cfg[$k]");
				$conf{$key}=$value;
			}
		}
	}
	return %conf;
}

sub listDir
{

	my ($dir)=@_;
	if (! -e $dir )
	{
		print "[ File::Reader ] Unknow directory ($dir).";
		return undef;
 	}
	if (! -d $dir )
	{
	 	print "[ File::Reader ] $dir is not a directory.";
	 	return undef;
	}
	if (! opendir( DIR, $dir) )
	{
	 	print "[ File::Reader ] Cannot open directory $dir : $!.";
	 	return undef;
	}
	my @files = grep !/(?:^\.$)|(?:^\.\$)/, readdir DIR;
	closedir DIR;

	return @files;
}

sub sWrite
{
	# TODO : support de @data dans sWrite et sReWrite
	my ($name,@data,$warning)=@_;
	my ($dev,$ino,$mode,$nmink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)=stat($name);
	if (defined($warning) && $warning == 0)
	{
		open(STDERR, ">>error_battosai.log") or warn "[ File::Reader ] Unable to redirect the standart output\n";
	}
	warn "[ CHECKING FOR : $name ]\n";
	unless ( -e $name)
	{
		warn "[ ",color('yellow'),"WARN",color('reset')," ] File doesn't exist !\n";
		#return undef;
	}
	else
	{
		warn "[ ",color('green'),"OK",color('reset')," ] File Exist.\n";
	}
	unless ( -f $name)
	{
		warn "[ ",color('yellow'),"WARN",color('reset')," ] Parameter not seems to be an ordinary file (maybe it's a link or a directory) !\n";
	}
	else
	{
		warn "[ ",color('green'),"OK",color('reset')," ] Parameter seems to be an ordinary file.\n";
	}
	if (defined($uid) && $< ne $uid)
	{
		warn "[ ",color('yellow'),"WARN",color('reset')," ] You're not the owner of the file !\n";
		if (defined($gid) && $( ne $gid)
		{
			warn "[ ",color('yellow'),"WARN",color('reset')," ] You're not in the file's owner's group !\n";
			unless ( -R $name)
			{
				warn "[ ",color('yellow'),"WARN",color('reset')," ] You dont' have the read permission for this file  !\n";
			}
			else
			{
				warn "[ ",color('green'),"OK",color('reset')," ] You have the read permission for this file.\n";
			}
			unless ( -W $name)
			{
				warn "[ ",color('red'),"DIE",color('reset')," ] You don't have the write permission for this file !\n";
				return undef;
			}
			else
			{
				warn "[ ",color('green'),"OK",color('reset')," ] You have the write permission for this file.\n";
			}
		}
		else
		{
			warn "[ ",color('green'),"OK",color('reset')," ] You are in the file's owner's group.\n";
		}
	}
	else
	{
		warn "[ ",color('green'),"OK",color('reset')," ] You are the owner of this file.\n";
	}
	if ( -u $name)
	{
		warn "[ ",color('yellow'),"WARN",color('reset')," ] The file is setuid !\n";
	}
	if ( -g $name)
	{
		warn "[ ",color('yellow'),"WARN",color('reset')," ] The file is setgid !\n";
	}
	if ( -B $name)
	{
		warn "[ ",color('yellow'),"WARN",color('reset')," ] The file is a Binary one !";
	}
	open(DATA,">$name");
	if(flock DATA, 2)
	{
		warn "[ ",color('green'),"OK",color('reset')," ] The lock (flock) seems to be activate without problem.\n";
	}
	else
	{
		warn "[ ",color('red'),"DIE",color('reset')," ] The lock (flock) cannot be activate !\n";
		return undef;
	}
	foreach my $p (@data)
	{
		unless (print DATA $p)
		{
			warn "[ ",color('red'),"DIE",color('reset')," ] Unable to write data in the file\n";
			return undef;
		}
	}
	warn "[ ",color('green'),"OK",color('reset')," ] Data are written without problem.\n";
	if(flock DATA, 8)
	{
		warn "[ ",color('green'),"OK",color('reset')," ] The lock (flock) seems to be disactivate without problem.\n";
	}
	else
	{
		warn "[ ",color('yellow'),"WARN",color('reset')," ] The lock (flock) cannot be disactivate !\n";
	}
	close (DATA);
	if (defined($warning) && $warning == 0)
	{
		close (STDERR);
	}
	return 1;
}

sub sReWrite
{
	my ($name,@data,$warning)=@_;
	my ($dev,$ino,$mode,$nmink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)=stat($name);
	if (defined($warning) && $warning == 0)
	{
		open(STDERR, ">>error_battosai.log") or warn "[ File::Reader ] Unable to redirect the standart output\n";
	}
	warn "[ CHECKING FOR : $name ]\n";
	unless ( -e $name)
	{
		warn "[ ",color('yellow'),"WARN",color('reset')," ] File doesn't exist !\n";
		#return undef;
	}
	else
	{
		warn "[ ",color('green'),"OK",color('reset')," ] File Exist.\n";
	}
	unless ( -f $name)
	{
		warn "[ ",color('yellow'),"WARN",color('reset')," ] Parameter not seems to be an ordinary file (maybe it's a link or a directory) !\n";
	}
	else
	{
		warn "[ ",color('green'),"OK",color('reset')," ] Parameter seems to be an ordinary file.\n";
	}
	if (defined($uid) && $< ne $uid)
	{
		warn "[ ",color('yellow'),"WARN",color('reset')," ] You're not the owner of the file !\n";
		if (defined($gid) && $( ne $gid)
		{
			warn "[ ",color('yellow'),"WARN",color('reset')," ] You're not in the file's owner's group !\n";
			unless ( -R $name)
			{
				warn "[ ",color('yellow'),"WARN",color('reset')," ] You dont' have the read permission for this file  !\n";
			}
			else
			{
				warn "[ ",color('green'),"OK",color('reset')," ] You have the read permission for this file.\n";
			}
			unless ( -W $name)
			{
				warn "[ ",color('red'),"DIE",color('reset')," ] You don't have the write permission for this file !\n";
				return undef;
			}
			else
			{
				warn "[ ",color('green'),"OK",color('reset')," ] You have the write permission for this file.\n";
			}
		}
		else
		{
			warn "[ ",color('green'),"OK",color('reset')," ] You are in the file's owner's group.\n";
		}
	}
	else
	{
		warn "[ ",color('green'),"OK",color('reset')," ] You are the owner of this file.\n";
	}
	if ( -u $name)
	{
		warn "[ ",color('yellow'),"WARN",color('reset')," ] The file is setuid !\n";
	}
	if ( -g $name)
	{
		warn "[ ",color('yellow'),"WARN",color('reset')," ] The file is setgid !\n";
	}
	if ( -B $name)
	{
		warn "[ ",color('yellow'),"WARN",color('reset')," ] The file is a Binary one !";
	}
	unless(open(DATA,">>$name"))
	{
		warn "[ ",color('red'),"DIE",color('reset')," ] unable to open a filehandle for '$name' : $!\n";
		return undef;
	}
	if(flock DATA, 2)
	{
		warn "[ ",color('green'),"OK",color('reset')," ] The lock (flock) seems to be activate without problem.\n";
	}
	else
	{
		warn "[ ",color('red'),"DIE",color('reset')," ] The lock (flock) cannot be activate !\n";
		return undef;
	}
	foreach my $p (@data)
	{
		unless (print DATA $p)
		{
			warn "[ ",color('red'),"DIE",color('reset')," ] Unable to write data in the file\n";
			return undef;
		}
	}
	warn "[ ",color('green'),"OK",color('reset')," ] Data are written without problem.\n";
	if(flock DATA, 8)
	{
		warn "[ ",color('green'),"OK",color('reset')," ] The lock (flock) seems to be disactivate without problem.\n";
	}
	else
	{
		warn "[ ",color('yellow'),"WARN",color('reset')," ] The lock (flock) cannot be disactivate !\n";
	}
	close (DATA);
	if (defined($warning) && $warning == 0)
	{
		close (STDERR);
	}
	return 1;
}
sub sRead
{
	my ($name,$warning,$level)=@_;
	# There is 3 level of security :
	# 0 : (welcome hackers !) No real security on the $name variable
	# 1 : (Medium security) All the escape shell caracters are escaped (&|; etc.)
	# 2 : (paranoid) All the escape shell caracters are delete !
	# If you use Battosai in CGI it's really recommend to use the lvl 2
	#Default is 1
	unless (defined($level))
	{
		print "[ sRead ] security level not specified ! I use the default level 1.\n";
		$level=1;
	}
	if($level == 1)
	{
		$name=~ s/([;\*\|`&\$!#\(\)\[\]\{\}:'"])\&\;\\0/\\$1/g;
	}
	elsif($level == 2)
	{
		$name=~ s/([;\*\|`&\$!#\(\)\[\]\{\}:'"])\&\;\\0//g;
	}
	elsif($level == 0)
	{
		print "[ sRead ] It's really dangerous to use the sRead function without security !\n";
	}
	else
	{
		print "[ sRead ] The security level cannot be recognize !\nQUITTING Battosai\n";
		exit;
	}
	my ($dev,$ino,$mode,$nmink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)=stat($name);
	if ($warning == 0)
        {
                open(STDERR, ">>error_battosai.log") or warn "Unable to redirect the standart output\n";
        }
        warn "[ CHECKING FOR : $name ]\n";
        unless ( -e $name)
        {
                warn "[ ",color('red'),"DIE",color('reset')," ] File doesn't exist !\n";
                return undef;
        }
        else
        {
                warn "[ ",color('green'),"OK",color('reset')," ] File Exist.\n";
                unless ( -f $name)
                {
                        warn "[ ",color('red'),"DIE",color('reset')," ] Parameter not seems to be an ordinary file (maybe it's a link or a directory) !\n";
                        return undef;
                }
                else
                {
                        warn "[ ",color('green'),"OK",color('reset')," ] Parameter seems to be an ordinary file.\n";
                }
        }
	if ($< eq $uid)
        {
		warn "[ ",color('green'),"OK",color('reset')," ] You're the owner of the file.\n";
	}
	else
	{
		warn "[ ",color('red'),"DIE",color('reset')," ] You're not the owner of the file !\n";
		if ($( ne $gid)
        	{
        	        warn "[ ",color('red'),"DIE",color('reset')," ] You're not in the file's owner's group !\n";
        	        return undef;
        	}
        	else
        	{
        	        warn "[ ",color('green'),"OK",color('reset')," ] You're in the file's owner's group  !\n";
        	}
	}
	unless ( -R $name)
	{
		warn "[ ",color('red'),"DIE",color('reset')," ] You don't have the read permission on the file !\n";
		return undef;
	}
	else
	{
		warn "[ ",color('green'),"OK",color('reset')," ] You have the read permission on the file.\n";
	}
	        if ( -u $name)
        {
                warn "[ ",color('yellow'),"WARN",color('reset')," ] The file is setuid !\n";
        }
        if ( -g $name)
        {
                warn "[ ",color('yellow'),"WARN",color('reset')," ] The file is setgid !\n";
        }
        if ( -B $name)
        {
                warn "[ ",color('yellow'),"WARN",color('reset')," ] The file is a Binary one !";
        }
	my $tmp="";
        my $p=0;
        my @file=();
        if (open (F2,$name))
	{
		warn "[ ",color('green'),"OK",color('reset')," ] I can open file.\n";
	}
	else
	{
		warn "[ ",color('red'),"DIE",color('reset')," ] I cannot open file.\n";
		return undef;
	}
        if(flock F2, 2)
        {
                warn "[ ",color('green'),"OK",color('reset')," ] The lock (flock) seems to be activate without problem.\n";
        }
        else
        {
                warn "[ ",color('red'),"DIE",color('reset')," ] The lock (flock) cannot be activate !\n";
                return undef;
        }

        while (defined($tmp=<F2>))
        {
                chomp $tmp;
		unless ($tmp=~ /^$/)
		{
                	$file[$p]=$tmp;
                	$p++;
		}
        }
	if(flock F2, 8)
        {
                warn "[ ",color('green'),"OK",color('reset')," ] The lock (flock) seems to be disactivate without problem.\n";
        }
        else
        {
                warn "[ ",color('yellow'),"WARN",color('reset')," ] The lock (flock) cannot be disactivate !\n";
        }

        close (F2);
	if ($warning == 0)
	{
		close STDERR;
	}
        return (@file);
}
sub sReadConf
{
	my ($conf_fln,$level)=@_;
	unless ( -e $conf_fln && -R $conf_fln)
	{
		warn "[ File::Reader ] unable to read $conf_fln : $!\n";
		return undef ;
	}
	my @cfg=sRead("$conf_fln",1,$level);
	my %conf=();
	unless (defined($cfg[0]))
	{
		print "An error has occured in the openning of $conf_fln ! \n QUITTING\n";
		exit;
	}
	for (my $k=0;$k<=$#cfg;$k++)
	{
		unless ($cfg[$k]=~ /^$/i)
		{
			$cfg[$k]=~ s/\s?=\s?/=/;
			my @tmp=split(//,$cfg[$k]);
			if ($tmp[0] ne '#')
			{
				$cfg[$k]=supprComment($cfg[$k]);
				my($key,$value)=split(/=/,"$cfg[$k]");
				$conf{$key}=$value;
			}
		}
	}
	return %conf;
}

sub sReadConf2
{
	my ($conf_fln,$level,$sep)=@_;
	unless ( -e $conf_fln && -R $conf_fln)
	{
		warn "[ File::Reader ] unable to read $conf_fln : $!\n";
		return undef ;
	}
	my @cfg=sRead("$conf_fln",1,$level);
	my %conf=();
	unless (defined($cfg[0]))
	{
		print "An error has occured in the openning of $conf_fln ! \n QUITTING\n";
		exit;
	}
	for (my $k=0;$k<=$#cfg;$k++)
	{
		unless ($cfg[$k]=~ /^$/i)
		{
			$cfg[$k]=~ s/\s?$sep\s?/$sep/;
			my @tmp=split(//,$cfg[$k]);
			if ($tmp[0] ne '#')
			{
				$cfg[$k]=supprComment($cfg[$k]);
				my($key,$value)=split(/$sep/,"$cfg[$k]");
				$conf{$key}=$value;
			}
		}
	}
	return %conf;
}

sub sReadConfAdv
{
	my ($conf_fln,$conf_start,$conf_stop,$level)=@_;
	#print "TRACER : \nconf_fln=$conf_fln\nconf_start=$conf_start\nconf_stop=$conf_stop\nlevel=$level\n";
	unless ( -e $conf_fln && -R $conf_fln)
	{
		warn "[ File::Reader ] unable to read $conf_fln : $!\n";
		return undef ;
	}
	my @cfg=sRead("$conf_fln",1,$level);
	unless (defined($cfg[0]))
	{
		print "An error has occured in the openning of $conf_fln ! \n QUITTING\n";
		exit;
	}
	my $k=0;
	my $fin='non';
	my %conf=();
	$k=findStartTag(\@cfg,$conf_start);
	unless (defined($k))
	{
		return 0;
	}
	while ($fin eq 'non')
	{
		#print "$k\n";
		if (defined($cfg[$k]))
		{
			unless ($cfg[$k]=~ /^$/i)
			{
				$cfg[$k]=supprComment($cfg[$k]);
				$cfg[$k]=~ s/\s?=\s?/=/;
				chomp $cfg[$k] ;
				if ($cfg[$k] eq $conf_stop)
				{
					$fin='oui';
					return %conf;
				}
				if ($cfg[$k]=~ /=/i && $cfg[$k] ne $conf_start)
				{
						my ($key,$value)=split(/=/,$cfg[$k]);
						#print "'$key' : '$value'\n";
						$conf{$key}=$value;
				}
			}
		}
		$k++;
		if ($k>=$#cfg)
		{
			$fin='oui';
		}
	}
	return %conf;
}
sub sReadConfAdv2
{
	my ($conf_fln,$conf_start,$conf_stop,$level,$sep)=@_;
	unless ( -e $conf_fln && -R $conf_fln)
	{
		warn "[ File::Reader ] unable to read $conf_fln : $!\n";
		return undef ;
	}
	my @cfg=sRead("$conf_fln",1,$level);
	unless (defined($cfg[0]))
	{
		print "An error has occured in the openning of $conf_fln ! \n QUITTING\n";
		return 0;
	}
	#print "[ Battosai dev Tracer ]\n\$conf_fln : $conf_fln\n\$conf_start : $conf_start\n\$conf_stop : $conf_stop\n";
	my $k=0;
	my $fin='non';
	my %conf=();
	$k=findStartTag(\@cfg,$conf_start);
	unless (defined($k))
	{
		return 0;
	}
	while ($fin eq 'non')
	{
		#print "$k\n";
		if (defined($cfg[$k]))
		{
			unless ($cfg[$k]=~ /^$/i)
			{
				$cfg[$k]=supprComment($cfg[$k]);
				if (defined($cfg[$k]) && $cfg[$k] !~ /^$/i)
				{
					$cfg[$k]=~ s/\s?$sep\s?/$sep/;
					chomp $cfg[$k] ;
					if ($cfg[$k] eq $conf_stop)
					{
						$fin='oui';
						return %conf;
					}
					if ($cfg[$k]=~ /$sep/i && $cfg[$k] ne $conf_start)
					{
							my ($key,$value)=split(/$sep/,$cfg[$k]);
							#print "'$key' : '$value'\n";
							$conf{$key}=$value;
					}
				}
			}
		}
		$k++;
		if ($k>=$#cfg)
		{
			$fin='oui';
		}
	}
	return %conf;
}

sub generateConfFile
{
	my ($pgmName,$confName) = @_ ;
	unless(defined($pgmName))
	{
		warn "[ File::Reader ] first parameter not defined (original Perl source name).\n" ;
		return undef ;
	}
	unless (-e $pgmName)
	{
		warn "[ File::Reader ] $pgmName doeesn't exist !\n" ;
		return undef ;
	}
	my $finalName = $pgmName ;
	if ($pgmName =~ /\.pl/)
	{
		$finalName =~ s/\.pl/_withconf.pl/;
	}
	else
	{
		$finalName .= '_withconf';
	}
	my @tab = Read($pgmName) ;
	my @final = () ;
	Write($confName,"## Configuration file for $pgmName generated by File::Reader version $File::Reader::VERSION\n\n");
	foreach my $a (@tab)
	{
		if ($a =~ /#!.*perl.*/)
		{
			#print "[ MATCH PERL ] $a\n";
			$a .= "\n\nuse File::Reader qw( ReadConf );\n\nmy \%conf = ReadConf('$confName');\n\n";
			push @final, $a;
		}
		elsif ($a =~ /^.*\$[A-Z_]*\s*={1}.*$/)
		{
			if($a !~ /^.*==.*$/ or $a !~ /^.*=~.*$/)
			{
				my $tmp = $a ;
				$a=~ s/^my //;
				$a=~ s/^our //;
				$a=~ s/;$//;
				$a=~ s/^\$//;
				my ($t1,$t2) = split(/=/,$a) ;
				#print "[ == ]$tmp\n";
				ReWrite($confName,"$a\n");
				$t1 =~ s/\s//g;
				my ($t3,$t4) = split(/=/,$tmp);
				$tmp = "$t3 = \$conf{$t1} ;\n" ;
				push @final, $tmp;
			}
			else
			{
				#print "[ != ] $a\n";
				push @final, $a;
			}
		}
		else
		{
			#print "[ else ] $a\n" ;
			push @final, $a;
		}
	}
	Write($finalName,@final);
}

## The following functions are for backward compatibility with the old's Battosai syntax

sub ouvre
{
	my ($name) = @_ ;
	Read($name);
}

sub ecrire
{
	my ($name,@data) = @_ ;
	Write($name,@data);
}
sub reecrire
{
	my ($name,@data) = @_ ;
	ReWrite($name,@data);
}
sub lireConfAdv2
{
	my ($conf_fln,$conf_start,$conf_stop,$sep)=@_;
	ReadConfAdv2($conf_fln,$conf_start,$conf_stop,$sep);
}

sub lireConfAdv
{
	my ($conf_fln,$conf_start,$conf_stop)=@_;
	ReadConfAdv($conf_fln,$conf_start,$conf_stop) ;
}
sub lireConf
{
	my ($conf_fln)=@_;
	ReadConf($conf_fln);
}

sub lireConf2
{
	my ($conf_fln,$sep)=@_;
	ReadConf2($conf_fln,$sep);
}

sub listRep
{

	my ($dir) = shift ;
	listDir($dir) ;
}
sub sReecrire
{
	my ($name,$data,$warning)=@_;
	sReWrite($name,$data,$warning);
}
sub sOuvre
{
	my ($name,$warning,$level)=@_;
	sRead($name,$warning,$level);
}
sub sLireConf
{
	my ($conf_fln,$level)=@_;
	sReadConf($conf_fln,$level);
}

sub sLireConf2
{
	my ($conf_fln,$level,$sep)=@_;
	sReadConf2($conf_fln,$level,$sep);
}

sub sLireConfAdv
{
	my ($conf_fln,$conf_start,$conf_stop,$level)=@_;
	sReadConfAdv($conf_fln,$conf_start,$conf_stop,$level);
}
sub sLireConfAdv2
{
	my ($conf_fln,$conf_start,$conf_stop,$level,$sep)=@_;
	sReadConfAdv2($conf_fln,$conf_start,$conf_stop,$level,$sep);
}
return 1;
END{}

__END__

# And now ladies and gentlemen...The documentation !!!!

=head1 NAME

File::Reader - Perl extension for Read and write easily text file

=head1 SYNOPSIS

	use File::Reader qw( Write Read ReadConf ReWrite );
	@myArray = Read('/home/arnaud/.bashrc');
	@mysArray = sRead('/home/arnaud/.bashrc',1,2);
	$file = '/home/arnaud/write_by_File_Reader ;
	$message = "Something to write\n" ;
	Write($file, $message) ;
	@message=("something", "to", "write", "\n");
	Write($file, @message) ;
	sWrite($file,"Something to write\n",1,2) ;
	%conf_file = ReadConf('/etc/file.conf') ;
	
	# A simple example for reading, using and writing config file
	my %CONF = ReadConf('/etc/mysoft/soft.conf');
	$CONF{'data-dir'} = '/tmp/'.$CONF{'data-dir'};
	WriteConf('/etc/mysoft/soft.conf',%CONF);


=head1 DESCRIPTION

=head3 Write :

	Write(file_to_write, data_to_write) : this function write some data in a file. You can call it like that : Write($file, @data) ;

=head3 WriteConf(file_to_write, %data_to_write) : this function write all data contains in %data_to_write into the file file_to_write in a format readable by ReadConf (key = value).

=head3 Read :

	Read("file_to_read") : read all data in "file_to_read". B<IMPORTANT> file is read just as it is ! Don't forget to treat data incomming :-). 
	Read() return B<undef> if the file that you try to open does not exist.

=head3 ReWrite :

	ReWrite(file_to_write, data_to_write) : write data in the end of "file_to_write". If file does not exist ReWrite() create him. 
	The function don't erase the original file. To really re-write a file (erase and write it) use Write().

=head3 ReadConf :

	ReadConf("some_configuration_file") : Read a configuration file (wich is write like : key = value) and return a hash (usable by : $conf{key}). ReadConf() return B<undef> if the file that you try to read does not exist.

=head3 ReadConf2 :

	ReadConf2("some_configuration_file","separator") : same as ReadConf() but you can specify the separator to use in the configuration file.


	configuration file :
	
		key1 :: value1
		key2 :: value2
	
	usable with the code :
	
		%conf = ReadConf2("configuration_file",'::') ;
		print "$conf{key1}\n" ;

=head3 ReadConfAdv :

	ReadConfAdv($conf_fln,$conf_start,$conf_stop) : with this function you can use only one configuration file for several applications by putting separating beacons of section.

	Ex : %conf = ReadConfAdv("conf_file",'<start-tag>','<stop-tag>') ;

	work with a configuration file like :

		<start-tag>
		key1 = value1
		key2 = value2
		<stop-tag>
		[other-start]
		key3 = value3
		[other-stop]


=head3 ReadConfAdv2 :

	ReadConfAdv2($conf_fln,$conf_start,$conf_stop,$level,$sep) : same options that ReadConfAdv() but you can specify, moreover,
	 the separator of the pairs of keys/values in the configuration file (like ReadConf2() ).

=head3 listDir :

	listDir("any_directory/" : return a table containing the contents of "any_directory/"

	Ex : @dir = listDir("/etc/") ;


=over 8


=item * The following function (s*) are the "secure" version of previous functions. They make somes tests on files before reading and writing them.

=back

=head3 sReWrite :

	sReWrite($name,$data,$warning) : if you set $warning to 1 (default) File::Reader print test on STDERR. If $warning = 0, STDERR is redirected to file_reader_err.log.

=head3 sWrite :

	sWrite($name,$data,$warning) : same as sReWrite() but with Write() functionality.

=head3 sRead :

	sRead($name,$warning,$level) : see sReWrite() for explanations relating to $warning. $level can have several values :

		0 : (welcome hackers !) No real security on the $name variable
		1 : (Medium security) All escape shell characters are escaped (&|; etc.)
		2 : (paranoid) All escape shell caracters are deleted !
	If you use File::Reader in CGI it's strongly recommended to use the lvl 2.
	Default is 1

=head3 sReadConf :

	sReadConf($conf_fln,$level) : see above for explanations relating to $level

=head3 sReadConfAdv :

	sReadConfAdv($conf_fln,$conf_start,$conf_stop,$level) : see above for explanations relating to $level, $conf_start and $conf_stop

=head3 sReadConf2

	sReadConf2($conf_fln,$level,$sep) : see above for explanations relating to $level and $sep

=head3 sReadConfAdv2

	sReadConfAdv2($conf_fln,$conf_start,$conf_stop,$level,$sep) : see above for explanations relating to $conf_start, $conf_stop, $level and $sep

=head3 generateConfFile

	generateConfFile("perl_source","conf_file_name") : Generate a configuration file (named "conf_file_name") for "perl_source". 
	Moreover it re-write "perl_source" to support the new configuration file. 
	The original source is not changed. A new file is created, named "perl_source_withconf".
	The modified variables are those in upper case (as $VERSION).

	Ex :  Perl source file (donothing.pl) :

		#!/usr/bin/perl -w
		$VERSION = 1.0 ;
		$ETC_DIR = '/etc/' ;
		$var_dir = '/var/' ;
		print "my Version -> $VERSION, my etc directory -> $ETC_DIR and my var directory -> $var_dir\n" ;

	Now in another Perl script (gen_conf.pl wich usable in this tarball) :
		#!/usr/bin/perl -w
		use File::Reader qw( generateConfFile ) ;
		generateConfFile("donothing.pl","donothing.conf") ;

	And after execution (it may takesome time if the "perl_source" is important) you could see 2 new file in the directory : donothing.conf and do nothing_withconf.pl.

	donothing_withconf.pl source code :

		#!/usr/bin/perl -w
		use File::Reader qw (ReadConf ) ;
		my %conf = ReadConf("donothing.conf");
		$VERSION = $conf{VERSION} ;
		$ETC_DIR = '$conf{ETC_DIR};
		$var_dir = '/var/' ;
		print "my Version -> $VERSION, my etc directory -> $ETC_DIR and my var directory -> $var_dir\n" ;

	And donothing.conf :

		## Configuration file for donothing.pl generated by File::Reader version 0.6
		VERSION = 1.0
		ETC_DIR = '/etc/'

=head2 EXPORT

None by default.

use File::Reader qw ( sWrite sReadConf ) ; # Export the two functions sWrite() and sReadConf().

=head1 COMPATIBILITY

You can assume the compatibility with the old syntax of Battosai by :

use File::Reader qw ( ecrire ouvre reecrire lireConfAdv lireConf listRep sReecrire sOuvre sLireConf sLireConfAdv lireConfAdv2 sLireConf2 sLireConfAdv2 lireConf2 ) ;

But this method is I<deprecated>. Moreover new function will B<never profit> from binding for old syntax.

The old syntax is no longer support.

=head1 AUTHOR

Arnaud DUPUIS, E<lt>arno@asocial.orgE<gt>

=head1 COPYRIGHT AND LICENCE

Copyright (c) 2004 Arnaud DUPUIS E<lt>a.dupuis@infinityperl.orgE<gt>. All rights reserved.
This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<perl>

=cut
