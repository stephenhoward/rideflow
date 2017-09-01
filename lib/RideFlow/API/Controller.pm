package RideFlow::API::Controller;

use Mojo::Base 'Mojolicious::Controller';
use RideFlow::Model;

sub list {
    my $c = $_[0]->openapi->valid_input or return;

    $c->render( openapi => [ map { $_->dump } @{$c->models( $c->model )->list()} ] );
}

sub create {
    my $c = $_[0]->openapi->valid_input or return;

    my $model = $c->models( $c->model )->create($c->req->json);

    $c->render( openapi => $model->dump );
}

sub fetch {
    my $c = $_[0]->openapi->valid_input or return;

    $c->render( openapi => $c->models( $c->model )->fetch( $c->param('uuid') )->dump );
}

1;