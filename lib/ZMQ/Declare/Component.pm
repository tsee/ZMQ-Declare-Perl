package ZMQ::Declare::Component;
use 5.008001;
use Moose;

use Scalar::Util ();
use Carp ();
use ZeroMQ qw(:all);

use ZMQ::Declare;
use ZMQ::Declare::Constants qw(:namespaces);
use ZMQ::Declare::Component::Runtime;

has 'name' => (
  is => 'rw',
  isa => 'Str',
  required => 1,
);

has 'sockets' => (
  is => 'ro',
  isa => 'ArrayRef[ZMQ::Declare::Socket]',
  default => sub {[]},
);

has 'schema' => (
  is => 'ro',
  isa => 'ZMQ::Declare::Schema',
  required => 1,
  weak_ref => 1,
);

has 'context' => (
  is => 'rw',
  isa => 'ZMQ::Declare::Context',
);

sub get_socket_by_name {
  my $self = shift;
  my $name = shift;
  foreach my $socket (@{$self->sockets}) {
    my $n = $socket->name;
    return $socket if defined $n and $n eq $name;
  }
  return();
}

sub run {
  my $self = shift;
  my %args = @_;
  my $callback = $args{main}
    or Carp::croak("Need 'main' CODE reference to run ZMQ::Declare::Component '" . $self->name . "'");

  my $rt = $self->_build_runtime;

  $callback->($rt);
}

sub _build_runtime {
  my $self = shift;
  # Note: Do not store non-weak refs to the runtime in the component.
  #       That wouldn't make a lot of sense anyway, since at least
  #       conceptually, one could have N runtime objects for the same
  #       Component.
  my $rt = ZMQ::Declare::Component::Runtime->new(
    name => $self->name,
    component => $self,
  );
  my $cxt = $self->context->setup_context;
  $rt->context($cxt);

  my @sockets;
  my @socket_names;
  foreach my $d_socket (@{$self->sockets}) {
    push @sockets, $d_socket->setup_socket($cxt);
    push @socket_names, $d_socket->name; # even if not defined
  }
  push @{ $rt->sockets }, @sockets;
  push @{ $rt->_socket_names}, @socket_names;

  return $rt;
}

no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

ZMQ::Declare::Component - A ZMQ::Declare Component object

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
