package RideFlow::Model;

use Moose;

use RideFlow::Model::Route;
use RideFlow::Model::Vehicle;

has model => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

sub m {

    my ( $class, $name ) = @_;

    return $class->new( model => "RideFlow::Model::$name" );
}

sub create {
    my( $self, $params ) = @_;

    return $self->model->new($params)->save;
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

    if ( my $result = $self->model->_schema->resultset( $self->model->dbic )
        ->new_result(\%params)->get_from_storage ) {

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

1;