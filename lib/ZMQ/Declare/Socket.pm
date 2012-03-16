package ZMQ::Declare::Socket;
use 5.008001;
use strict;
use warnings;
use Scalar::Util ();
use Carp qw(croak);

use ZMQ::Declare::Constants qw(:namespaces);

use Class::XSAccessor getters => {_app=> 'app'};
use Class::XSAccessor getters => [qw(name type)];

sub new {
  my $class = shift;
  my $self = bless {
    name => undef,
    type => undef,
    binds => [],
    connects => [],
    @_,
  } => $class;

  if (defined $self->{app}) {
    Scalar::Util::weaken($self->{app});
  }
  else {
    croak("Need Component object for a new " . __PACKAGE__);
  }

  for my $attr (qw(name type)) {
    if (not defined $self->$attr) {
      croak("A " . __PACKAGE__ . " object needs a '$attr'");
    }
  }

  return $self;
}

sub endpoints {
  return @{$_[0]->{binds}}, @{$_[0]->{connects}};
}

sub bind_endpoints {
  return @{$_[0]->{binds}};
}

sub connect_endpoints {
  return @{$_[0]->{connects}};
}

sub _add_endpoint {
  my ($self, $ep, $target, $rest) = @_;

  my $schema = $self->_app->_schema;
  my $endpoint = $ep;
  $endpoint = $schema->endpoint($endpoint) if not ref $endpoint;
  $endpoint = $schema->add_endpoint($ep, @$rest) if not $endpoint;

  push @$target, $endpoint;
  Scalar::Util::weaken($target->[-1]);

  return $endpoint;
}

sub add_connect_endpoint {
  my $self = shift;
  my $address_or_e = shift;
  return $self->_add_endpoint($address_or_e, $self->{connects}, \@_);
}

sub add_bind_endpoint {
  my $self = shift;
  my $address_or_e = shift;
  return $self->_add_endpoint($address_or_e, $self->{binds}, \@_);
}

1;
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
