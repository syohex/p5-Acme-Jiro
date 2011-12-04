use strict;
use warnings;
use Test::More;

use utf8;
use Acme::Jiro;

can_ok('Acme::Jiro', 'get_valid_volume');

my @ret = Acme::Jiro->get_valid_volume('麺');
is_deeply(\@ret, ['少なめ', '普通'], 'valid 麺 volume');

eval {
    Acme::Jiro->get_valid_volume();
};
like $@, qr/not defined/, 'key parameter is not defined';

eval {
    Acme::Jiro->get_valid_volume('煮卵');
};
like $@, qr/Invalid parameter/, 'invalid key';

done_testing;
