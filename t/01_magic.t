use strict;
use warnings;
use Test::More;

use Acme::Jiro;

use utf8;

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

my $default = Acme::Jiro->new();

ok $default;
isa_ok $default, 'Acme::Jiro';
is $default->magic, 'ソノママ', 'default parameters';

my $all_mashi = Acme::Jiro->new(
    '麺'       => '普通',
    '野菜'     => '多め',
    '背脂'     => '多め',
    'タレ'     => '多め',
    'にんにく' => '多め',
);

is $all_mashi->magic, 'ゼンマシ', 'all mashi';

my $all_mashimashi = Acme::Jiro->new(
    '麺'       => '普通',
    '野菜'     => '非常に多め',
    '背脂'     => '非常に多め',
    'タレ'     => '非常に多め',
    'にんにく' => '非常に多め',
);

is $all_mashimashi->magic, 'ゼンマシマシ', 'all mashimashi';

my $all_mashimashi_chomolungma = Acme::Jiro->new(
    '麺'       => '普通',
    '野菜'     => '極めて多め',
    '背脂'     => '非常に多め',
    'タレ'     => '非常に多め',
    'にんにく' => '非常に多め',
);

is $all_mashimashi_chomolungma->magic,
   'ゼンマシマシチョモランマ', 'all mashimashi chmolungma';

my $sonomama = Acme::Jiro->new(
    '麺'       => '普通',
    '野菜'     => '普通',
    '背脂'     => '普通',
    'タレ'     => '普通',
    'にんにく' => '無し',
);

is $sonomama->magic, 'ソノママ', 'no customize';

my $men_sukuname = Acme::Jiro->new(
    '麺'       => '少なめ',
    '野菜'     => '普通',
    '背脂'     => '普通',
    'タレ'     => '普通',
    'にんにく' => '無し',
);

like $men_sukuname->magic, qr/Before passing ticket/, 'men sukuname';
like $men_sukuname->magic, qr/スクナメ/, 'men sukuname2';

my $men_katame = Acme::Jiro->new(
    '固さ' => '固め',
);

like $men_katame->magic, qr/Before passing ticket/, 'men katame';
like $men_katame->magic, qr/カタメ/, 'men katame2';

my $chomolungma = Acme::Jiro->new(
    '麺'       => '少なめ',
    '野菜'     => '極めて多め',
    '背脂'     => '普通',
    'タレ'     => '普通',
    'にんにく' => '無し',
);

like $chomolungma->magic, qr/チョモランマ/, 'chomolungma';

my $hoka = Acme::Jiro->new(
    '麺'       => '少なめ',
    '野菜'     => '非常に多め',
    '背脂'     => '多め',
    'タレ'     => '多め',
    'にんにく' => '多め',
);

like $hoka->magic, qr/ホカ/, 'hoka';

my $hoka_chomo = Acme::Jiro->new(
    '麺'       => '少なめ',
    '野菜'     => '極めて多め',
    '背脂'     => '多め',
    'タレ'     => '多め',
    'にんにく' => '多め',
);

like $hoka_chomo->magic, qr/ゼン/, 'chomolungma';

my $has_invalid_param = Acme::Jiro->new(
    '麺'       => 'aaa',
    '野菜'     => 'aaa',
    '背脂'     => 'aaa',
    'タレ'     => 'aaa',
    'にんにく' => 'aaa',
);

is $has_invalid_param->magic, 'ソノママ', 'use default value';

done_testing;
