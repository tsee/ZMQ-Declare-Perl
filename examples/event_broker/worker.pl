use strict;
use warnings;
use lib 'lib';
$| = 1;

use ZeroMQ qw(:all);

use EventBroker;

my $broker = EventBroker->new(specfile => "event_processing.zspec");
my $comp = $broker->get_component("worker");

my $nforks = $ARGV[0] || 1;
print "Spawning $nforks workers!\n";

$comp->run(
  nforks => $nforks,
  main => sub {
    my ($runtime) = @_;
    my $queue = $runtime->get_socket_by_name("work_queue");

    warn "[$$] Worker ready to receive work...\n";

    my $proc_callback = sub {
      my $msgdata = $queue->recv->data;
      warn "[$$] Processing work ($msgdata)...";
      # Do work here...
      sleep($msgdata);
    };
    my $timeout = 2_000_000; # micro seconds
    while (1) {
      ZeroMQ::Raw::zmq_poll(
        [
          {
            socket => $queue->socket,
            events => ZMQ_POLLIN,
            callback => $proc_callback,
          },
        ], $timeout # any large timeout will be fine, see while(1)
      );
    }
  }, # end main
);
