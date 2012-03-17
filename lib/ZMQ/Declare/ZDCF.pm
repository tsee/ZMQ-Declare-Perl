package ZMQ::Declare::ZDCF;
use 5.008001;
use Moose;
our $VERSION = '0.01';

use ZMQ::Declare;
use ZMQ::Declare::ZDCF::Validator;
use ZMQ::Declare::ZDCF::Encoder;
use ZMQ::Declare::ZDCF::Encoder::JSON;

use ZMQ::Declare::Constants qw(:all);
use ZMQ::Declare::Types;
use Carp ();
use Clone ();

has 'validator' => (
  is => 'ro',
  isa => 'ZMQ::Declare::ZDCF::Validator',
  default => sub {ZMQ::Declare::ZDCF::Validator->new},
);

has 'tree' => ( # FIXME Want coercion from string via the validator. Does that pose a problem for order-of-execution?
  is => 'rw',
  isa => 'HashRef',
);

has 'encoder' => (
  is => 'rw',
  isa => 'ZMQ::Declare::ZDCF::Encoder',
  default => sub {ZMQ::Declare::ZDCF::Encoder::JSON->new},
);

# FIXME ditch notion of "schema"

sub create_schema {
  my $self = shift;
  my $name = shift;

  my $tree = $self->tree;

  my $schema_def = $tree->{schemas}{$name};
  Carp::croak("Unknown schema '$name'") if not defined $schema_def;

  my $schema = Schema->new(name => $name);
  $schema->extra_options( Clone::clone($schema_def->{extra_options} || {}) );

  $self->_build_components($schema, $schema_def);

  return $schema;
}

sub _build_components {
  my $self = shift;
  my $schema = shift;
  my $spec = shift;

  my $components_spec = $spec->{components};
  Carp::croak("Schema needs {components}")
    if not defined $components_spec
    or not ref($components_spec) eq 'HASH';

  foreach my $comp_name (keys %$components_spec) {
    my $comp = $self->_build_component($schema, $comp_name, $components_spec->{$comp_name});
    $schema->add_component($comp);
  }
}

sub _build_component {
  my ($self, $schema, $name, $spec) = @_;
  my $comp = Component->new(
    name => $name,
    schema => $schema,
  );
  $comp->context( $self->_build_context($comp, $spec->{context}) );

  foreach my $sock_spec (@{$spec->{sockets} || []}) {
    push @{$comp->sockets}, $self->_build_socket($comp, $sock_spec);
  }

  return $comp;
}

sub _build_context {
  my ($self, $comp, $cxt_spec) = @_;
  return Context->new(%$cxt_spec, component => $comp);
}

sub _build_socket {
  my ($self, $comp, $sock_spec) = @_;
  my %sspec = %$sock_spec;
  my $options = delete $sspec{options};

  return Socket->new(
    %sspec,
    component => $comp,
    options => ($options ? Clone::clone($options) : {}),
  );
}

no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

ZMQ::Declare::ZDCF - Object representing a 0MQ-declare specification

=head1 SYNOPSIS

  use ZMQ::Declare;

  my $spec = ZMQ::Declare::ZDCF->new(src => $json_spec);
  my $dev = $spec->get_device("server");
  $dev->implement(sub {
    ...
  });

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
