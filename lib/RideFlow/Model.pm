package RideFlow::Model;

use strict;
use warnings;

sub m {

    my ( $class, $name ) = @_;

    return "RideFlow::Model::$name";
}

sub list {
    my ( $class ) = @_;

    return [];
}

package RideFlow::Model::Route;

use base 'RideFlow::Model';

1;