
use strict;
use warnings;

BEGIN {
  package
    Foo;
  use ZMQ::Declare;
  use Carp ();

  our $ZDCF;
  our $Device;
  our $Socket;
  our $CurScope;

  use base 'Exporter';
  our @EXPORT = qw(
    context
    iothreads
    device
    name
    type
    sock
    bnd
    conn
    option
  );

  sub context(&) {
    local $ZDCF = {};
    local $CurScope = 'context';
    $_[0]->();
    my $zdcf = ZMQ::Declare::ZDCF->new(tree => $ZDCF);
    return $zdcf;
  }

  sub iothreads($) {
    Carp::croak("Error: iothreads() outside context()") if not $CurScope eq 'context';
    $ZDCF->{context}{iothreads} = $_[0];
  }

  sub device(&) {
    Carp::croak("Error: device() outside context()") if not $CurScope eq 'context';
    local $Device = {};
    local $CurScope = 'device';
    $_[0]->();
    my $name = delete $Device->{name};
    die if not defined $name or $name eq 'context';
    $ZDCF->{$name} = $Device;
  }

  sub name($) {
    if ($CurScope eq 'device') {
      $Device->{name} = shift;
    } elsif ($CurScope eq 'socket') {
      $Socket->{name} = shift;
    } else { Carp::croak("Error 'name()' outside device()") }
  }

  sub type($) {
    if ($CurScope eq 'device') {
      $Device->{type} = shift;
    } elsif ($CurScope eq 'socket') {
      $Socket->{type} = shift;
    } else { Carp::croak("Error 'type()' outside device()") }
  }

  sub sock(&) {
    Carp::croak("Error: socket() outside device()") if not $CurScope eq 'device';
    local $Socket = {};
    local $CurScope = 'socket';
    $_[0]->();
    my $name = delete $Socket->{name};
    die if not defined $name or $name eq 'type';
    $Device->{$name} = $Socket;
  }

  sub bnd(@) {
    Carp::croak("Error: bind() outside socket") if not $CurScope eq 'socket';
    push @{ $Socket->{bind} }, @_;
  }

  sub conn(@) {
    Carp::croak("Error: conn() outside socket") if not $CurScope eq 'socket';
    push @{ $Socket->{connect} }, @_;
  }

  sub option(%) {
    Carp::croak("Error: option() outside socket") if not $CurScope eq 'socket';
    while (@_) {
      my $k = shift;
      $Socket->{option}->{$k} = shift;
    }
  }
} # end Foo

package
  main;
BEGIN {Foo->import;}
use ZMQ::Declare;
use Data::Dumper;

my $zdcf = context {
    iothreads 1;

    device {
        name 'client';
        type 'clientdevice';
        sock {
            name 'event_dispatcher';
            type 'pub';
            conn qw(tcp://localhost:12345);
            option hwm => 100;
        };
    };

    device {
        name 'broker';
        type 'brokerdevice';
        sock {
            name 'event_listener';
            type 'sub';
            bnd qw(tcp://*:12345);
            option subscribe => "WEB",
                   hwm       => 10000;
        };
        sock {
            name 'work_dispatcher';
            type 'push';
            bnd qw(tcp://*:12346);
        };
    };
    
    device {
        name 'worker';
        type 'workerdevice';
        sock {
            name 'work_queue';
            type 'pull';
            conn qw(tcp://localhost:12346);
        };
    };
};

use Data::Dumper;
warn Dumper $zdcf;

my $worker = $zdcf->device('worker');
$worker->implementation(sub {
  my ($runtime) = @_;
  # worker main loop here
  return();
});
$worker->run(nforks => 20);


