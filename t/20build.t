use strict;
use warnings;
use ZMQ::Declare qw(:all);
use File::Spec;
use Test::More;

my $datadir = -d 't' ? File::Spec->catdir(qw(t data)) : "data";

my $testzdcf = File::Spec->catfile($datadir, 'simple.zdcf');
ok(-f $testzdcf)
  or die "Missing test file";

my $zdcf = ZMQ::Declare::ZDCF->new(tree => $testzdcf);
isa_ok($zdcf, "ZMQ::Declare::ZDCF");

my @devices = $zdcf->device_names;
is(scalar(@devices), 2, 'Number of available devices');

is_deeply(\@devices, [qw(weather_client weather_server)]);

foreach my $device_name (qw(weather_client weather_server)) {
  my $device = $zdcf->device($device_name);
  isa_ok($device, "ZMQ::Declare::Device");
  is($device->name, $device_name);

  is("" . $device->spec, "$zdcf", "parent spec/zdcf is same ref");

  is($device->typename, $device_name =~ /client/ ? "myweatherclientdevice" : "myweatherserverdevice");
}

my $srv_device = $zdcf->device("weather_server");
SCOPE: {
  my $rt = $srv_device->make_runtime();
  isa_ok($rt, "ZMQ::Declare::Device::Runtime");
}
my $called = 0;
$srv_device->implementation(sub {$called++});
$srv_device->run();
is($called, 1);

done_testing();
