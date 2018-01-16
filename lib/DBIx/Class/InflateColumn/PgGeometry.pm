package DBIx::Class::InflateColumn::PgGeometry;

use strict;
use warnings;
use base qw/DBIx::Class/;
use Try::Tiny;

__PACKAGE__->load_components(qw/InflateColumn/);

my $point_rx = qr/\( \s* (-?\d+(?:\.\d+)?), \s* (-?\d+(?:\.\d+)?) \s* \)/x;

my %inflators = (
    point => sub {
        return [ ( $_[0] =~ $point_rx )[0,1] ];
    },
    lseg => sub {
        return _inflate_coordinates( ( $_[0] =~ /\[ \s* $point_rx \s* , \s* $point_rx \s* \]/x )[0..3] );
    },
    box => sub {
        return _inflate_coordinates( ( $_[0] =~ / $point_rx \s* , \s* $point_rx /x )[0..3] );
    },
    path => sub {
        return _inflate_coordinates( $_[0] =~ /  [\[\(]  \s*  ( $point_rx \s* )+ ( , \s* $point_rx \s* )*  [\]\)] /x );
    },
    polygon => sub {
        return _inflate_coordinates( $_[0] =~ /  \(  \s*  ( $point_rx \s* )+ ( , \s* $point_rx \s* )*  \) /x );
    },
);

my %deflators = (
    point => sub {
        my ( $value ) = @_;

        return '(' . join( ',' => @$value ) . ')';
    },
    lseg => sub {
        return _deflate_coordinates(@_);
    },
    box => sub {
        return _deflate_coordinates(@_);
    },
    path => sub {
        return _deflate_coordinates(@_);
    },
    polygon => sub {
        return _deflate_coordinates(@_);
    },
);

sub register_column {
    my ($self, $column, $info, @rest) = @_;

    $self->next::method($column, $info, @rest);

    my $data_type = lc( $info->{data_type} || '' );

    return unless $data_type;
    return unless defined $inflators{$data_type};

    $self->inflate_column(
        $column => {
            inflate => sub {
                my ( $value ) = @_;

                return try {
                    $inflators{ $data_type }->($value);
                }
                catch {
                    $self->throw_exception ("Error while inflating '$value' for $column on ${self}: $_");
                    undef;  # rv
                };
            },
            deflate => sub {
                my ( $value ) = @_;

                return try {
                    $deflators{ $data_type }->($value);
                }
                catch {
                    $self->throw_exception ("Error while deflating $column on ${self}: $_");
                    undef;  # rv
                };
            },
        }
    );
}

sub _inflate_coordinates {

    my @coords = @_;

    if ( @_ % 2 ) {

      die "odd number of coordinates, missing an x or a y";
    }

    my @return;

    while( $#coords > 2 ) {
        my( $x, $y ) = ( shift @coords, shift @coords );

        push @return, [ $x, $y ];
    }

    return \@return;
}

sub _deflate_coordinates {
    my ( $value ) = @_;

    return join( ',' =>
        map { '(' . join( ',' => @$_ ) . ')' }
        @$value
    ) || undef;
}

1;