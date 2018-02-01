
use lib 't/lib';

use Test::More;
use Test::Exception;
use RideFlow::Model;

my %overlap_tests = (

    'A before B' => {
        a => [qw( 1:00:00 2:00:00 )],
        b => [qw( 2:00:00 3:00:00 )],
        pass => 1,
    },
    'B before A' => {
        a => [qw( 2:00:00 3:00:00 )],
        b => [qw( 1:00:00 2:00:00 )],
        pass => 1,
    },
    'B starts inside A' => {
        a => [qw( 2:00:00 3:00:00 )],
        b => [qw( 2:30:00 3:30:00 )],
        pass => 0,
    },
    'A starts inside B' => {
        a => [qw( 2:30:00 3:30:00 )],
        b => [qw( 2:00:00 3:00:00 )],
        pass => 0,
    },
    'A inside B' => {
        a => [qw( 2:30:00 3:00:00 )],
        b => [qw( 2:00:00 3:30:00 )],
        pass => 0,
    },
    'B inside A' => {
        a => [qw( 2:00:00 3:30:00 )],
        b => [qw( 2:30:00 3:00:00 )],
        pass => 0,
    },
    'B ends after unfinished A starts' => {
        a => [qw( 2:30:00 ), undef ],
        b => [qw( 2:00:00 3:00:00 )],
        pass => 0,
    },
    'B starts after unfinished A starts' => {
        a => [qw( 2:00:00 ), undef ],
        b => [qw( 2:30:00 3:00:00 )],
        pass => 0,
    },
    'B ends before unfinished A starts' => {
        a => [qw( 3:00:00 ), undef ],
        b => [qw( 2:00:00 3:00:00 )],
        pass => 1,
    },
    'Unfinished B starts inside A' => {
        a => [qw( 2:00:00 3:00:00 )],
        b => [qw( 2:30:00 ), undef ],
        pass => 0,
    },
    'Unfinished B starts before A' => {
        a => [qw( 2:30:00 3:00:00 )],
        b => [qw( 2:00:00 ), undef ],
        pass => 0,
    },
    'Unfinished B starts after A' => {
        a => [qw( 2:00:00 3:00:00 )],
        b => [qw( 3:00:00 ), undef ],
        pass => 1,
    },
    'Unfinished B starts before Unfinished A' => {
        a => [ '3:00:00', undef ],
        b => [ '2:00:00', undef ],
        pass => 0,
    },
    'Unfinished B starts after Unfinished A' => {
        a => [ '2:00:00', undef ],
        b => [ '3:00:00', undef ],
        pass => 0,
    },
);

my $sessions  = RideFlow::Model->m('RouteSession');
my $txn_guard = $sessions->model->_schema->txn_scope_guard;

my $driver  = RideFlow::Model->m('User')->build({
    firstname => 'Test',
    lastname => 'Driver',
})->save();
my $vehicle = RideFlow::Model->m('Vehicle')->build({
    name => 'Test Vehicle',
})->save();
my $route   = RideFlow::Model->m('Route')->build({
    name => 'Test Route',
})->save();

subtest 'Verify Needed Objects' => sub {

    ok( $driver->in_storage );
    ok( $vehicle->in_storage );
    ok( $route->in_storage );
};

while( my ( $test, $params ) = each %overlap_tests ) {

    subtest $test => sub {


        my $a = $sessions->build({
            route   => $route,
            vehicle => $vehicle,
            driver  => $driver,
            session_start => prefix_date( $params->{a}[0] ),
            session_end   => prefix_date( $params->{a}[1] ),
        })->save();

        ok( $a->in_storage, 'A: successful save' );

        my $b = $sessions->build({
            route   => $route,
            vehicle => $vehicle,
            driver  => $driver,
            session_start => prefix_date( $params->{b}[0] ),
            session_end   => prefix_date( $params->{b}[1] ),
        });

        if ( $params->{pass} ) {
            eval { $b->save() };
            ok( ! $@, 'no overlap' );
            ok( $b->in_storage, 'B: successful save' );
        }
        else {
            dies_ok { $b->save() } 'overlap found';
        }

        $a->delete();
        $b->delete();
    };
}

sub prefix_date {
    my ( $time ) = @_;

    return '2018-01-15 ' . $time if $time;
    return undef;

}

done_testing;

1;
