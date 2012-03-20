package ZMQ::Declare::ZDCF;
use 5.008001;
use Moose;
our $VERSION = '0.01';

use ZMQ::Declare;
use ZMQ::Declare::ZDCF::Validator;
use ZMQ::Declare::ZDCF::Encoder;
use ZMQ::Declare::ZDCF::Encoder::JSON;

use ZeroMQ qw(:all);

use ZMQ::Declare::Constants qw(:all);
use ZMQ::Declare::Types;
use Carp ();
use Clone ();

has 'validator' => (
  is => 'rw',
  isa => 'ZMQ::Declare::ZDCF::Validator',
  default => sub {ZMQ::Declare::ZDCF::Validator->new},
);

has 'tree' => (
  is => 'rw',
  required => 1,
);

has 'encoder' => (
  is => 'rw',
  isa => 'ZMQ::Declare::ZDCF::Encoder',
  default => sub {ZMQ::Declare::ZDCF::Encoder::JSON->new},
);

has '_runtime_context' => (
  is => 'rw',
  isa => 'ZeroMQ::Context',
  weak_ref => 1,
);

sub BUILD {
  my $self = shift;
  my $tree = $self->tree;

  # needs decoding
  if (not ref($tree) eq 'HASH') {
    my $sref;
    if (ref($tree) eq 'SCALAR') { # content as scalar ref
      $sref = $tree;
    }
    elsif (not ref $tree) { # slurp from file
      use autodie;
      open my $fh, "<", $tree;
      local $/;
      my $zdcf_content = <$fh>;
      $sref = \$zdcf_content;
    }

    $tree = $self->encoder->decode($sref);
    Carp::croak("Failed to decode input ZDCF")
      if not defined $tree;

    $self->tree($tree);
  }

  Carp::croak("Failed to validate decoded ZDCF")
    if not $self->validator->validate($tree);
}

sub device_names {
  my $self = shift;

  return grep $_ ne 'context', keys %{ $self->tree || {} };
}

sub device {
  my $self = shift;
  my $name = shift;

  my $device = $self->_build_device($name);
  return $device;
}

sub _build_device {
  my ($self, $name) = @_;

  my $tree = $self->tree;
  Carp::croak("Invalid device '$name'")
    if $name eq 'context' or not exists $tree->{$name};

  my $dev_spec = $tree->{$name};
  my $typename = $dev_spec->{type};
  $typename = '' if not defined $typename;

  return ZMQ::Declare::Device->new(
    name => $name,
    spec => $self,
    typename => $typename,
  );
}

# runtime context
sub get_context {
  my ($self) = @_;
  my $cxt = $self->_runtime_context;
  return $cxt if defined $cxt;

  my $tree = $self->tree;
  my $context_str = $tree->{context};
  my $iothreads = defined $context_str ? $context_str->{iothreads} : 1;
  $cxt = ZeroMQ::Context->new($iothreads);
  $self->_runtime_context($cxt);

  return $cxt;
}

# runtime sockets
sub make_device_sockets {
  my $self = shift;
  my $dev_runtime = shift;

  my $tree = $self->tree;
  my $dev_spec = $tree->{ $dev_runtime->name };
  Carp::croak("Could not find ZDCF entry for device '".$dev_runtime->name."'")
    if not defined $dev_spec or not ref($dev_spec) eq 'HASH';

  my $cxt = $dev_runtime->context;
  my @socks;
  foreach my $sockname (grep $_ ne 'type', keys %$dev_spec) {
    my $sock_spec = $dev_spec->{$sockname};
    my $socket = $self->_setup_socket($cxt, $sock_spec);
    push @socks, [$socket, $sock_spec];
    $dev_runtime->sockets->{$sockname} = $socket;
  }

  $self->_init_sockets(\@socks, "bind");
  $self->_init_sockets(\@socks, "connect");

  return();
}

sub _setup_socket {
  my ($self, $cxt, $sock_spec) = @_;

  my $type = $sock_spec->{type};
  my $typenum = ZMQ::Declare::Types->zdcf_sock_type_to_number($type);
  my $sock = $cxt->socket($typenum);

  # FIXME figure out whether some of these options *must* be set after the connects
  my $opt = $sock_spec->{option} || {};
  foreach my $opt_name (keys %$opt) {
    my $opt_num = ZMQ::Declare::Types->zdcf_settable_sockopt_type_to_number($opt_name);
    $sock->setsockopt($opt_num, $opt->{$opt_name});
  }

  return $sock;
}

