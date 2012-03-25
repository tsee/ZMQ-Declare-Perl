package ZMQ::Declare::ZDCF::Validator;
use 5.008001;
use Moose;
our $VERSION = '0.01';

use Data::Rx;

# The following spec snippets are shared between ZDCF 0.1 and ZDCF 1.0
my $context_schema =  { # the top level context obj/hash
  type => '//rec',
  optional => { # can have these properties
    iothreads => { type => '//int', range => {min => 1} },
    verbose => '//bool',
  },
};
my $option_schema = {
  type => '//rec',
  optional => {
    "hwm"          => { type => '//int' },
    "swap"         => { type => '//int' },
    "affinity"     => { type => '//int' },
    "identity"     => { type => '//str' },
    "subscribe"    => { type => '//str' },
    "rate"         => { type => '//int' },
    "recovery_ivl" => { type => '//int' },
    "mcast_loop"   => { type => '//bool' },
    "sndbuf"       => { type => '//int' },
    "rcvbuf"       => { type => '//int' },
  },
};
my $string_or_value_ary_schema = {
  type => '//any',
  of => [
    { type => '//str' },
    { type => '//arr', length => {min => 1}, contents => "//str" },
  ]
};
my $socket_type_schema = {
  type => '//any',
  of => [
    map {
      { type => '//str', value => $_ },
      { type => '//str', value => uc($_) }
    } qw(sub pub req rep xreq xrep push pull pair)
  ]
};
my $socket_schema = {
  type => '//any',
  of => [
    {
      type => '//rec',
      required => {
        type => $socket_type_schema,
        bind => $string_or_value_ary_schema,
      },
      optional => {
        connect => $string_or_value_ary_schema,
        option => $option_schema,
      },
    },
    {
      type => '//rec',
      required => {
        type => $socket_type_schema,
        connect => $string_or_value_ary_schema,
      },
      optional => {
        bind => $string_or_value_ary_schema,
        option => $option_schema,
      },
    }
  ]
};

# The following are versioned
# First for ZDCF 0.1
my $device_schema_0 = {
  type => '//rec',
  # device must have property called 'type'
  required => { 'type' => {type => '//str'} },
  rest => {type => '//map', values => $socket_schema}, # anything else is a socket (sigh)
};
my $base_zdcf_schema_0 = {
  type => '//rec',
  optional => {
    context => $context_schema,
    version => { type => '//num', range => {min => 0} },
  },
  rest => {type => '//map', values => $device_schema_0}, # anything but the context is a device
};

# Now ZDCF 1.0
my $device_schema_1 = {
  type => '//rec',
  optional => {
    # device CAN have property called 'type' (no longer required)
    'type' => {type => '//str'},
    'sockets' => {
      type => '//map',
      values => $socket_schema
    },
  },
};
my $app_schema_1 = {
  type => '//rec',
  optional => {
    context => $context_schema,
    devices => { type => '//map', values => $device_schema_1 },
  },
};
my $base_zdcf_schema_1 = {
  type => '//rec',
  required => {
    version => { type => '//num', range => {min => 0} },
  },
  optional => {
    apps => { type => '//map', values => $app_schema_1 },
  },
};


my $rx = Data::Rx->new;

my %validator_schemata;
sub _get_validator {
  my $version = shift;

  # normalize version
  my $major_version = int($version);

  if (not exists $validator_schemata{$major_version}) {
    if ($major_version == 0) {
      my $validator_schema = $rx->make_schema($base_zdcf_schema_0);
      $validator_schemata{$major_version} = $validator_schema;
    }
    elsif ($major_version == 1) {
      my $validator_schema = $rx->make_schema($base_zdcf_schema_1);
      $validator_schemata{$major_version} = $validator_schema;
    }
    else {
      die __PACKAGE__ . " does not support ZDCF specification version $version";
    }
  }

  return $validator_schemata{$major_version};
}

sub validate {
  my $self = shift;
  my $structure = shift;

  # Just extract the spec version so we use the right validation code
  return 0 if not ref($structure) eq 'HASH';
  my $spec_version = $structure->{version} || '0'; # 0 == pre-versioned spec

  return _get_validator($spec_version)->check($structure);
}

no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

ZMQ::Declare::ZDCF::Validator - ZDCF validator

=head1 SYNOPSIS

  use ZMQ::Declare;
  my $validator = ZMQ::Declare::ZDCF::Validator->new;
  unless ($validator->check($datastructure)) {
    die "Input data structure is not ZDCF!"
  }

=head1 DESCRIPTION

Validates that a given nested Perl data structure (arrays, hashes, scalars)
is actually a valid ZDCF tree.

=head1 METHODS

=head2 validate

Returns true if the given Perl data structure is a valid ZDCF tree, false
otherwise.

Dies if the specification version of the ZDCF tree is unsupported.

=head1 SEE ALSO

The ZDCF RFC L<http://rfc.zeromq.org/spec:17>

L<Data::Rx>, L<http://rx.codesimply.com/index.html>

L<ZeroMQ>

=head1 AUTHOR

Steffen Mueller E<lt>smueller@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Steffen Mueller

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
