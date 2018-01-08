package RideFlow::API;

use Mojo::Base 'Mojolicious';
use RideFlow::Model;
use RideFlow::API::Controller::Authorize;

sub startup {
    my ( $app, $api ) = @_;

    my $rideflow_app = $ENV{RIDEFLOW_APP};

    $app->log( Mojo::Log->new( path => 'var/log/' . $rideflow_app . '.log', level => 'debug' ));
    if ( $app->mode eq 'development' ) {
        # don't swallow warnings:
        $SIG{__WARN__} = sub {
            @_ = ($app->log, shift);
            goto &Mojo::Log::warn;
        };       
    }

    $app->plugin( YamlConfig => {
        file => $app->home->rel_file('var/config/'.$app->mode.'.config.yaml'), class => 'YAML::XS'
    } );
    $app->config( hypnotoad => $app->config->{ht}{$rideflow_app} );
    $app->secrets( [ $app->config->{secret} ] );
    $app->plugin( OpenAPI => {
        url      => $app->home->rel_file( 'var/config/' . $rideflow_app . '.swagger.yaml'),
        security => {
            Bearer => sub { RideFlow::API::Controller::Authorize::check_token(@_) },
        },
    } );

    $app->helper('models' => sub {
        my ( $c, $model ) = @_;

        RideFlow::Model->m($model);
    });

    $app->helper('posted_model' => sub {
        my ( $c, $id ) = @_;

        my $spec  = $c->openapi->spec;
        my $model = undef;

        if ( $spec->{parameters} && $spec->{parameters}[0]{name} eq 'model' ) {

            my $class = ( $spec->{parameters}[0]{schema}{'$ref'} =~ / ( [^\/]+ ) $ /x )[0];

            if ( $id ) {
                $model = $c->models( $class )->fetch( $c->param('uuid') );

                if ( $model ) {
                    $model->update($c->req->json);
                }
            }
            else {
                $model = $c->models( $class )->build($c->req->json);
            }
        }


        return $model;
    });

}

1;
