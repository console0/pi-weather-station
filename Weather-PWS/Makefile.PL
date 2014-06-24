use 5.010000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Weather::PWS',
    VERSION_FROM      => 'lib/Weather/PWS.pm', # finds $VERSION
    PREREQ_PM         => { 'DateTime' => 0, 'Math::BigFloat' => 0 }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Weather/PWS.pm', # retrieve abstract from module
       AUTHOR         => 'Marcus Slagle <mslagle@whapps.com>') : ()),
);
