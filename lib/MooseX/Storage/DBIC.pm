package MooseX::Storage::DBIC;

use Moose::Role;


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

        return $self->_schema->resultset( $self->dbic )->new({
            map { $_ => $self->$_ }
            @{$self->_dbic_attrs}
        });
    };

sub _dbic_attrs {
    my ( $self ) = @_;

    return [
        map  { $_->name }
        grep { $_->does('DBIC') }
        $self->meta->get_all_attributes
    ];
}

package RideFlow::Model::Meta::Attribute::Trait::DBIC;
use Moose::Role;
Moose::Util::meta_attribute_alias('DBIC');

before '_process_options' => sub {
    my ( $self, $name, $options ) = @_;

    $options->{trigger} //= sub {
        my( $instance, $value, $old_value ) = @_;

        $instance->_dbic_result->$name( $value );
    }
};

package Moose::Meta::Attribute::Custom::Trait::DBIC;
    sub register_implementation { 
        'MooseX::Meta::Attribute::Trait::DBIC'
    };

1;