package ZMQ::Declare::Component::Runtime;
use 5.008001;
use Moose;

use Scalar::Util ();
use Carp ();
use ZeroMQ qw(:all);

use ZMQ::Declare;
use ZMQ::Declare::Constants qw(:namespaces);

has 'name' => (
  is => 'rw',
  isa => 'Str',
  required => 1,
);

# "declare-time" progenitor
has 'component' => (
  is => 'rw',
  isa => 'ZMQ::Declare::Component',
  required => 1,
);

has 'sockets' => (
  is => 'ro',
  isa => 'ArrayRef[ZeroMQ::Socket]',
  default => sub {[]},
);

has '_socket_names' => (
  is => 'ro',
  isa => 'ArrayRef[Str]',
  default => sub {[]},
);

has 'context' => (
  is => 'rw',
  isa => 'ZeroMQ::Context',
);

sub get_socket_by_name {
  my $self = shift;
  my $name = shift;
  my $names = $self->_socket_names;
  foreach my $i (0 .. $#$names ) {
    my $n = $names->[$i];
    return $self->sockets->[$i] if defined $n and $n eq $name;
  }
  return();
}


no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

ZMQ::Declare::Component::Runtime - The runtime pitch on a ZMQ::Declare Component object

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
