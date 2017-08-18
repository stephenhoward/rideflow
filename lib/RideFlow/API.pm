package RideFlow::API;

use Mojo::Base 'Mojolicious';

sub startup {
    my ( $app, $api ) = @_;

    my $rideflow_app = $ENV{RIDEFLOW_APP};

    $app->plugin( YamlConfig => {
        file => $app->home->rel_file('config/config.yaml'), class => 'YAML::XS'
    } );
   $app->plugin( OpenAPI => {
        url  => $app->home->rel_file( 'var/config/' . $rideflow_app . '.swagger.yaml')
    } );
}

1;
