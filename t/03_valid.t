use strict;
use warnings;
use Test::More;

use utf8;
use Acme::Jiro;

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

can_ok('Acme::Jiro', 'get_valid_param');

my @ret = Acme::Jiro->get_valid_param('麺');
my %param = map { $_ => 1 } @ret;
is_deeply(\%param, {
    '少なめ' => 1, '普通' => 1, '半分' => 1
}, 'valid 麺 volume');

eval {
    Acme::Jiro->get_valid_param();
};
like $@, qr/not defined/, 'key parameter is not defined';

eval {
    Acme::Jiro->get_valid_param('煮卵');
};
like $@, qr/Invalid parameter/, 'invalid key';

done_testing;
