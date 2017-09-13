package RideFlow::API::Controller::Authorize;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::JWT;
use DateTime;

# Routes:

sub get_token {
    my $c = $_[0]->openapi->valid_input or return;

    return $c->render( openapi => { errors => [] }, status => 400 ) unless $c->req->json && $c->req->json->{email};

    if ( my $user = $c->models('User')->fetch( email => lc $c->req->json->{email} ) ) {

        if ( $user->check_password($c->req->json->{password}) ) {

            return $c->render( openapi => $c->_generate_token($user) );
        }
    }

    return $c->render( openapi => { errors => [] }, status => 400 );

}

sub refresh_token {
    my $c = $_[0]->openapi->valid_input or return;

    if ( my $claims = $c->stash('claims') ) {

        if ( my $user = $c->models('User')->fetch( $claims->{id} ) ) {

            return $c->render( openapi => $c->_generate_token($user) );
        }
    }

    return $c->render( openapi => { errors => [] }, status => 400 );
}

# Utils:

sub check_token {
    my ( $c, $definition, $scopes, $callback) = @_;

    if ( my $jwt = $c->req->headers->authorization ) {

        my $claims = eval {
            Mojo::JWT->new( secret => $c->app->secrets->[0] )->decode($jwt);
        };

        return $c->$callback($@) if $@;

        $c->stash( claims => $claims );

        return $c->$callback();
    }

    return $c->$callback('Authorization header not present');

}

sub _generate_token {
    my ( $c, $user ) = @_;

    my $claims = {
        id => $user->id
    };

    return Mojo::JWT->new(
        claims  => $claims,
        expires => DateTime->now->add( minutes => 5 )->epoch,
        secret  => $c->app->secrets->[0],
    )->encode;
}

1;