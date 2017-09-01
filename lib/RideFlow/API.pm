package RideFlow::API;

use Mojo::Base 'Mojolicious';
use RideFlow::Model;

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
        file => $app->home->rel_file('config/'.$app->mode.'.config.yaml'), class => 'YAML::XS'
    } );
    $app->config( hypnotoad => $app->config->{ht}{$rideflow_app} );

    $app->plugin( OpenAPI => {
        url  => $app->home->rel_file( 'var/config/' . $rideflow_app . '.swagger.yaml')
    } );

   $app->helper('models' => sub {
        my ( $c, $model ) = @_;

        RideFlow::Model->m($model);
   })
}

1;
