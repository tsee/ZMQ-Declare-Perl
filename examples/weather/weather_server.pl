=pod

Based on the "Weather update server" from the 'zguide' at http://zguide.zeromq.org/pl:wuserver

Binds PUB socket to tcp://*:5556

Publishes random weather updates

Original author: Alexander D'Archangel (darksuji) <darksuji(at)gmail(dot)com>

=cut

use strict;
use warnings;

use ZeroMQ qw/:all/;
use lib 'lib';
use lib 'examples/weather/lib';
use WeatherApp;
use Time::HiRes qw(sleep);

sub within {
  my ($upper) = @_;
  return int(rand($upper)) + 1;
}

# Prepare our context and publisher
my $srv = WeatherApp->new;
$srv->run('weather_server' => sub {
  my %args = @_;
  my $publisher = $args{sockets}{pub_socket};
  
  while (1) {
    # Get values that will fool the boss
    my $zipcode     = within(100_000);
    my $temperature = within(215) - 80;
    my $relhumidity = within(50) + 10;

    # Send message to all subscribers
    my $update = sprintf('%05d %d %d', $zipcode, $temperature, $relhumidity);
    #print "Sending update $update\n";
    $publisher->send($update);
    #sleep 0.1;
  }
});
