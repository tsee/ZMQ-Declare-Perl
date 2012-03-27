
use strict;
use warnings;

BEGIN {
  package
    Foo;
  use ZMQ::Declare;
  use Carp ();

  our $ZDCF;
  our $App;
  our $Context;
  our $Device;
  our $Socket;
  our $CurScope;

  use base 'Exporter';
  our @EXPORT = qw(
    declare_zdcf
    app
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

  sub declare_zdcf(&) {
    local $ZDCF = {version => "1.0"};
    local $App;
    local $Context;
    local $Device;
    local $Socket;
    local $CurScope = 'zdcf';
    $_[0]->();
    return ZMQ::Declare::ZDCF->new(tree => $ZDCF);
  }

  sub app(&) {
    Carp::croak("'app' outside ZDCF found: Did you fail to call 'declare_zdcf'?")
      if not defined $CurScope;
    Carp::croak("Wrongly nested or out-of-place 'app' detected: You cannot nest ZDCF apps")
      if $App or $CurScope ne 'zdcf';

    local $CurScope = 'app';
    local $App = {};
    $_[0]->();

    my $name = delete $App->{name};
    Carp::croak("Missing app name!") if not defined $name;
    $ZDCF->{apps}{$name} = $App;
  }

  sub context(&) {
    Carp::croak("'context' outside ZDCF found: Did you fail to call 'declare_zdcf'?")
      if not defined $CurScope;
    Carp::croak("Wrongly nested or out-of-place 'context' detected: You cannot nest ZDCF contexts")
      if $Context or $CurScope ne 'app';

    local $Context = {};
    local $CurScope = 'context';
    $_[0]->();
    $App->{context} = $Context;
  }

  sub iothreads($) {
    Carp::croak("'iothreads' outside ZDCF found: Did you fail to call 'declare_zdcf'?")
      if not defined $CurScope;
    Carp::croak("Wrongly nested or out-of-place 'iothreads' detected")
      if $CurScope ne 'context';

    $Context->{iothreads} = $_[0];
  }

  sub device(&) {
    Carp::croak("'device' outside ZDCF found: Did you fail to call 'declare_zdcf'?")
      if not defined $CurScope;
    Carp::croak("Wrongly nested or out-of-place 'device' detected: You cannot nest ZDCF devices")
      if $Context or $CurScope ne 'app';

    local $Device = {};
    local $CurScope = 'device';
    $_[0]->();
    my $name = delete $Device->{name};
    Carp::croak("Missing device name!") if not defined $name;
    $App->{devices}{$name} = $Device;
  }

  sub name($) {
    if (not defined $CurScope) {
      Carp::croak("Error 'name()' outside app, device, and socket. Did you fail to call 'declare_zdcf'?");
    }
    elsif ($CurScope eq 'device') {
      $Device->{name} = shift;
    } elsif ($CurScope eq 'socket') {
      $Socket->{name} = shift;
    } elsif ($CurScope eq 'app') {
      $App->{name} = shift;
    } else { Carp::croak("Error 'name()' outside app, device, and socket") }
  }

  sub type($) {
    if (not defined $CurScope) {
      Carp::croak("Error 'type()' outside device, and socket. Did you fail to call 'declare_zdcf'?");
    }
    elsif ($CurScope eq 'device') {
      $Device->{type} = shift;
    } elsif ($CurScope eq 'socket') {
      $Socket->{type} = shift;
    } else { Carp::croak("Error 'type()' outside device, and socket") }
  }

  sub sock(&) {
    Carp::croak("'socket' outside ZDCF found: Did you fail to call 'declare_zdcf'?")
      if not defined $CurScope;
    Carp::croak("Wrongly nested or out-of-place 'socket' detected: You cannot nest ZDCF devices")
      if $Context or $CurScope ne 'device';

    local $Socket = {};
    local $CurScope = 'socket';
    $_[0]->();
    my $name = delete $Socket->{name};
    Carp::croak("Missing socket name!") if not defined $name;
    $Device->{sockets}{$name} = $Socket;
  }

  sub bnd(@) {
    Carp::croak("Error: bnd (bind) outside socket")
      if not defined $CurScope or $CurScope ne 'socket';
    push @{ $Socket->{bind} }, @_;
  }

  sub conn(@) {
    Carp::croak("Error: conn (connect) outside socket")
      if not defined $CurScope or $CurScope ne 'socket';
    push @{ $Socket->{connect} }, @_;
  }

  sub option(%) {
    Carp::croak("Error: option() outside socket")
      if not defined $CurScope or $CurScope ne 'socket';
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

my $zdcf = declare_zdcf {

    app {
        name 'events';

        context { iothreads 1 };

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
            sock {
                name 'work_queue';
                type 'pull';
                conn qw(tcp://localhost:12346);
            };
        };
    };
};

#warn Dumper $zdcf;

my $worker = $zdcf->application("events")->device('worker');
$worker->implementation(sub {
  my ($runtime) = @_;
  # worker main loop here
  return();
});
$worker->run(nforks => 20);


