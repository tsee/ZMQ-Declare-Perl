package ZeroMQ::Declare::Socket;
use 5.008001;
use strict;
use warnings;
use Scalar::Util ();
use Carp qw(croak);

use ZeroMQ::Declare qw(:namespaces);

use Class::XSAccessor {
  getters => {_app=> 'app'}
};

sub new {
  my $class = shift;
  my $self = bless {
    @_,
  } => $class;

  if (defined $self->{app}) {
    Scalar::Util::weaken($self->{app});
  }
  else {
    croak("Need App object for a new " . __PACKAGE__);
  }

  return $self;
}

1;
__END__

=head1 NAME

ZeroMQ::Declare::Socket - A ZeroMQ::Declare Socket object

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
