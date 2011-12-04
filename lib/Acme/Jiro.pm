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
    '無し'       => { magic => 'ナシ' },
    '少なめ'     => { magic => 'スクナメ' },
    '普通'       => { magic => '' },
    '多め'       => { magic => 'マシ' },
    '非常に多め' => { magic => 'マシマシ' },
    '極めて多め' => { magic => 'チョモランマ' },
    '半分'      => { magic => 'ハンブン' },
    '固め'      => { magic => 'カタメ' },
);

my %parameter = (
    '麺'       => { volume => [ qw/少なめ 半分 普通/ ], magic => 'メン', default => '普通' },
    '固さ'     => { volume => [ qw/普通 固め/ ], default => '普通' },
    '野菜'     => { volume => [ qw/無し 少なめ 普通 多め 非常に多め 極めて多め/ ],
                    magic => 'ヤサイ', default => '普通' },
    '背脂'     => { volume => [ qw/無し 少なめ 普通 多め 非常に多め / ],
                    magic => 'アブラ', default => '普通' },
    'タレ'     => { volume => [ qw/少なめ 普通 多め 非常に多め/ ],
                    magic => 'カラメ', default => '普通' },
    'にんにく' => { volume => [ qw/無し 少なめ 多め 非常に多め/ ],
                    magic => 'ニンニク', default => '無し' },
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

    for my $key (qw/麺 固さ 野菜 背脂 タレ にんにく/) {
        my %param_volume;
        my $index = 1;
        for my $k (qw/無し 少なめ 半分 普通 多め 非常に多め 極めて多め 固め/) {
            if (grep { $k eq $_ } @{$parameter{$key}->{volume}}) {
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
    my $before_passing = '';

    if ($copy_param{'固さ'} ne '普通') {
        $before_passing .= $volume{ $copy_param{'固さ'} }->{magic};
    }
    delete $copy_param{'固さ'};

    if ($copy_param{'麺'} ne '普通') {
        $before_passing .= ($volume{$copy_param{'麺'}}->{magic});
    }
    delete $copy_param{'麺'};

    if ($before_passing) {
        $str .= "(Before passing ticket) " . $before_passing . "\n";
    }

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

sub get_valid_volume {
    my ($self, $key) = @_;

    unless (defined $key) {
        Carp::croak("'key' parameter is not defined");
    }

    unless (exists $parameter{$key}) {
        Carp::croak("Invalid parameter '$key'");
    }

    return @{$parameter{$key}->{volume}};
}

sub _param_magic {
    $parameter{ $_[0] }->{magic};
}

sub _volume_magic {
    $volume{ $_[0] }->{magic};
}

sub _is_valid_volume {
    my ($param, $value) = @_;

    return 1 if exists $volume{$value};
    return 0;
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
      '固さ'     => '固め',
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

=item 固さ :{'普通', '固め'}

=item 野菜 :{'無し', '少なめ', '普通', '多め', '非常に多め', '極めて多め'}

=item 背脂 :{'無し', '少なめ', '普通', '多め', '非常に多め'}

=item タレ :{'普通', '多め', '非常に多め'}

=item にんにく :{'無し', '少なめ', '多め', '非常に多め'}

=back

=head2 Instance Methods

=head3 C<< $jiro->prompt >>

Choose from options of each parameters.

=head3 C<< $jiro->magic :Str >>

Return Jiro's magic as string. You utter this magic.

=head3 C<< $jiro->valid_volume($key) :Array[Str] >>

Return valid volumes of C<$key>.

=head1 AUTHOR

Syohei YOSHIDA E<lt>syohex@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2011- Syohei YOSHIDA

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
