=pod

Based on "Task worker" from http://zguide.zeromq.org/pl:taskwork

Connects PULL socket to tcp://localhost:5557

Collects workloads from ventilator via that socket

Connects PUSH socket to tcp://localhost:5558

Sends results to sink via that socket

Original author: Alexander D'Archangel (darksuji) <darksuji(at)gmail(dot)com>

=cut

use strict;
use warnings;

use ZeroMQ qw/:all/;
use lib 'lib';
use lib 'examples/parallel_pipeline/lib';
use ParallelPipelineApp;
use Time::HiRes qw(sleep);


my $nworkers = $ARGV[0]||1;

my $is_parent;
my @pids;
for (1..$nworkers) {
  my $pid = fork;
  if ($pid) {
    $is_parent = 1;
    push @pids, $pid;
  }
  else {
    $is_parent = 0;
    last;
  }
}

if ($is_parent) {
  waitpid($_, 0) for @pids;
  print "All children done!\n";
  exit(0);
}

my $srv = ParallelPipelineApp->new;
$srv->run('worker' => sub {
  my %args = @_;
  my $input = $args{sockets}{input};
  my $output = $args{sockets}{output};

  local $| = 1;
  # Process tasks forever
  while (1) {
      my $string = $input->recv()->data;
      my $time = $string / 1000; # msec => sec
      # Simple progress indicator for the viewer
      print "$string.";

      # Do the work
      sleep($time);

      # Send results to sink
      $output->send('');
  }
});

