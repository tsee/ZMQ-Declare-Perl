package ZMQ::Declare::Device::Runtime;
use 5.008001;
use Moose;

use Scalar::Util ();
use Carp ();
use ZeroMQ qw(:all);

use ZMQ::Declare;
use ZMQ::Declare::Device;

# "declare-time" progenitor
has 'device' => (
  is => 'rw',
  isa => 'ZMQ::Declare::Device',
  required => 1,
  handles => [qw(name)],
);

has 'sockets' => (
  is => 'ro',
  isa => 'HashRef[ZeroMQ::Socket]',
  default => sub {{}},
);

has 'context' => (
  is => 'rw',
  isa => 'ZeroMQ::Context',
);

sub get_socket_by_name {
  my $self = shift;
  my $name = shift;
  my $sock = $self->sockets->{$name};
  Carp::croak("Cannot find socket for name '$name'")
    if not defined $sock;
  return $sock;
}


no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

ZMQ::Declare::Device::Runtime - The runtime pitch on a ZMQ::Declare Device object

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
