use Test::More;
use Test::Mojo;
 
use YAML::XS qw( LoadFile );
use List::Util 'any';

my %test_rest_methods = (
    'get'    => sub { test_rest_get(@_) },
    'post'   => \&test_rest_post,
    'delete' => \&test_rest_delete,
);

$ENV{RIDEFLOW_APP} = 'public';
my $t = Test::Mojo->new('RideFlow::API');
 
SKIP: {

    skip 'Mojo::JSON fails on deep recursion atm';
    my $spec = $t->get_ok( '/v1', 'load OpenAPI spec' )->tx->res->content;
}
#meanwhile:
my $spec = LoadFile('var/config/public.swagger.yaml');

note $spec;

my $base_path = $spec->{basePath};
my $default_consumes = $spec->{consumes};
my $default_produces = $spec->{produces};


while( my ( $url, $endpoint ) = each %{$spec->{paths}} ) {
    test_rest_endpoint( $base_path . $url, $endpoint );
}

done_testing();

sub test_rest_endpoint {
    my ( $url, $endpoint ) = @_;

    while( my ( $method, $params ) = each %{$endpoint} ) {

      next if $method eq 'parameters';

        $params->{consumes} ||= $default_consumes;
        $params->{produces} ||= $default_produces;

        if ( my $test_method = $test_rest_methods{$method} ) {

            if ( ok( defined $params->{responses}{200}, 'normal response is defined for '.$url ) ) {
                my $t = $test_method->($url, $params);
                if ( $t->tx->res->code == '501' ) {
                    note "not implemented, skipping";
                }
                else {
                    
                    my $content_type = $t->tx->res->headers->content_type;
                    ok( ( any { $content_type eq $_ } @{$params->{produces} || []} ), $content_type . ' is an expected content type' );
                }
            }
        }
    }
}

sub test_rest_get {
    my ( $url, $params ) = @_;

    return $t->get_ok($url);
}

sub test_rest_post {
    my ( $url, $params ) = @_;

    return $t->post_ok($url);
}

sub test_rest_delete {
    my ( $url, $params ) = @_;

    if ( $params->{responses}{200} ) {
        my $ret = $t->delete_ok($url);
    }
}
