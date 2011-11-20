package Acme::Jiro;

use 5.008_001;

use strict;
use warnings;

use utf8;
use Carp ();
use Scalar::Util qw(looks_like_number);
use List::MoreUtils qw(all);

use IO::Prompt::Simple ();

binmode STDERR, ":utf8";

our $VERSION = '0.01';

my %volume = (
    '無し'       => { id => 1, magic => 'ナシ' },
    '少なめ'     => { id => 2, magic => 'スクナメ' },
    '普通'       => { id => 3, magic => '' },
    '多め'       => { id => 4, magic => 'マシ' },
    '非常に多め' => { id => 5, magic => 'マシマシ' },
    '極めて多め' => { id => 6, magic => 'チョモランマ' },
);

my %parameter = (
    '麺'       => { volume => [ 2..3 ], magic => 'メン', default => '普通' },
    '野菜'     => { volume => [ 1..6 ], magic => 'ヤサイ', default => '普通' },
    '背脂'     => { volume => [ 1..5 ], magic => 'アブラ', default => '普通' },
    'タレ'     => { volume => [ 3..5 ], magic => 'カラメ', default => '普通' },
    'にんにく' => { volume => [ 1..2, 4..5 ], magic => 'ニンニク', default => '無し' },
);

sub new {
    my ($class, %args) = @_;

    my %info;
    for my $key (keys %parameter) {
        my $ret;

        if ($args{$key} && ($ret = _is_valid_volume($key, $args{$key})) ) {
            $info{$key} = $args{$key};
        } else {
            Carp::carp("$args{$key} is invalid parameter\n") if defined $ret && $ret == 0;
            $info{$key} = $parameter{$key}->{default};
        }
    }

    bless \%info, $class;
}

sub prompt {
    my $self = shift;

    for my $key (qw/麺 野菜 背脂 スープ にんにく/) {
        my %param_volume;
        my $index = 1;
        for my $k (qw/無し 少なめ 普通 多め 非常に多め 極めて多め/) {
            if (grep { $volume{$k}->{id} == $_ } @{$parameter{$key}->{volume}}) {
                $param_volume{$index++} = $k;
            }
        }

        $self->{$key} = IO::Prompt::Simple::prompt "select $key parameter", {
            anyone  => \%param_volume,
            encode  => 'utf-8',
            verbose => 1,
        };
    }
}

sub magic {
    my $self = shift;

    my %copy_param = %{$self};

    my $str = '';
    if ($copy_param{'麺'} eq '少なめ') {
        $str .= "(Before passing ticket) ";
        $str .= ($parameter{'麺'}->{magic} . $volume{'少なめ'}->{magic} . "\n");
    }
    delete $copy_param{'麺'};

    if ((all { $self->{$_} eq '普通' } qw/野菜 背脂 タレ/)
        && $self->{'にんにく'} eq '無し') {
        $str .= 'ソノママ';
        return $str;
    }

    my %check_same_value;
    $check_same_value{ $self->{$_} }++ for qw/野菜 背脂 タレ にんにく/;
    if (scalar keys %check_same_value == 1) {
        $str .= ("ゼン" . _volume_magic($self->{'野菜'}));
        return $str;
    }

    %check_same_value = ();
    $check_same_value{ $self->{$_} }++ for qw/背脂 タレ にんにく/;
    if (scalar keys %check_same_value == 1) {
        if ($self->{'野菜'} eq '極めて多め') {
            $str .= 'ゼン'   . _volume_magic($self->{'背脂'});
            $str .= _volume_magic($self->{'野菜'});
        } else {
            $str .= 'ヤサイ' . _volume_magic($self->{'野菜'});
            $str .= 'ホカ' . _volume_magic($self->{'背脂'});
        }
        return $str;
    }

    my %params;
    while (my ($param, $volume) = each %copy_param) {
        push @{$params{$volume}}, $param;
    }

    my $is_chomolungma = 0;
    while (my ($volume, $param) = each %params) {
        if ($volume eq '極めて多め') {
            $is_chomolungma = 1;
            next;
        }

        unless ($volume eq '普通') {
            $str .= _param_magic($_) for @{$params{$volume}};
            $str .= _volume_magic($volume);
        }
    }

    if ($is_chomolungma) {
        $str .= _volume_magic('極めて多め');
    }

    return $str;
}

sub _param_magic {
    $parameter{ $_[0] }->{magic};
}

sub _volume_magic {
    $volume{ $_[0] }->{magic};
}

sub _is_valid_volume {
    my ($param, $value) = @_;

    my @valid_volumes = @{$parameter{$param}->{volume}};
    if (looks_like_number($value)) {
        return grep { $value == $_ } @valid_volumes;
    } else {
        return 0 unless exists $volume{$value};
        return grep { $volume{$value}->{id} eq $_ } @valid_volumes;
    }
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

Acme::Jiro - Jiro is not a ramen, Jiro is Jiro

=head1 SYNOPSIS

  use Acme::Jiro;

  my $jiro = Acme::Jiro->new(
      '麺'       => '普通',
      '野菜'     => '極めて多め',
      '背脂'     => '多め',
      'タレ'     => '非常に多め',
      'にんにく' => '非常に多め',
  );
  print $jiro->magic, "\n";

=head1 DESCRIPTION

Acme::Jiro is Jiro's magic generator inspired by
L<http://www.cl.ecei.tohoku.ac.jp/~yuki.h/jiro/>.

=head1 INTERFACE

=head2 Class Methods

=head3 C<< Acme::Jiro->new(%args) :Acme::Jiro >>

Creates and returns a new Acme Jiro instance with I<%args>.
If I<%args> has invalid parameter, Acme::Jiro let you input valid
parameter.

I<%args> might be:

=over

=item 麺 :{'少なめ', '普通'}

=item 野菜 :{'無し', '少なめ', '普通', '多め', '非常に多め', '極めて多め'}

=item 背脂 :{'無し', '少なめ', '普通', '多め', '非常に多め'}

=item タレ :{'普通', '多め', '非常に多め'}

=item にんにく :{'無し', '少なめ', '多め', '非常に多め'}

=back

=head2 Instance Methods

=head3 C<< $jiro->magic :Str >>

Return Jiro's magic as string. You utter this magic.

=head1 AUTHOR

Syohei YOSHIDA E<lt>syohex@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2011- Syohei YOSHIDA

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
