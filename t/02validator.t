use strict;
use warnings;
use Test::More;

use ZMQ::Declare::ZDCF::Validator;

my $validator = ZMQ::Declare::ZDCF::Validator->new;
isa_ok($validator, "ZMQ::Declare::ZDCF::Validator");

ok($validator->validate({}));

ok(!$validator->validate({foo => "bar"}));
ok(!$validator->validate("asd"));

ok($validator->validate(
  {
    context => {iothreads => 20},
  }
));

ok($validator->validate(
  {
    context => {iothreads => 20},
    foo => {type => "baz"},
  }
));

my $struct = {
  context => {iothreads => 20},
  foo => {
    type => "baz",
    foosock => {
      type => "pull",
      bind => "incproc://#1",
    },
  },
};
ok($validator->validate($struct));

$struct->{foo}{foosock}{type} = "doesntexist";
ok(!$validator->validate($struct));

done_testing();
