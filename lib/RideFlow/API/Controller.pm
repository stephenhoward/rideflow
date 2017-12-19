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

    if ( my $model = $c->models( $c->model )->fetch( $c->param('uuid') ) ) {

        return $c->render( openapi => $model->dump );
    }

    return $c->not_found;

}

sub update {
    my $c = $_[0]->openapi->valid_input or return;

    if ( my $model = $c->models( $c->model )->fetch( $c->param('uuid') ) ) {

        $model->update($c->req->json)->save;

        return $c->render( openapi => $model->dump );
    }

    return $c->not_found;

}

sub delete {
    my $c = $_[0]->openapi->valid_input or return;

    if ( my $model = $c->models( $c->model )->fetch( $c->param('uuid') ) ) {

        if ( $model->delete ) {
            return $c->render( openapi => 1 );
        }
        else {
            return $c->bad_request;
        }
    }

    return $c->not_found;
}

sub not_found {
    my ( $c ) = @_;

    return $c->render( openapi => { errors => [] }, status => 404 );
}

sub bad_request {
    my ( $c ) = @_;

    return $c->render( openapi => { errors => []}, status => 400 );
}

1;