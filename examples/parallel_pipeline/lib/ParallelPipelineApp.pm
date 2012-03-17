package # hide from PAUSE
  ParallelPipelineApp;
use strict;
use warnings;
use ZeroMQ::Declare qw/:all/;
use ZeroMQ qw/:all/;

my $schema = Schema->new;
my $vent_app   = $schema->add_app('ventilator');
my $worker_app = $schema->add_app('worker');
my $sink_app   = $schema->add_app('sink');

my $vent_sock        = $vent_app->add_socket('output', type => ZMQ_PUSH);
my $worker_pull_sock = $worker_app->add_socket('input', type => ZMQ_PULL);
my $worker_push_sock = $worker_app->add_socket('output', type => ZMQ_PUSH);
my $sink_pull_sock   = $sink_app->add_socket('input', type => ZMQ_PULL);

$vent_sock->add_bind_endpoint('tcp://*:5557');
$worker_pull_sock->add_connect_endpoint('tcp://127.0.0.1:5557');
my $worker_ep = Endpoint::Range->new(address => 'tcp://*', ports => '555'
$worker_push_sock->add_bind_endpoint('tcp://*:5558');
$worker_push_sock->add_bind_endpoint('tcp://*:5558');
$sink_pull_sock->add_connect_endpoint('tcp://127.0.0.1:5558');

sub new {
  my $class = shift;
  return bless {} => $class;
}

sub run {
  my $self = shift;
  my $role = shift;
  my $runloop = shift;
  my $app = $schema->app($role) or die;
  $app->run(runloop => $runloop);
}

1;
