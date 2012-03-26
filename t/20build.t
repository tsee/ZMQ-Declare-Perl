use strict;
use warnings;
use ZMQ::Declare qw(:all);
use File::Spec;
use Test::More;

my $datadir = -d 't' ? File::Spec->catdir(qw(t data)) : "data";

# test the ZDCF v0.1 spec file first
my $testzdcf = File::Spec->catfile($datadir, 'simple_v0.zdcf');
ok(-f $testzdcf)
  or die "Missing test file";

my $zdcf = ZMQ::Declare::ZDCF->new(tree => $testzdcf);
isa_ok($zdcf, "ZMQ::Declare::ZDCF");

# just the compat "" application
my @applications = $zdcf->application_names;
is(scalar(@applications), 1, 'Number of available applications');
is($applications[0], "", "Contains only the compat app");

my $app = $zdcf->application(); # default for compat
isa_ok($app, "ZMQ::Declare::Application");
$app = $zdcf->application(""); # using explicit name
isa_ok($app, "ZMQ::Declare::Application");

my @devices = $app->device_names;
is(scalar(@devices), 2, 'Number of available devices');

is_deeply(\@devices, [qw(weather_client weather_server)]);

foreach my $device_name (qw(weather_client weather_server)) {
  my $device = $app->device($device_name);
  isa_ok($device, "ZMQ::Declare::Device");
  is($device->name, $device_name);

  is("" . $device->application, "$app", "parent app is same ref");

  is($device->typename, $device_name =~ /client/ ? "myweatherclientdevice" : "myweatherserverdevice");
}

my $srv_device = $app->device("weather_server");
SCOPE: {
  my $rt = $srv_device->make_runtime();
  isa_ok($rt, "ZMQ::Declare::Device::Runtime");
}
my $called = 0;
$srv_device->implementation(sub {$called++});
$srv_device->run();
is($called, 1);

done_testing();
