package ZMQ::Declare;

use 5.008001;
use strict;
use warnings;

our $VERSION = '0.01';

use ZeroMQ ();

require ZMQ::Declare::Constants;
require ZMQ::Declare::Types;
require ZMQ::Declare::Schema;
require ZMQ::Declare::Component;
require ZMQ::Declare::Socket;
require ZMQ::Declare::Endpoint;
require ZMQ::Declare::Spec;
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

ZMQ::Declare - Declare 0MQ infrastructure

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
