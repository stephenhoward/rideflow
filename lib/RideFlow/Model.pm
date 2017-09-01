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
    my ( $self, $id ) = @_;

    my $result = $self->model->_schema->resultset( $self->model->dbic )
        ->new_result({ id => $id })->get_from_storage;

    return $self->model->_new_from_db($result);
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