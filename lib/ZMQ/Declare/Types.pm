package ZMQ::Declare::Types;
use 5.008001;
use strict;
use warnings;

our $VERSION = '0.01';

use Moose::Util::TypeConstraints;
use JSON ();
use ZeroMQ::Constants qw(:all);

#my %socket_types = (
#  ZMQ_PUB => ZMQ_PUB,
#  ZMQ_SUB => ZMQ_SUB,
#  ZMQ_PUSH => ZMQ_PUSH,
#  ZMQ_PULL => ZMQ_PULL,
#  ZMQ_UPSTREAM => ZMQ_UPSTREAM,
#  ZMQ_DOWNSTREAM => ZMQ_DOWNSTREAM,
#  ZMQ_REQ => ZMQ_REQ,
#  ZMQ_REP => ZMQ_REP,
#  ZMQ_PAIR => ZMQ_PAIR,
#  ZMQ_XREQ => ZMQ_XREQ,
#  ZMQ_XREP => ZMQ_XREP,
#  ZMQ_XPUB => ZMQ_XPUB,
#  ZMQ_XSUB => ZMQ_XSUB,
#);


my %zdcf_socket_types = (
  pub => ZMQ_PUB,
  sub => ZMQ_SUB,
  push => ZMQ_PUSH,
  pull => ZMQ_PULL,
  req => ZMQ_REQ,
  rep => ZMQ_REP,
  pair => ZMQ_PAIR,
  xreq => ZMQ_XREQ,
  xrep => ZMQ_XREP,
  xpub => ZMQ_XPUB,
  xsub => ZMQ_XSUB,

  # not official, just aliases
  upstream => ZMQ_UPSTREAM,
  downstream => ZMQ_DOWNSTREAM,
);

# FIXME reverse is not good enough here
#my %zdcf_numeric_socket_types = reverse %zdcf_socket_types;
#enum 'ZMQDeclareZDCFSocketType' => [keys %zdcf_socket_types];
#subtype 'ZMQDeclareNumericSocketType'
#  => as 'Int'
#  => where {exists $numeric_socket_types{$_}};
#coerce 'ZMQDeclareNumericSocketType'
#  => from 'Str'
#    => via {$socket_types{$_}};

sub zdcf_sock_type_to_number {
  my ($class, $type) = @_;
  return $zdcf_socket_types{$type};
}

enum 'ZMQDeclareSocketConnectType' => [qw(connect bind)];

my %zdcf_settable_sockopts = (
  hwm => ZMQ_HWM,
  swap => ZMQ_SWAP,
  affinity => ZMQ_AFFINITY,
  identity => ZMQ_IDENTITY,
  subscribe => ZMQ_SUBSCRIBE,
  rate => ZMQ_RATE,
  recovery_ivl => ZMQ_RECONNECT_IVL,
  mcast_loop => ZMQ_MCAST_LOOP,
  sndbuf => ZMQ_SNDBUF,
  rcvbuf => ZMQ_RCVBUF,
);

sub zdcf_settable_sockopt_type_to_number {
  my $class = shift;
  return $zdcf_settable_sockopts{shift()};
}


1;
__END__

=head1 NAME

ZMQ::Declare::Types - Type definitions for ZMQ::Declare

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
