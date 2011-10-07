package ZeroMQ::Declare::Endpoint;
use 5.008001;
use strict;
use warnings;
use Scalar::Util ();
use Carp qw(croak);

use ZeroMQ::Declare qw(:namespaces);

use Class::XSAccessor getters => {_schema => 'schema'};
use Class::XSAccessor getters => [qw(address)];

sub new {
  my $class = shift;
  my $self = bless {
    address => undef,
    @_,
  } => $class;

  if (defined $self->{schema}) {
    Scalar::Util::weaken($self->{schema});
  }
  else {
    croak("Need schema object for a new " . __PACKAGE__);
  }
  for my $attr (qw(address)) {
    if (not defined $self->$attr) {
      croak("A " . __PACKAGE__ . " object needs a '$attr'");
    }
  }

  return $self;
}

1;
__END__

=head1 NAME

ZeroMQ::Declare::Endpoint - A ZeroMQ::Declare Endpoint object

=head1 SYNOPSIS

  use ZeroMQ::Declare;

=head1 DESCRIPTION

=head1 SEE ALSO

L<ZeroMQ>

=head1 AUTHOR

Steffen Mueller, E<lt>smueller@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Steffen Mueller

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
