package ZeroMQ::Declare::App;
use 5.008001;
use strict;
use warnings;
use Scalar::Util ();
use Carp qw(croak);

use ZeroMQ::Declare qw(:namespaces);

use Class::XSAccessor {
  getters => {_schema => 'schema'}
};

sub new {
  my $class = shift;
  my $self = bless {
    sockets => {},
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

sub socket {
  my $self = shift;
  my $objs = $self->{sockets};
  return exists($objs->{$_[0]}) ? $objs->{$_[0]} : undef;
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

1;
__END__

=head1 NAME

ZeroMQ::Declare::App - A ZeroMQ::Declare App object

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
