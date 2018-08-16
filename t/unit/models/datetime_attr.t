package My::Model::Widget;

    use Moose;
    extends 'RideFlow::Model::Base';

    sub dbic { }
    sub _schema { }

    has 'date' => (
        is => 'rw',
        isa => 'Maybe[DateTime]',
        traits => ['DBIC'],
    );

1;

package main;

use lib 't/lib';

use Test::More;
use My::Model::Widget;
use DateTime;

my %dates = (
    '2018-01-01' => DateTime->new( year => 2018, month => 1, day => 1 ),
    '2000-08-12 5:00:34' => DateTime->new( year => 2000, month => 8, day => 12, hour => 5, minute => 0, second => 34 ),
);

subtest 'Convert date from string' => sub {

    while ( my ( $string, $datetime ) = each %dates ) {

        my $test = new My::Model::Widget(
            date => $string,
        );

        is( $test->date, $datetime );
    }
};

subtest 'Set with DateTime object' => sub {

    while ( my ( $string, $datetime ) = each %dates ) {

        my $test = new My::Model::Widget(
            date => $datetime,
        );

        is( $test->date, $datetime );
    }
};




done_testing;

1;
