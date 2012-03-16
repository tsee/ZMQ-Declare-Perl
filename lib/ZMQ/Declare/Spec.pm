package ZMQ::Declare::Spec;
use 5.008001;
use Moose;
our $VERSION = '0.01';

use Moose::Util::TypeConstraints;

use ZMQ::Declare::Constants qw(:all);
use Carp ();
use JSON ();

require ZMQ::Declare;

subtype 'SpecTree'
  => as 'HashRef';

coerce 'SpecTree'
  => from 'FileHandle'
    => via { JSON::decode_json(do {local $/; <$_>}) },
  => from 'ScalarRef[Str]'
    => via { JSON::decode_json($$_) },
  => from 'Str'
    => via {
        my $filename = $_;
        local $/;
        use autodie;
        open my $fh, "<", $filename;
        my $outhash = JSON::decode_json(<$fh>);
        close $fh;
        return $outhash;
    };

has 'tree' => (
  is => 'rw',
  isa => 'SpecTree',
  required => 1,
  coerce => 1,
);

sub create_schema {
  my $self = shift;
  my $name = shift;

  my $tree = $self->tree;

  my $schema_def = $tree->{schemas}{$name};
  Carp::croak("Unknown schema '$name'") if not defined $schema_def;

  return Schema->new(name => $schema_def->{name});
}

sub _build_components {
  my $self = shift;
  my $schema = shift;

  my $components_spec = $schema->{components};
  Carp::croak("Schema needs {components}")
    if not defined $components_spec
    or not ref($components_spec) eq 'HASH';

  foreach my $comp_name (keys %$components_spec) {
    my $comp = $self->_build_component($schema, $comp_name, $components_spec);
    $schema->add_component($comp);
  }
}

sub _build_component {
  my ($self, $schema, $name, $spec) = @_;
  my $comp = Component->new(
    name => $name,
    schema => $schema,
  );

  foreach my $sock_spec (@{$spec->{sockets} || []}) {
    $comp->add_socket( $self->_build_socket($comp, $sock_spec) );
  }

  return $comp;
}

sub _build_socket {
  my ($self, $comp, $spec) = shift;
  my $sock_spec = shift;
  my $sock = Socket->new(%$sock_spec, component => $comp);
}

no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

ZMQ::Declare::Spec - Object representing a 0MQ-declare specification

=head1 SYNOPSIS

  use ZMQ::Declare;

  my $spec = ZMQ::Declare::Spec->new(src => $json_spec);
  my $schema = $spec->create_schema("weather_info");
  my $comp = $spec->get_component("server");
  $comp->implement(sub {
    ...
  });

=head1 DESCRIPTION

=head1 SEE ALSO

L<ZMQ>

=head1 AUTHOR

Steffen Mueller, E<lt>smueller@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Steffen Mueller

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
