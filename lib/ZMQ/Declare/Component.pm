package ZMQ::Declare::Component;
use 5.008001;
use Moose;

use Scalar::Util ();
use Carp ();

#use ZeroMQ qw(:all);
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

sub get_socket {
  my $self = shift;
  my $name = shift;
  return $self->sockets->{$name} || croak("Unknown Socket '$name'");
}

sub add_socket {
  my $self = shift;
  my $name = shift;
  my %param = @_;
  $param{name} = $name;

  my $objs = $self->{sockets};
  if (exists $objs->{$name}) {
    croak("Cannot add duplicate socket of name '$name' to a " . __PACKAGE__);
  }

  my $obj = Socket->new(%param, app => $self);
  $objs->{$name} = $obj;

  return $obj;
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