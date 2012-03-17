package ZMQ::Declare::Component;
use 5.008001;
use Moose;

use Scalar::Util ();
use Carp ();

use ZeroMQ qw(:all);
use ZMQ::Declare::Constants qw(:namespaces);
require ZMQ::Declare;

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

sub run {
  my $self = shift;

  my @obj = $self->_build_zeromq_objs;
# TODO implement
}

sub _build_zeromq_objs {
  my $self = shift;
  my $cxt = $self->context->setup_context;
  
  my @sockets;
  foreach my $d_socket (@{$self->sockets}) {
    push @sockets, $d_socket->setup_socket($cxt);
  }

  return [$cxt, \@sockets];
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

Steffen Mueller, E<lt>smueller@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011,2012 by Steffen Mueller

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
