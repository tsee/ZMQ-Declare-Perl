use 5.008001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'ZMQ::Declare',
    VERSION_FROM      => 'lib/ZMQ/Declare.pm', # finds $VERSION
    PREREQ_PM         => {
      'ZeroMQ' => '0',
      'Scalar::Util' => '0',
      'Moose' => '0',
      'Carp' => '0',
      'JSON' => '0',
      'lib' => '0',
      'File::Spec' => '0',
      'Test::More' => '0.88',
      'autodie' => '0',
      'Data::Dumper' => '0',
      'Clone' => '0',
      'parent' => '0',
      'Storable' => '0',
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/ZMQ/Declare.pm', # retrieve abstract from module
       AUTHOR         => 'Steffen Mueller <smueller@cpan.org>') : ()),
);
