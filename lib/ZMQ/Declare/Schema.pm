package ZMQ::Declare::Schema;
use 5.008001;
use Moose;

use Scalar::Util ();
use Carp ();

use ZMQ::Declare::Constants qw(:namespaces);
require ZMQ::Declare;

has 'name' => (
  is => 'rw',
  isa => 'String',
  required => 1,
);

has 'components' => (
  is => 'ro',
  isa => 'HashRef[ZMQ::Declare::Component]',
  default => sub { {} },
);

sub get_component {
  my $self = shift;
  my $name = shift;
  return $self->components->{$name} || croak("Unknown Component '$name'");
}

sub add_component {
  my $self = shift;
  my $comp = shift;
  $self->components->{$comp->name} = $comp;
}

no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

ZMQ::Declare::Schema - A ZMQ::Declare Schema

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
