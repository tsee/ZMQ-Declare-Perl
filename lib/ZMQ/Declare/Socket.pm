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

# TODO sockopts

sub numeric_socket_type {
  my $self = shift;
  return ZMQ::Declare::Types->sock_type_to_number($self->type);
}

sub setup_socket {
  my ($self, $cxt) = @_;
  $cxt->socket( $self->numeric_socket_type );
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
