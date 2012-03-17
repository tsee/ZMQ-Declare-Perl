=pod

Based on the 0MQ example scripts "Task sink", "Task ventilator", and
"Task worker" from

  http://zguide.zeromq.org/pl:tasksink
  http://zguide.zeromq.org/pl:taskvent
  http://zguide.zeromq.org/pl:taskwork

Original author of the above: Alexander D'Archangel (darksuji) <darksuji(at)gmail(dot)com>

=cut

use strict;
use warnings;
$| = 1;

use ZMQ::Declare qw/:all/;
use Time::HiRes qw(time sleep);
use Getopt::Long qw(GetOptions);

use constant N_WORK_UNITS => 1000;

GetOptions(
  'role|r=s' => \(my $Role),
  'forks=i' => \(my $NWorkers),
);
die "Need process role as --role=...\n" if not defined $Role;

# Just to support N workers out of the box
if ($Role eq 'worker' and $NWorkers and $NWorkers > 1) {
  my @pids;
  for (1..$NWorkers) {
    my $pid = fork;
    if ($pid) { push @pids, $pid; sleep 0.1; }
    else      { @pids = (); last; }
  }

  if (@pids) {
    waitpid($_, 0) for @pids; # not elegant, but it's just an example
    print "All children done!\n";
    exit(0);
  }
  print "[$$] Worker staring.\n";
}

# We put the main component implementations in the same place.
# If you have complicated components, this makes no sense,
# but given the simplicity, this allows for easy reading on how
# they talk to one another.
my %MainLoops = (
  ventilator => sub {
    my ($runtime) = @_;
    my $sender = $runtime->get_socket_by_name("sender");

    # The first message is "0" and signals start of batch
    $sender->send('0');

    # Send N_WORK_UNITS tasks
    my $total_msec = 0;     # Total expected cost in msecs
    for (1 .. N_WORK_UNITS) {
      # Random workload from 1 to 100msecs
      my $workload = int(rand(100))+1;
      $total_msec += $workload;
      $sender->send($workload);
    }
    print "Total expected cost: $total_msec msec\n";
    sleep(1); # Give 0MQ time to deliver (FIXME: There must be a better way to block for delivery)
  }, # end of ventilator

  worker => sub {
    my ($runtime) = @_;
    my ($input, $output) = @{ $runtime->sockets };

    # Process tasks forever
    while (1) {
      my $string = $input->recv()->data;
      my $time = $string / 1000; # msec => sec
      print "[$$]: $string\n"; # Simple progress indicator for the viewer
      sleep($time); # Do the "work"
      $output->send(''); # Send "results" to sink
    }
  },

  sink => sub {
    my ($runtime) = @_;
    my $input = $runtime->get_socket_by_name("receiver");

    print "Sink ready...\n";
    # Wait for start of batch
    $input->recv();

    # Start our clock now
    my $tstart = time;

    # Process N_WORK_UNITS confirmations
    for my $task_nbr (0 .. N_WORK_UNITS-1) {
      $input->recv();
      use integer;
      print( ($task_nbr / 10) * 10 == $task_nbr ? ':' : '.' );
    }

    # Calculate and report duration of batch
    my $tend = time;

    my $total_msec = ($tend - $tstart) * 1000;
    print "\nTotal elapsed time: $total_msec msec\n";
  }, # end of sink main loop
);

my $schema = Spec->new(tree => 'parallel_pipeline.zspec')->create_schema("parallel_pipeline");
$schema->get_component($Role)->run('main' => $MainLoops{$Role});

