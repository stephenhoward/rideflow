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
        $self->_get_all_attributes
    };
}

sub _dump_property {
    my ( $self, $value ) = @_;

    return $value if ! ref $value;

    return [ map { $self->_dump_property($_) } @$value ] if ref $value eq 'ARRAY';

    return { map { $_ => $self->_dump_property( $value->{$_} ) } keys %$value } if ref $value eq 'HASH';

    return $value->dump if $value->can('does') && $value->does('Model::Envoy');

    return undef;
}

sub _get_all_attributes {
    my ( $self ) = @_;

    return grep { $_->name !~ /^_/ } $self->meta->get_all_attributes;
}

package Model::Envoy::Meta::Attribute::Trait::Envoy;
use Moose::Role;
Moose::Util::meta_attribute_alias('Envoy');

use Moose::Util::TypeConstraints;

has moose_class => (
    is  => 'ro',
    isa => 'Str',
);

around '_process_options' => sub { _install_types(@_) };

sub _install_types {
    my ( $orig, $self, $name, $options ) = @_;

    return unless grep { $_ eq __PACKAGE__ } @{$options->{traits} || []};

    unless( find_type_constraint('Array_of_Hashref') ) {

        subtype 'Array_of_HashRef',
            as 'ArrayRef[HashRef]';
    }
    unless ( find_type_constraint('Array_of_Object') ) {

        subtype 'Array_of_Object',
            as 'ArrayRef[Object]';
    }
    if ( $options->{isa} =~ / ArrayRef \[ (.+?) \]/x ) {
        $options->{moose_class} = $1;
        $options->{isa} = $self->_coerce_array($1);
    }
    elsif( $options->{isa} =~ / Maybe  \[ (.+?) \]/x ) {
        $options->{moose_class} = $1;
        $options->{isa} = $self->_coerce_maybe($1);
    }
    else {
        $self->_coerce_class($options->{isa});
    }

    $options->{coerce} = 1;

    return $self->$orig($name,$options);
}

sub _coerce_array {
    my ( $self, $class ) = @_;

    my $type = ( $class =~ / ( [^:]+ ) $ /x )[0];

    unless( find_type_constraint("Array_of_$type") ) {

        subtype "Array_of_$type",
            as "ArrayRef[$class]";

        coerce   "Array_of_$type",
            from "Array_of_Object",
            via  { [ map { $class->new_from_db($_) } @{$_} ] },

            from 'Array_of_HashRef',
            via  { [ map { $class->new($_) } @{$_} ] };
    }

    return "Array_of_$type";
}

sub _coerce_maybe {
    my ( $self, $class ) = @_;
    my $type = ( $class =~ /\:\:([^:]+)$/ )[0];

    unless( find_type_constraint("Maybe_$type") ) {

        subtype "Maybe_$type",
            as "Maybe[$class]";

        coerce   "Maybe_$type",
            from 'Object',
            via  { $class->new_from_db($_) },

            from 'HashRef',
            via { $class->new($_) };
    }

    return "Maybe_$type";
}

sub _coerce_class {
    my ( $self, $class ) = @_;
    my $type = ( $class =~ /\:\:([^:]+)$/ )[0];

    coerce   $class,
        from 'Object',
        via  { $class->new_from_db($_) },

        from 'HashRef',
        via { $class->new($_) };
}

package Moose::Meta::Attribute::Custom::Trait::Envoy;
    sub register_implementation {
        'MooseX::Meta::Attribute::Trait::Envoy'
    };

1;