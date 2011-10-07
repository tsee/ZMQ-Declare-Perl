package ZeroMQ::Declare;

use 5.008001;
use strict;
use warnings;

our $VERSION = '0.01';

use constant({
  map {$_ => "ZeroMQ::Declare::$_"} qw(App Socket)
});

use Exporter;
our (@ISA, @EXPORT_OK, %EXPORT_TAGS);
BEGIN {
  @ISA = qw(Exporter);
  @EXPORT_OK = qw();
  %EXPORT_TAGS = (
    'namespaces' => [qw(App Socket)],
  );
}

require ZeroMQ::Declare::Schema;
require ZeroMQ::Declare::App;

1;
__END__

=head1 NAME

ZeroMQ::Declare - Declare ZeroMQ infrastructure

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
