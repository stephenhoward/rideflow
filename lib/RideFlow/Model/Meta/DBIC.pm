package RideFlow::Model::Meta::DBIC;

use Moose::Role;

requires 'dbic';

has _dbic => ( is => 'rw', );

package RideFlow::Model::Meta::Attribute::Trait::DBIC;
use Moose::Role;
Moose::Util::meta_attribute_alias('DBIC');

before '_process_options' => sub {
    my ( $self, $name, $options ) = @_;

    $options->{trigger} //= sub {
        my( $instance, $value, $old_value ) = @_;

        $instance->_dbic->$name( $value );
    }
};

package Moose::Meta::Attribute::Custom::Trait::RideFlowDBIC;
    sub register_implementation { 
        'MooseX::Meta::Attribute::Trait::DBIC'
    };

1;