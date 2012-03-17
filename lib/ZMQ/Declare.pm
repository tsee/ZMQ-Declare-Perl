package ZMQ::Declare;

use 5.008001;
use strict;
use warnings;

our $VERSION = '0.01';

use ZeroMQ ();

require ZMQ::Declare::Constants;
require ZMQ::Declare::Types;

require ZMQ::Declare::ZDCF;

require ZMQ::Declare::Schema;
require ZMQ::Declare::Component;
require ZMQ::Declare::Socket;
require ZMQ::Declare::Context;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = @ZMQ::Declare::Constants::EXPORT_OK;
our %EXPORT_TAGS = (
  'all' => \@EXPORT_OK,
  'namespaces' => $ZMQ::Declare::Constants::EXPORT_TAGS{namespaces},
);

ZMQ::Declare::Constants->import(':namespaces');

1;
__END__

=head1 NAME

ZMQ::Declare - Declarative 0MQ infrastructure

=head1 SYNOPSIS

  use ZMQ::Declare qw(:all);
  my $schema = Spec->new(tree => 'mynetwork.zspec')->create_schema("events");
  my $broker = $schema->get_component("event_broker");
  
  # This will create the actual 0MQ objects and connections, configure them,
  # and then hand control to your main loop!
  $broker->run( main => sub {
    my ($runtime) = @_;
    my $input_sock = $runtime->get_socket_by_name("listener");
    ... other sockets ...
    while (1) {
      ... recv, dispatch to other sockets ...
    }
  });

Actual, runnable examples can be found in the F<examples/>
subdirectory of the C<ZMQ::Declare> distribution.

=head1 DESCRIPTION

B<This is experimental software. Interfaces and implementation are subject to
change. If you are interested in using this in production, please get in touch
to gauge the current state of stability.>

0MQ is a light-weight messaging library built on TCP.

C<ZMQ::Declare> aims to provide a declarative and/or configuration
driven way of establishing a network of 0MQ sockets/connections.
Normally using the common Perl binding, L<ZeroMQ>, makes you to
explicitly write out the code to create 0MQ context and sockets, and
to write the connect/bind logic for each socket. Since the use of
0MQ commonly implies that multiple disjunct piece of software talk
to one another, it's easy to scatter this logic in many places.
(Which side of the connection is supposed to C<bind()> and which is
supposed to C<connect()> again?)
For what it's worth, I've always felt that the network components
that I've written were simply flying in close formation.

C<ZMQ::Declare> is an attempt to concentrate the information about
your I<network> of 0MQ sockets and connections in one place, to
create and connect all sockets for you, and to allow you to focus
on the actual implementation of the various components that talk
to one another using 0MQ.

The envisioned typical use of C<ZMQ::Declare> is that you write
a single I<zspec> specification file (with a simple JSON-based
format) that defines various components in your network and how
they interact with one another. The specification for I<zspec>
files can be found at L<ZMQ::Declare::ZSpecFormat>. This approach
means that as long as you have a library to handle I<zspec> files,
you can write your components in any programming language and mix
and match to your heart's content. For example, you might choose
to implement your right-loop message broker in C for performance,
but prefer to write the parallelizable worker components in
Perl for ease of development.

C<ZMQ::Declare> comes with a set of classes that mimic the normal
C<ZeroMQ>/0MQ objects. Instead of relying on a I<zspec> file, you
can use the API of these classes directly. In a future version,
you will be able to generate I<zspec> files from these object
hierarchies.

The C<ZMQ::Declare> object hierarchies can be passed around your
application safely. They are thread-safe (unlike, say a C<ZeroMQ::Socket>)
and the C<ZMQ::Declare::Socket> objects do not have any actual
connections yet.

=head1 SEE ALSO

L<ZMQ::Declare::ZSpecFormat>

L<ZeroMQ>

=head1 AUTHOR

Steffen Mueller E<lt>smueller@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011,2012 by Steffen Mueller

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
