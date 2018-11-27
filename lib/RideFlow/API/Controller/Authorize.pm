package RideFlow::API::Controller::Authorize;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::JWT;
use DateTime;
use List::Util 'any';

# Routes:

sub get_token {
    my $c = $_[0]->openapi->valid_input or return;

    return $c->render( openapi => { errors => [] }, status => 400 ) unless $c->req->json && $c->req->json->{email};

    if ( my $user = $c->models('User')->fetch( email => lc $c->req->json->{email} ) ) {

        if ( $user->check_password($c->req->json->{password}) ) {

            return $c->render( openapi => $c->_generate_token($user) );
        }
    }

    return $c->render_status( 401 => 'Unknown user or password' );

}

sub refresh_token {
    my $c = $_[0]->openapi->valid_input or return;

    if ( my $claims = $c->stash('claims') ) {

        if ( my $user = $c->models('User')->fetch( $claims->{id} ) ) {

            return $c->render( openapi => $c->_generate_token($user) );
        }
    }

    return $c->render_status( 401 => 'Invalid token, cannot refresh' );
}

sub create_password_reset {
    my $c = $_[0]->openapi->valid_input or return;

    return $c->render( openapi => { errors => [] }, status => 400 ) unless $c->req->json && $c->req->json->{email};

    if ( my $user = $c->models('User')->fetch( email => lc $c->req->json->{email} ) ) {

        $c->models('PasswordReset')->model_class->issue_reset($user)->send;

        return $c->render( openapi => 'Ok' );
    }

    return $c->render_status( 404 => 'No such email found');
}

sub check_password_reset {
    my $c = $_[0]->openapi->valid_input or return;

    return $c->_if_valid_reset_token( sub {
        my ( $c, $reset_token ) = @_;

        return $c->render( openapi => 'Ok' );
    } );
}

sub do_password_reset {
    my $c = $_[0]->openapi->valid_input or return;

    return $c->render( openapi => { errors => [] }, status => 400 ) unless $c->req->json && $c->req->json->{password};

    return $c->_if_valid_reset_token( sub {
        my ( $c, $reset_token ) = @_;

        my $user = $reset_token->user;

        $user->set_password($c->req->json->{password});

        $reset_token->delete;

        return $c->render( openapi => $c->_generate_token($user) );
    } );
}

# Utils:

sub render_status {
    my( $c, $code, $message ) = @_;
    return $c->render( openapi => { errors => [ {
        message => $message,
        path    => $c->req->url->to_string,

    } ] }, status => $code );
}

sub check_token {
    my ( $c, $definition, $scopes, $callback) = @_;

    my $role = $c->openapi->spec()->{'x-role'} || $c->openapi->spec('/x-role');

    if ( my $jwt = $c->req->headers->authorization ) {
        $jwt =~ s/^Bearer\s+//;

        my $claims = eval {
            Mojo::JWT->new( secret => $c->app->secrets->[0] )->decode($jwt);
        };

        return $c->$callback($@) if $@;

        if ( $role ) {

            unless ( any { $_ eq $role } @{ $claims->{roles} || [] } ) {
                return $c->$callback('Incorrect priveleges to access this resource');
            }

        }

        $c->stash( claims => $claims );

        return $c->$callback();
    }

    return $c->$callback('Authorization header not present');

}

sub _generate_token {
    my ( $c, $user ) = @_;

    my $claims = {
        id    => $user->id,
        roles => [ @{$user->roles} ],
    };

    return Mojo::JWT->new(
        claims  => $claims,
        expires => DateTime->now->add( minutes => 5 )->epoch,
        secret  => $c->app->secrets->[0],
    )->encode;
}

sub _if_valid_reset_token {
    my( $c,$callback ) = @_;

    if ( my $reset_token = $c->models('PasswordReset')->fetch( $c->param('uuid') ) ) {

        if ( $reset_token->expired ) {
            $reset_token->delete;
            return $c->render_status( 410 => 'Expired' );
        }
        else {
            return $callback($c,$reset_token);
        }
    }
    return $c->render_status( 404 => 'Not Found' );
}


1;