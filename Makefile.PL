use 5.008001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'ZeroMQ::Declare',
    VERSION_FROM      => 'lib/ZeroMQ/Declare.pm', # finds $VERSION
    PREREQ_PM         => {
      'ZeroMQ' => '0',
      'Scalar::Util' => '0',
      'Class::XSAccessor' => '1.12',
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/ZeroMQ/Declare.pm', # retrieve abstract from module
       AUTHOR         => 'Steffen Mueller <smueller@cpan.org>') : ()),
);
