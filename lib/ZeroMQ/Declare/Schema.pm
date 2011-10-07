package ZeroMQ::Declare::Schema;
use 5.008001;
use strict;
use warnings;
use Scalar::Util ();
use Carp qw(croak);

use ZeroMQ::Declare::Constants qw(:namespaces);

sub new {
  my $class = shift;
  my $self = bless {
    apps => {},
    endpoints => {},
    @_,
  } => $class;

  return $self;
}

sub endpoint {
  my $self = shift;
  my $objs = $self->{endpoints};
  return exists($objs->{$_[0]}) ? $objs->{$_[0]} : undef;
}

sub app {
  my $self = shift;
  my $objs = $self->{apps};
  return exists($objs->{$_[0]}) ? $objs->{$_[0]} : undef;
}

sub add_app {
  my $self = shift;
  my $name = shift;
  my %param = @_;
  $param{name} = $name;

  my $objs = $self->{apps};
  if (exists $objs->{$name}) {
    croak("Cannot add duplicate App of name '$name' to a " . __PACKAGE__);
  }

  my $obj = App->new(%param, schema => $self);
  $objs->{$name} = $obj;

  return $obj;
}

sub add_endpoint {
  my $self = shift;
  my $addr = shift;
  my %param = @_;
  $param{address} = $addr;

  my $objs = $self->{endpoints};
  if (exists $objs->{$addr}) {
    croak("Cannot add duplicate Endpoint with address '$addr' to a " . __PACKAGE__);
  }

  my $obj = Endpoint->new(%param, schema => $self);
  $objs->{$addr} = $obj;

  return $obj;
}

1;
__END__

=head1 NAME

ZeroMQ::Declare::Schema - A ZeroMQ::Declare Schema

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
