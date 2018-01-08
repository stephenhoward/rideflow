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

    foreach my $attr ( $self->_get_all_attributes ) {

        my $name = $attr->name;

        if ( exists $hashref->{$name} ) {

            $self->$name( $hashref->{$name} );
        }
    }

    return $self;
}

sub delete {
    my ( $self ) = @_;

    $self->db_delete();

    return 1;
}

sub dump {
    my ( $self ) = @_;

    return {
        map  { $_ => $self->_dump_property( $self->$_ ) }
        grep { defined $self->$_ }
        @{$self->_dbic_attrs}
    };
}

sub _dump_property {
    my ( $self, $value ) = @_;

    return $value if ! ref $value;

    return [ map { $self->_dump_property($_) } @$value ] if ref $value eq 'ARRAY';

    return { map { $_ => $self->_dump_property( $value->{$_} ) } keys %$value } if ref $value eq 'HASH';

    return $value->dump if $value->isa('RideFlow::Model::Base');

    return undef;
}

sub _get_all_attributes {
    my ( $self ) = @_;

    return grep { $_->name !~ /^_/ } $self->meta->get_all_attributes;
}

sub _relationship_accessor {

    my $self     = shift;
    my $property = shift;

    if ( ! @_ ) {

        my $getter = '_get_' . $property;
        return $self->$getter;
    }
    else {
        my $setter = '_set_' . $property;
        use Data::Dumper; warn Dumper $self->_transform_relationship_input($property, @_);
        $self->$setter( $self->_transform_relationship_input( $property, @_ ) );
    }
}

sub _transform_relationship_input {
    my ( $self, $property, $value ) = @_;

    my $attr    = $self->meta->find_attribute_by_name($property);
    my $type    = $attr->type_constraint->type_parameter;
    my $factory = RideFlow::Model->m($type);

    return ( $attr->rel =~ /to_many$/ )
        ? [
            map { $factory->build($_) }
            ( ref $value eq 'ARRAY'
                ? @$value
                : defined $value
                    ? ( $value )
                    : ()
            )
        ]
        : $factory->build($_);
}

1;