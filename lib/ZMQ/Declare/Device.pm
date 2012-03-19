package ZMQ::Declare::Device;
use 5.008001;
use Moose;

use POSIX ":sys_wait_h";
use Time::HiRes qw(sleep);
use Scalar::Util ();
use Carp ();
use ZeroMQ qw(:all);

use ZMQ::Declare;
use ZMQ::Declare::Constants qw(:namespaces);
use ZMQ::Declare::Device::Runtime;
use ZMQ::Declare::ZDCF;

has 'name' => (
  is => 'rw',
  isa => 'Str',
  required => 1,
);

has 'typename' => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

has 'implementation' => (
  is => 'rw',
);

has 'spec' => (
  is => 'ro',
  isa => 'ZMQ::Declare::ZDCF',
  required => 1,
);

sub run {
  my $self = shift;
  my %args = @_;

  my $callback = $self->implementation;
  Carp::croak("Need 'implementation' CODE reference to run ZMQ::Declare::Device '" . $self->name . "'")
    if not defined $callback or not ref($callback) eq 'CODE';

  if ($args{nforks} and $args{nforks} > 1) {
    $self->_fork_runtimes(\%args, $callback);
  }
  else {
    $callback->($self->make_runtime);
  }

  return ();
}

sub _fork_runtimes {
  my ($self, $args, $callback) = @_;

  my $nforks = $args->{nforks};

  my @pids;
  FORK: foreach my $i (1..$nforks) {
    my $pid = fork();
    if ($pid) { push @pids, $pid; }
    else { @pids = (); last FORK; }
  }

  if (@pids) { # parent
    my %pids = map {$_ => 1} @pids;
    while (keys %pids) {
      my $kid;
      do {
        $kid = waitpid(-1, WNOHANG);
        delete $pids{$kid} if $kid > 0;
      } while $kid > 0;
      sleep(0.1);
    }
  }
  else { # kid
    $callback->($self->make_runtime);
    exit(0);
  }
  return();
}

sub make_runtime {
  my $self = shift;
  # Note: Do not store non-weak refs to the runtime in the component.
  #       That wouldn't make a lot of sense anyway, since at least
  #       conceptually, one could have N runtime objects for the same
  #       Device.
  my $rt = ZMQ::Declare::Device::Runtime->new(
    device => $self,
  );

  my $zdcf = $self->spec;
  my $cxt = $zdcf->make_context();
  $rt->context($cxt);

  my @sockets;
  my @socket_names;
  foreach my $d_socket (@{$self->sockets}) {
    push @sockets, $d_socket->setup_socket($cxt);
    push @socket_names, $d_socket->name; # even if not defined
  }
  push @{ $rt->sockets }, @sockets;
  push @{ $rt->_socket_names}, @socket_names;

  return $rt;
}

no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

ZMQ::Declare::Device - A ZMQ::Declare Device object

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
