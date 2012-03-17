use strict;
use warnings;
use Test::More;

use ZMQ::Declare::ZDCF::Encoder::JSON;

my $enc = ZMQ::Declare::ZDCF::Encoder::JSON->new;
isa_ok($enc, "ZMQ::Declare::ZDCF::Encoder::JSON");

my $empty = $enc->decode('{}');
is_deeply($empty, {});

my $empty_json = $enc->encode({});
ok($empty_json =~ /^\s*\{\}\s*$/s);

done_testing();
