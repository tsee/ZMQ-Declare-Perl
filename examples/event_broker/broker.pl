use strict;
use warnings;
use lib 'lib';
$| = 1;

use ZeroMQ qw(:all);

use EventBroker;

my $broker = EventBroker->new(specfile => "event_processing.zspec");
my $comp = $broker->get_component("broker");

$comp->run( main => sub {
  my ($runtime) = @_;
  my $listener = $runtime->get_socket_by_name("event_listener");
  my $work_dist = $runtime->get_socket_by_name("work_distributor");

  my $poller = ZeroMQ::Poller->new({
    socket    => $listener,
    events    => ZMQ_POLLIN,
  });

  print "Broker ready, listening for events...\n";
  while (1) {
    $poller->poll();
    my $message = $listener->recv();
    $work_dist->send($message);

    # Instead, if there are multi-part messages:
    # while (1) {
    #   # Process all parts of the message
    #   my $message = $listener->recv();
    #   my $more = $listener->getsockopt(ZMQ_RCVMORE);
    #   $work_dist->send($message, $more ? ZMQ_SNDMORE : 0);
    #   last unless $more;
    # }
  }
});
