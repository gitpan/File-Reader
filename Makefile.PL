use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'File::Reader',
    AUTHOR              => 'Arnaud DUPUIS <a.dupuis@infinityperl.org>',
    VERSION_FROM        => 'lib/File/Reader.pm',
    ABSTRACT_FROM       => 'lib/File/Reader.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'File-Reader-*' },
);
