package MooseX::Storage::DBIC;

use Moose::Role;
use Scalar::Util 'blessed';


# The name of the DBIx::Class ResultClass is stored here:
requires 'dbic';

# Model needs to provide its own connection to the database:
requires '_schema';

# The actual ResultClass for the model object is stored here:
has '_dbic_result',
    is      => 'rw',
    isa     => 'Maybe[Object]',
    default => sub {
        my ( $self ) = @_;

        my $result =  $self->_schema->resultset( $self->dbic )->new({
            map  { $_ => $self->$_ }
            grep { defined $self->$_ }
            @{$self->_dbic_columns}
        });

        return $result;
    };

sub db_save {
    my ( $self ) = @_;

    if ( $self->_dbic_result && $self->_dbic_result->in_storage ) {
        $self->_dbic_result->update;
    }
    else {
        $self->_dbic_result( $self->_schema->resultset( $self->dbic )->create(
            { map { $_ => $self->$_ } @{$self->_dbic_columns} }
        ))->insert();
    }

    return $self;
}

sub db_delete {
    my ( $self ) = @_;

    if ( $self->_dbic_result && $self->_dbic_result->in_storage ) {
        $self->_dbic_result->delete;
    }

    return;
}

sub _dbic_attrs {
    my ( $self ) = @_;

    return [
        map  { $_->name }
        grep { $_->does('DBIC') }
        $self->meta->get_all_attributes
    ];
}

sub _dbic_columns {
    my ( $self ) = @_;

    return [
        map  { $_->name }
        grep { $_->does('DBIC') && ! $_->is_relationship }
        $self->meta->get_all_attributes
    ];
}

sub _dbic_relationships {
    my ( $self ) = @_;

    return [
        map  { $_->name }
        grep { $_->does('DBIC') && $_->is_relationship }
        $self->meta->get_all_attributes
    ];
}

sub _new_from_db {
    my ( $class, $db_result, $no_rel ) = @_;

    return undef unless $db_result;

    my $data  = {};

    my %relationships = map { $_ => 1 } @{$class->_dbic_relationships};

    foreach my $attr ( grep { defined $db_result->$_ } @{$class->_dbic_attrs} ) {

        next if $no_rel && exists $relationships{$attr};

        if ( blessed $db_result->$attr && $db_result->$attr->isa('DBIx::Class::ResultSet') ) {

            my $factory = RideFlow::Model->db( $db_result->$attr->result_class );
            $data->{$attr} = [ map { $factory->build( $_, 1 ) } $db_result->$attr ];

        }
        else {
            $data->{$attr} = $db_result->$attr;
        }

    }

    return $class->new( _dbic_result => $db_result, %$data );
}

package RideFlow::Model::Meta::Attribute::Trait::DBIC;
use Moose::Role;
Moose::Util::meta_attribute_alias('DBIC');

use Moose::Util::TypeConstraints 'enum';
use Scalar::Util 'blessed';

has rel => (
    is  => 'ro',
    isa => enum(['belongs_to','has_many','many_to_many']),
    predicate => 'is_relationship'
);

has mm_rel => (
    is  => 'ro',
    isa => 'Str',
    predicate => 'is_many_to_many',
);

has primary_key => (
    is  => 'ro',
    isa => 'Bool',
    predicate => 'is_primary_key'
);

before '_process_options' => sub {
    my ( $self, $name, $options ) = @_;

    return unless grep { $_ eq __PACKAGE__ } @{$options->{traits} || []};

    $options->{trigger} //= sub {
        my( $instance, $value, $old_value ) = @_;

        $value = $self->_value_to_db($value);

        if ( ( $options->{rel} || '' ) eq 'many_to_many' ) {
            my $setter = 'set_' . $name;
            $instance->_dbic_result->$setter( $value );
        }
        else {
            $instance->_dbic_result->$name( $value );

        }
    }
};

sub _value_to_db {
    my ( $self, $value ) = @_;

        if ( ref $value eq 'ARRAY' ) {

            return [ map { $self->_value_to_db($_) } @$value ];
        }
        elsif ( blessed $value && $value->can('does') && $value->does('MooseX::Storage::DBIC') ) {

            return $value->_dbic_result;
        }

        return $value;

}

package Moose::Meta::Attribute::Custom::Trait::DBIC;
    sub register_implementation { 
        'MooseX::Meta::Attribute::Trait::DBIC'
    };

1;