package ZMQ::Declare::Socket;
use 5.008001;
use Moose;

use Carp ();

use ZMQ::Declare::Types;
use ZMQ::Declare::Constants qw(:namespaces);

has 'name' => ( # entirely optional
  is => 'rw',
  isa => 'Str',
);

has 'connect_type' => (
  is => 'rw',
  isa => 'ZMQDeclareSocketConnectType',
  required => 1,
);

has 'type' => (
  is => 'rw',
  isa => 'ZMQDeclareSocketType',
  required => 1,
);

has 'endpoint' => (
  is => 'rw',
  isa => 'Str', # FIXME define proper class or type?
  required => 1,
);

has 'component' => (
  is => 'ro',
  isa => 'ZMQ::Declare::Component',
  required => 1,
  weak_ref => 1,
);

# FIXME option name/value validation?
has 'options' => (
  is => 'ro',
  isa => 'ZMQDeclareSettableSocketOptionsHashRefType', # hashref with only valid keys
  default => sub { +{} },
);

sub numeric_socket_type {
  my $self = shift;
  return ZMQ::Declare::Types->sock_type_to_number($self->type);
}

sub numeric_settable_sockopt {
  my $self = shift;
  my $optname = shift;
  return ZMQ::Declare::Types->settable_sockopt_type_to_number($optname);
}

sub setup_socket {
  my ($self, $cxt) = @_;
  my $socket = $cxt->socket( $self->numeric_socket_type );
  my $conn_type = $self->connect_type;

  # set all the provided socket options
  my $opts = $self->options;
  foreach my $optname (sort keys %$opts) {
    my $optval = $opts->{$optname};
    my $optname_num = $self->numeric_settable_sockopt($optname);
    $socket->setsockopt($optname_num, $optval);
  }

  $socket->$conn_type($self->endpoint);
  return $socket;
}

no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

ZMQ::Declare::Socket - A ZMQ::Declare Socket object

=head1 SYNOPSIS

  use ZMQ::Declare;

=head1 DESCRIPTION

=head1 SEE ALSO

L<ZeroMQ>

=head1 AUTHOR

Steffen Mueller E<lt>smueller@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011,2012 by Steffen Mueller

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
