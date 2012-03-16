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

my $schema = $spec->create_schema("weather");
isa_ok($schema, "ZMQ::Declare::Schema");
is($schema->name, 'weather');

my $components = $schema->components;
is(scalar(keys %$components), 2, 'Number of available components');
my @comp_names = sort keys %$components;
is_deeply(\@comp_names, [qw(weather_client weather_server)]);

foreach my $schema_name (qw(weather_client weather_server)) {
  my $comp = $schema->get_component($schema_name);
  isa_ok($comp, "ZMQ::Declare::Component");
  is($comp->name, $schema_name);

  is("" . $comp->schema, "$schema", "parent schema same ref");

  my $sockets = $comp->sockets;
  is(ref($sockets), "ARRAY");
  is(scalar(@$sockets), 1);

  my $sock = $sockets->[0];
  isa_ok($sock, "ZMQ::Declare::Socket");

  ok(not defined($sock->name));
  is($sock->connect_type, $schema_name eq 'weather_client' ? "connect" : "bind");
  is($sock->type, $schema_name eq 'weather_client' ? "ZMQ_SUB" : "ZMQ_PUB");
  is($sock->endpoint, $schema_name eq 'weather_client' ? "tcp://localhost:5556" : "tcp://*:5556");
}

done_testing();
