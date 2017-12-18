package RideFlow::Model::Base;

use Moose;

use RideFlow::DB;

my $schema;

sub _schema {
    $schema ||= RideFlow::DB->db_connect();
}

sub fetch {
    my $class = shift;

    RideFlow::Model->m($class)->fetch(@_);
}

sub save {
    my ( $self ) = @_;

    $self->db_save;

    return $self;
}

sub update {
    my ( $self, $hashref ) = @_;

    foreach my $attr ( map { $_->name } $self->meta->get_all_attributes ) {

        if ( exists $hashref->{$attr} ) {
            $self->$attr( $hashref->{$attr} );
        }
    }

    return $self;
}

sub delete {
    my ( $self ) = @_;

    $self->db_delete();

    return;
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