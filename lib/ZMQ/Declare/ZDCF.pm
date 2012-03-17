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
  is => 'ro',
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

sub BUILD {
  my $self = shift;
  my $tree = $self->tree;
  if (not ref($tree) eq 'HASH') {
    $tree = $self->encoder->decode($tree);

    Carp::croak("Failed to decode input ZDCF")
      if not defined $tree;
    Carp::croak("Failed to validate decoded ZDCF")
      if not $self->validator->validate($tree);

    $self->tree($tree);
  }
}

sub device {
  my $self = shift;
  my $name = shift;

  my $cxt = $self->_build_context;

  my $device = $self->_build_device($cxt, $name);

  return $schema;
}

sub _build_device {
  my ($self, $cxt, $name) = @_;

  my $tree = $self->tree;
  Carp::croak("Invalid device '$name'")
    if $name eq 'context' or not exists $tree->{$name};

  my $dev_spec = $tree->{$name};
  return ZMQ::Declare::Device->new(
    name => $name,
    context => $cxt,
    typename => '', # FIXME
  );
# FIXME
  foreach my $sock_spec (@{$spec->{sockets} || []}) {
    push @{$comp->sockets}, $self->_build_socket($comp, $sock_spec);
  }

  return $comp;
}

sub _build_context {
  my ($self) = @_;
  my $tree = $self->tree;
  my $context_str = $tree->{context};
  my $iothreads = defined $context_str ? $context_str->{iothreads} : 1;
  my $cxt = ZeroMQ::Context->new($iothreads);
  return $cxt;
}

no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

ZMQ::Declare::ZDCF - Object representing a 0MQ-declare specification

=head1 SYNOPSIS

  use ZMQ::Declare;

  my $zdcf = ZMQ::Declare::ZDCF->new(tree => $some_json_zdcf);
  # or:
  my $zdcf = ZMQ::Declare::ZDCF->new(
    encoder => ZMQ::Declare::ZDCF::Encoder::YourFormat->new,
    tree => $your_format_string.
  );

=head1 DESCRIPTION

=head1 SEE ALSO

The ZDCF RFC L<http://rfc.zeromq.org/spec:5>

L<ZeroMQ>

=head1 AUTHOR

Steffen Mueller E<lt>smueller@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Steffen Mueller

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
