package RideFlow::Model::Base;

use Moose;

use RideFlow::DB;

my $schema;

sub list {
    my( $class ) = @_;

    return [
        map {
            $class->_new_from_db($_);
        }
        @{$class->_schema->resultset( $class->dbic )->search()->all() || []}
    ];
}

sub _schema {
    $schema ||= RideFlow::DB->db_connect();
}

sub _new_from_db {
    my ( $class, $db_result ) = @_;

    return $class->new( _dbic_result => $db_result );
}

sub save {
    my ( $self ) = @_;

    if ( $self->_dbic_result && $self->_dbic_result->in_storage ) {
        $self->_dbic_result->update
    }
    else {
        $self->_dbic_result( $self->_schema->resultset( $self->dbic )->create(
            $self->dump
        ))->insert();
    }

    return $self;
}

sub dump {
    my ( $self ) = @_;

    return {
        map  { $_ => $self->_dump_attribute( $self->$_ ) }
        grep { defined $self->$_ }
        @{$self->_dbic_attrs}
    };
}

sub _dump_attribute {
    my ( $self, $value ) = @_;

    return $value if ! ref $value;

    return [ map { $self->_dump_attribute($_) } @$value ] if ref $value eq 'ARRAY';

    return { map { $_ => $self->_dump_attribute( $value->{$_} ) } keys %$value } if ref $value eq 'HASH';

    return $value->dump if $value->isa('RideFlow::Model::Base');

    return undef;
}

1;