package RideFlow::Model;

use Moose;

use RideFlow::Model::Route;
use RideFlow::Model::Vehicle;

sub m {

    my ( $class, $name ) = @_;

    return "RideFlow::Model::$name";
}

1;