=pod

Based on the "Weather update client" from the 'zguide' at http://zguide.zeromq.org/pl:wuclient

Connects SUB socket to tcp://localhost:5556

Collects weather updates and finds avg temp in zipcode

Original author: Alexander D'Archangel (darksuji) <darksuji(at)gmail(dot)com>

=cut

use strict;
use warnings;

use ZeroMQ qw/:all/;
use lib 'lib';
use lib 'examples/lib';
use WeatherApp;

print "Collecting updates from weather server...\n";

$|=1;

# Subscribe to zipcode, default is NYC, 10001
my $filter = @ARGV ? $ARGV[0] : '10001 ';

my $client = WeatherApp->new;

$client->run('weather_client' => sub {
  my %args = @_;
  my $subscriber = $args{sockets}{sub_socket};
  $subscriber->setsockopt(ZMQ_SUBSCRIBE, $filter);

  # Process 100 updates
  my $total_temp = 0;
  my $update_count = 100;
  for (1 .. $update_count) {
    print "Fetching sample $_\n";
    my ($zipcode, $temperature, $relhumidity) = split(/ /, $subscriber->recv->data);
    $total_temp += $temperature;
  }

  print "Average temperature for zipcode '$filter' was "
        . int($total_temp / $update_count) . "\n";
});


