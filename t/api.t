use Test::More;
use Test::Mojo;
 
use YAML::XS qw( LoadFile );
use List::Util 'any';

my %test_rest_methods = (
    'get'    => sub { test_rest_get(@_) },
    'post'   => sub { test_rest_post(@_) },
    'delete' => sub { test_rest_delete(@_) },
);

my $default_consumes;
my $default_produces;

foreach my $api ( qw( public vend ride manage ) ) {

    note "--- Testing $api API ---";
    $ENV{RIDEFLOW_APP} = $api;
    my $t = Test::Mojo->new('RideFlow::API');
     
    SKIP: {

        skip 'Mojo::JSON fails on deep recursion atm';
        my $spec = $t->get_ok( '/v1', 'load OpenAPI spec' )->tx->res->content;
    }
    #meanwhile:
    my $spec = LoadFile('var/config/'.$ENV{RIDEFLOW_APP}.'.swagger.yaml');

    my $base_path     = $spec->{basePath};
    $default_consumes = $spec->{consumes};
    $default_produces = $spec->{produces};


    while( my ( $url, $endpoint ) = each %{$spec->{paths}} ) {
        test_rest_endpoint( $t, $base_path . $url, $endpoint );
    }
}

done_testing();

sub test_rest_endpoint {
    my ( $t, $url, $endpoint ) = @_;

    while( my ( $method, $params ) = each %{$endpoint} ) {

      next if $method eq 'parameters';

        $params->{consumes} ||= $default_consumes;
        $params->{produces} ||= $default_produces;

        ok( scalar keys %{$params->{responses}}, $method . ' ' . $url . ' has responses defined' );
        ok( defined $test_rest_methods{$method}, 'we know how to test '. $method .' requests' );

        if ( my $test_method = $test_rest_methods{$method} ) {

            my $t        = $test_method->( $t, $url, $params);
            my $response = $t->tx->res;

            if ( defined $params->{responses}{501} ) {

                ok( $response->code == '501', 'Response Not Implemented');
            }
            else {
                ok( defined $params->{responses}{200}, 'normal response is defined for '.$url );

                if ( ! ok( $response->code == '200','Response Success') ) {
                    diag( "response code was ".$response->code );
                }
                my $content_type = $response->headers->content_type;
                ok(
                 ( any { $content_type eq $_ } @{$params->{produces} || []} ),
                 $content_type . ' is one of (' . join(',',@{$params->{produces} || []} ) . ')' );            
            }
        }
    }
}

sub test_rest_get {
    my ( $t, $url, $params ) = @_;

    return $t->get_ok($url);
}

sub test_rest_post {
    my ( $t, $url, $params ) = @_;

    return $t->post_ok($url);
}

sub test_rest_delete {
    my ( $t, $url, $params ) = @_;

    if ( $params->{responses}{200} ) {
        my $ret = $t->delete_ok($url);
    }
}
