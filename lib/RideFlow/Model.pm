package RideFlow::Model;

use Moose;
use Scalar::Util 'blessed';

use Moose::Util::TypeConstraints;

has model => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

sub m {

    my ( $class, $name ) = @_;

    $name =~ s/^RideFlow::Model:://;

    return $class->new( model => "RideFlow::Model::$name" );
}

sub db {
    my ( $class, $db_class ) = @_;

    my $type = 'RideFlow::Model::' . $db_class->model;

    return $class->new( model => $type );
}

sub build {
    my( $self, $params, $no_rel ) = @_;

    if ( ! ref $params ) {
        die "Cannot build a ". $self->model ." from '$params'";
    }
    elsif( ref $params eq 'HASH' ) {
        return $self->model->new(%$params);
    }
    elsif( ref $params eq 'ARRAY' ) {
        die "Cannot build a ". $self->model ." from an Array Ref";
    }
    elsif( blessed $params && $params->isa( $self->model ) ) {
        return $params;
    }
    elsif( blessed $params && $params->isa( 'RideFlow::DB::Result' ) ) {

        my $type = ( ( ref $params ) =~ / ( [^:]+ ) $ /x )[0];

        return RideFlow::Model->m( $type )->model->_new_from_db($params, $no_rel);
    }
    else {
        die "Cannot coerce a " . ( ref $params ) . " into a " . $self->model;
    }
}

sub fetch {
    my $self = shift;
    my %params;

    return undef unless @_;

    if ( @_ == 1 ) {

        my ( $id ) = @_;

        $params{id} = $id;
    }
    else {

        my ( $key, $value ) = @_;

        $params{$key} = $value;
    }

    if ( my $result = ($self->model->_schema->resultset( $self->model->dbic )
        ->search(\%params))[0] ) {

        return $self->model->_new_from_db($result);
    }

    return undef;
}

sub list {
    my( $self ) = @_;

    return [
        map {
            $self->model->_new_from_db($_);
        }
        $self->model->_schema->resultset( $self->model->dbic )->search()
    ];
}

sub _load_types {
    my ( $self, @types ) = @_;

    subtype 'Array_of_HashRef',
        as 'ArrayRef[HashRef]';

    foreach my $type ( @types ) {

        die "inalid type name '$type'" unless $type =~ /^[a-z]+$/i;

        my $package = "RideFlow::Model::$type";

        subtype "Array_of_$type",
            as "ArrayRef[$package]";

        subtype "Maybe_$type",
            as "Maybe[$package]";

        subtype "Array_of_DB_$type",
            as "ArrayRef[RideFlow::DB::Result::$type]";

        coerce   "Array_of_$type",
            from "Array_of_DB_$type",
            via  { [ map { $package->_new_from_db($_) } @{$_} ] },

            from 'Array_of_HashRef',
            via  { [ map { $package->new($_) } @{$_} ] };

        coerce   "Maybe_$type",
            from "RideFlow::DB::Result::$type",
            via  { $package->_new_from_db($_) },

            from 'HashRef',
            via { $package->new($_) };

        coerce   "RideFlow::Model::$type",
            from "RideFlow::DB::Result::$type",
            via  { $package->_new_from_db($_) },

            from 'HashRef',
            via { $package->new($_) };
    }


    foreach my $type ( @types ) {
        eval "use RideFlow::Model::$type";
        die "Could not load model type '$type': $@" if $@;
    }



}

BEGIN {
    require RideFlow::Models;
};

1;