use strict;
use warnings;
use lib 'lib';
$| = 1;

use Data::Dumper;
use Time::HiRes qw(sleep);

use EventBroker;

my $broker = EventBroker->new(specfile => "event_processing.zspec");
my $event_sock = $broker->client_socket;

print "Client ready, sending a bunch of events...\n";

$event_sock->send(rand(0.1)), sleep(rand(0.005)) for 1..10000;
#$event_sock->send(0) for 1..100000;
sleep 1; # allow for 0MQ to catch up (FIXME there must be a better way)


