package # hide from PAUSE
  WeatherApp;
use strict;
use warnings;
use ZeroMQ::Declare qw/:all/;
use ZeroMQ qw/:all/;

my $schema = Schema->new;
my $pub_app = $schema->add_app('weather_server');
my $sub_app = $schema->add_app('weather_client');

my $pub_sock = $pub_app->add_socket('pub_socket', type => ZMQ_PUB);
my $sub_sock = $sub_app->add_socket('sub_socket', type => ZMQ_SUB);

my $endpoint = $pub_sock->add_bind_endpoint('tcp://127.0.0.0:9977');
$sub_sock->add_connect_endpoint($endpoint);

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
