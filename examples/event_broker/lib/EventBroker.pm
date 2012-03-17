package # hide from PAUSE
  EventBroker;
use Moose;

use ZMQ::Declare qw/:all/;

has 'specfile' => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

has 'schema' => (
  is => 'ro',
  isa => 'ZMQ::Declare::Schema',
  handles => [qw(get_component)],
);

# Call this on any instance to get a cached 0MQ socket for sending events
has 'client_socket' => (
  is => 'ro',
  isa => 'ZeroMQ::Socket',
  lazy => 1,
  builder => '_build_client_socket',
);

sub _build_client_socket {
  $_[0]->_client_runtime->get_socket_by_name("event_dispatch")
}

# internal: the runtime for the cached clinet socket
has '_client_runtime' => (
  is => 'rw',
  isa => 'ZMQ::Declare::Component::Runtime',
  lazy => 1,
  builder => '_build_client_runtime',
);

sub _build_client_runtime {
  $_[0]->get_component("client")->make_runtime
}

# sets up the ZMQ::Declare::Schema
sub BUILD {
  my $self = shift;
  my $spec = Spec->new(tree => $self->specfile);
  $self->{schema} = $spec->create_schema('event_processing');
}

no Moose;
__PACKAGE__->meta->make_immutable;
