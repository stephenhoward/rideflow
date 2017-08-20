package RideFlow::Model::Base;

use Moose;

use RideFlow::DB;

my $schema;

has '_result',
    is  => 'rw',
    isa => 'Maybe[Object]';

sub list {
    my( $class ) = @_;

    return [
        map {
            $class->_new_from_db($_);
        }
        @{$class->_schema->resultset( $class->dbic )->search()->all()}
    ];
}

sub _schema {
    $schema ||= RideFlow::DB->db_connect();
}

sub _new_from_db {
    my ( $class, $db_result ) = @_;

    return $class->new( _result => $db_result );
}

sub _save {
    my ( $self ) = @_;

    if ( $self->_result ) {
        $self->_result->update
    }
    else {
        $self->_result( $self->schema->resultset( $self->dbic )->create(

        ));
    }

    return $self;
}

1;