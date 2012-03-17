=pod

Based on the "Weather update client" from the 'zguide' at http://zguide.zeromq.org/pl:wuclient

Connects SUB socket to tcp://localhost:5556

Collects weather updates and finds avg temp in zipcode

Original author: Alexander D'Archangel (darksuji) <darksuji(at)gmail(dot)com>

=cut

use strict;
use warnings;

use ZeroMQ qw/:all/;
use ZMQ::Declare qw/:all/;
my $schema = Spec->new(tree => 'weather.zspec')->create_schema("weather");
my $component = $schema->get_component('client');

print "Collecting updates from weather server...\n";

$|=1;

my $samples = $ARGV[0]||10;
my $nclients = $ARGV[1]||1;

# Subscribe to a particular zipcode, default is random (after fork)
my $filter = $ARGV[2];

# For spawning N clients
my @pids;
for (1..$nclients) {
  my $pid = fork;
  if ($pid) { push @pids, $pid }
  else      { @pids = (); last; }
}

if (@pids) {
  waitpid($_, 0) for @pids; # not elegant, but it's just an example
  print "All children done!\n";
  exit(0);
}

# set random ZIP code if none supplied
$filter ||= sprintf('%05u', rand(100000));

$component->run(
  main => sub {
    my ($runtime) = @_;
    my $subscriber = $runtime->get_socket_by_name("subscriber");
  
    # set subscription filter based on CLI (could be an option in the spec otherwise)
    print "Subscribing to weather updates for ZIP code '$filter'\n";
    $subscriber->setsockopt(ZMQ_SUBSCRIBE, $filter);


    # Process 100 updates
    my $total_temp = 0;
    for (1 .. $samples) {
      print "Fetching sample $_\n";
      my ($zipcode, $temperature, $relhumidity) = split(/ /, $subscriber->recv->data);
      $total_temp += $temperature;
    }

    print "Average temperature for zipcode '$filter' was "
          . int($total_temp / $samples) . "\n";
  }
);


