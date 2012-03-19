package # hide from PAUSE
  EventBroker;
use Moose;

use ZMQ::Declare;

my $ClientSpec = ZMQ::Declare::ZDCF->new( tree => {
  client => {
    type => 'event_client',
    event_dispatch => {
      type => 'pub',
      connect => 'tcp://localhost:5999',
      option => {hwm => 10000}
    }
  },
});

my $ServiceSpec = ZMQ::Declare::ZDCF->new( tree => {
  broker => {
    type => 'event_broker',
    event_listener => {
      type => 'sub',
      bind => 'tcp://*:5999',
      option => {subscribe => ''}
    },
    work_distributor => {
      type => 'push',
      bind => 'tcp://*:5998',
      option => {hwm => 500000},
    },
  },
  worker => {
    type => 'event_processor',
    work_queue => {
      type => 'pull',
      connect => 'tcp://localhost:5998',
    },
  },
});

has '_client_runtime' => (
  is => 'rw',
);

# instance method for caching (don't want to reconnect all the time)
sub client_socket {
  my $self = shift;
  my $rt = $self->_client_runtime;
  if (not $rt) {
    $rt = $ClientSpec->device("client")->make_runtime;
    $self->_client_runtime($rt);
  }
  return $rt->get_socket_by_name("event_dispatch");
}

# static and/or instance methods
sub broker { $ServiceSpec->device("broker") }
sub worker { $ServiceSpec->device("worker") }

no Moose;
__PACKAGE__->meta->make_immutable;
