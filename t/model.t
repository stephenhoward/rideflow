
use lib 't/lib';

unlink '/tmp/model';

use Test::More;
use My::Model::Widget;
use DateTime;

My::Model::Widget->_schema->storage->dbh->do( My::DB::Result::Widget->sql );

my %dates = (
    '2018-01-01' => DateTime->new( year => 2018, month => 1, day => 1 ),
    '2000-08-12 5:00:34' => DateTime->new( year => 2000, month => 8, day => 12, hour => 5, minute => 0, second => 34 ),
);

subtest 'Convert date from string' => sub {

    while ( my ( $string, $datetime ) = each %dates ) {

        my $test = new My::Model::Widget(
            id   => 1,
            name => 'foo',
            date => $string,
        );

        is( $test->date, $datetime );
    }
};

subtest 'Set with DateTime object' => sub {

    while ( my ( $string, $datetime ) = each %dates ) {

        my $test = new My::Model::Widget(
            id   => 1,
            name => 'foo',
            date => $datetime,
        );

        is( $test->date, $datetime );
    }
};




done_testing;

1;