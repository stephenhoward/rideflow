package RideFlow::API::Controller;

use Mojo::Base 'Mojolicious::Controller';
use RideFlow::Model;

sub list {
    my $c = $_[0]->openapi->valid_input or return;

    $c->render( openapi => $c->models( $c->model )->list() );
}

1;