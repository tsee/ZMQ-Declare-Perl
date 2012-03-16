package ZMQ::Declare::Endpoint;
use 5.008001;
use strict;
use warnings;
use Scalar::Util ();
use Carp qw(croak);

use Class::XSAccessor getters => {_schema => 'schema'};

sub new {
  my $class = shift;
  my $self = bless {
    @_,
  } => $class;

  if (defined $self->{schema}) {
    Scalar::Util::weaken($self->{schema});
  }
  else {
    croak("Need schema object for a new " . __PACKAGE__);
  }

  return $self;
}

sub get_address_for {
  die "Unimplemented in base class";
}

1;
__END__

=head1 NAME

ZMQ::Declare::Endpoint - A ZMQ::Declare Endpoint object

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
