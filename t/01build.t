use strict;
use warnings;
use ZMQ::Declare qw(:all);
use File::Spec;
use Test::More;

my $datadir = -d 't' ? File::Spec->catdir(qw(t data)) : "data";

my $testspec = File::Spec->catfile($datadir, 'simple.zspec');
ok(-f $testspec)
  or die "Missing test file";

my $spec = ZMQ::Declare::Spec->new(tree => $testspec);
isa_ok($spec, "ZMQ::Declare::Spec");

done_testing();
