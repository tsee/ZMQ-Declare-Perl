package ZeroMQ::Declare::App;
use 5.008001;
use strict;
use warnings;
use Scalar::Util ();
use Carp qw(croak);

use ZeroMQ qw(:all);
use ZeroMQ::Declare::Constants qw(:namespaces);

use Class::XSAccessor getters => {_schema => 'schema'};
use Class::XSAccessor getters => [qw(name)];

sub new {
  my $class = shift;
  my $self = bless {
    name => undef,
    sockets => {},
    @_,
  } => $class;

  if (defined $self->{schema}) {
    Scalar::Util::weaken($self->{schema});
  }
  else {
    croak("Need schema object for a new " . __PACKAGE__);
  }
  if (not defined $self->name) {
    croak("A " . __PACKAGE__ . " object needs a 'name'");
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

sub run {
  my $self = shift;
  my %args = @_;

  my $cxt = $args{cxt} || ZeroMQ::Context->new();
  my $runloop = $args{runloop} or die "Need a 'runloop'";

  my $socks = $self->{sockets};

  my %zmq_socks;
  foreach my $sock (values %$socks) {
    my $s = $zmq_socks{$sock->name} = $cxt->socket($sock->type);
    $s->bind($_->address) for $sock->bind_endpoints;
  }

  foreach my $sock (values %$socks) {
    my $s = $zmq_socks{$sock->name};
    $s->connect($_->address) for $sock->connect_endpoints;
  }

  $runloop->(context => $cxt, sockets => \%zmq_socks);
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