sub _init_sockets {
  my ($self, $socks, $connecttype) = @_;

  foreach my $sock_n_spec (@$socks) {
    my ($sock, $spec) = @$sock_n_spec;
    $self->_init_socket_conn($sock, $spec, $connecttype);
  }
}

sub _init_socket_conn {
  my ($self, $sock, $spec, $connecttype) = @_;

  my $conn_spec = $spec->{$connecttype};
  return if not $conn_spec;

  my @endpoints = (ref($conn_spec) eq 'ARRAY' ? @$conn_spec : $conn_spec);
  $sock->$connecttype($_) for @endpoints;
}

sub encode {
  my ($self) = @_;
  return $self->encoder->encode($self->tree);
}

sub write_to_file {
  my ($self, $filename) = @_;
  open my $fh, ">", $filename or die $!;
  print $fh ${ $self->encode };
  close $fh;
}

no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

ZMQ::Declare::ZDCF - Object representing ZeroMQ Device Configuration (File)

=head1 SYNOPSIS

  use ZMQ::Declare;
  
  my $zdcf = ZMQ::Declare::ZDCF->new(tree => $json_zdcf_filename);
  # Alternatively
  my $zdcf = ZMQ::Declare::ZDCF->new(
    encoder => ZMQ::Declare::ZDCF::Encoder::YourFormat->new,
    tree => $zdcf_file_with_different_encoding
  );

=head1 DESCRIPTION

This class represents the content of a single ZDCF. That means,
it covers a single 0MQ threading context and an arbitrary
number of devices and sockets.

=head1 METHODS

=head2 new

Constructor taking named arguments. Any parameters listed under
I<METHOD-ACCESSIBLE INSTANCE PROPERTIES> can be supplied, but
a C<tree> is the main input and thus required.

You can provide the C<tree> property as any one of the following:

=over 2

=item *

A hash reference that represents the underlying ZDCF data structure.
It will be validated using the ZDCF validator but otherwise won't
be touched (or cloned).

=item *

A reference to a scalar. The scalar is assumed to contain valid input
for the decoder (by default: JSON-encoded ZDCF). The thusly decoded
Perl data structure will be validated like if you provided a hash
reference.

=item *

A string, which is interpreted as a file name to read from. The data
read from the file will be decoded and validated as per the above.

=back

=head2 device

Given a device name, creates a L<ZMQ::Declare::Device> object from
the information stored in the ZDCF tree and returns that object.

This C<ZMQ::Declare::Device> object is what you can use to actually
implement 0MQ devices that are configured through ZDCF.
Note that creating a C<ZMQ::Declare::Device> object does B<not>
create any 0MQ contexts, sockets, or connections yet.

=head2 device_names

Returns a list (not a reference) of device names that are known to
the ZDCF tree.

=head2 encode

Encodes the ZDCF data structure using the object's encoder and
returns a scalar reference to the result.

=head2 write_to_file

Writes the ZDCF content to the given file name.

=head2 get_context

Creates a L<ZeroMQ::Context> object from the ZDCF tree and returns
it. In other words, this creates the actual threading context of
0MQ. Generally, this is called indirectly by using the C<device>
method to obtain a C<ZMQ::Declare::Device> object and then
calling the C<run> or C<make_runtime> methods on that.

=head2 make_device_sockets

I<Used by other ZMQ::Declare classes, but considered internal.>

=head1 SEE ALSO

The ZDCF RFC L<http://rfc.zeromq.org/spec:5>

L<ZMQ::Declare>

L<ZeroMQ>

=head1 METHOD-ACCESSIBLE INSTANCE PROPERTIES

=head2 validator

Get/set the validator object that can check a Perl-datastructure ZDCF tree
for structural correctness. Must be a L<ZMQ::Declare::ZDCF::Validator>
object or an object of a derived class. Defaults to a new
C<ZMQ::Declare::ZDCF::Validator> object.

=head2 encoder

Get/set the encoder (decoder) object for turning a text file into a
ZDCF tree in memory and vice versa. Needs to be an object of a class
derived from L<ZMQ::Declare::ZDCF::Encoder>. Defaults to a
L<ZMQ::Declare::ZDCF::Encoder::JSON> object for reading/writing JSON-encoded
ZDCF.

=head2 tree

The actual nested (and untyped) Perl data structure that represents the ZDCF
information. See the documentation for the constructor for details on what
data is valid to supply to the constructor for this property.

=head1 AUTHOR

Steffen Mueller E<lt>smueller@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Steffen Mueller

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
