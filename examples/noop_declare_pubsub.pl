use strict;
use warnings;
use ZeroMQ::Declare qw/:all/;
use ZeroMQ qw/:all/;
use Data::Dumper;

# Declare
my $s = Schema->new();
my $pub_app = $s->add_app('publisher');
my $sub_app = $s->add_app('subscriber');

my $pub_sock = $pub_app->add_socket('pub_socket', type => ZMQ_PUB);
my $sub_sock = $sub_app->add_socket('sub_socket', type => ZMQ_SUB);

my $endpoint = $pub_sock->add_bind_endpoint('tcp://127.0.0.0:9977');
$sub_sock->add_connect_endpoint($endpoint);

