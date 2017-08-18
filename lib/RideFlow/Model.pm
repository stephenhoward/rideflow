package RideFlow::Model;

use strict;
use warnings;

use RideFlow::Model::Route;

sub m {

    my ( $class, $name ) = @_;

    return "RideFlow::Model::$name";
}

1;