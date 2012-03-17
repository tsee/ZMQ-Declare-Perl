package ZMQ::Declare::Constants;

use 5.008001;
use strict;
use warnings;

our $VERSION = '0.01';

our %Namespaces;
BEGIN {
  %Namespaces = (
    map {$_ => "ZMQ::Declare::$_"} qw(Device ZDCF)
  );
  eval join "\n", map {qq[sub $_ () {"$Namespaces{$_}"}]} keys %Namespaces;
}

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = (keys %Namespaces);
our %EXPORT_TAGS = (
  'namespaces' => [keys %Namespaces],
  'all' => \@EXPORT_OK,
);

1;
__END__

=head1 NAME

ZMQ::Declare::Constants - Constants you can import

=head1 SYNOPSIS

  use ZMQ::Declare::Constants ...;

=head1 DESCRIPTION

=head1 SEE ALSO

L<ZMQ::Declare>

L<ZeroMQ>

=head1 AUTHOR

Steffen Mueller E<lt>smueller@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011,2012 by Steffen Mueller

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
