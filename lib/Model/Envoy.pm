package Model::Envoy;

use Moose::Role;

with 'MooseX::Storage::DBIC';

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
        map  { $_->name }
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

1;