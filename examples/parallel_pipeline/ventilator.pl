=pod

Based on "Task ventilator" from http://zguide.zeromq.org/pl:taskvent

Binds PUSH socket to tcp://localhost:5557

Sends batch of tasks to workers via that socket

Original author: Alexander D'Archangel (darksuji) <darksuji(at)gmail(dot)com>

=cut

use strict;
use warnings;

use ZeroMQ qw/:all/;
use lib 'lib';
use lib 'examples/parallel_pipeline/lib';
use ParallelPipelineApp;

my $srv = ParallelPipelineApp->new;
$srv->run('ventilator' => sub {
  my %args = @_;
  my $sender = $args{sockets}{output};
  print 'Press Enter when the workers are ready: ';
  my $tmp = <STDIN>;
  print "Sending tasks to workers...\n";

  # The first message is "0" and signals start of batch
  $sender->send('0');

  # Send 100 tasks
  my $total_msec = 0;     # Total expected cost in msecs
  for (1 .. 100) {
    # Random workload from 1 to 100msecs
    my $workload = int(rand(100))+1;
    $total_msec += $workload;
    $sender->send($workload);
  }
  print "Total expected cost: $total_msec msec\n";
  sleep (1);              # Give 0MQ time to deliver
});

