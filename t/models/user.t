
use lib 't/lib';

use strict;
use warnings;

use Test::More;
use Test::Exception;
use RideFlow::Model;

my $users  = RideFlow::Model->m('User');

my $email = random_string(16) . '@' . random_string(16) . '.com';
my $password = random_string(32);

# NOTE: Each subtest has its own txn_scope_guard because a failed sql statement in one
# will ruin all db tests in another

subtest '1 Step User Create' => sub {

    my $txn_guard = $users->model->_schema->txn_scope_guard;
    my $user = $users->build({
        email    => $email,
        password => $password
    });

    isa_ok( $user, 'RideFlow::Model::User');

    is(   $user->email, lc $email,                    'email check' );
    ok(   $user->check_password($password),           'password check');
    ok( ! $user->check_password( random_string(32) ), 'bogus password' );
    isnt( $user->password, $password,                 'not storing literal password');

    my $user_in_db = $users->fetch( id => $user->id );
    ok( ! $user_in_db, 'user is in the database' );
    $user->save();

    $user_in_db = $users->fetch( id => $user->id );
    ok( $user_in_db, 'user is in the database' );


    subtest 'Email Collision' => sub {

        my $user2 = $users->build({
            email => $email
        });

        isa_ok( $user2, 'RideFlow::Model::User');

        # Note: this test needs to run last, as it breaks 
        throws_ok { $user2->save() } qr/duplicate key value/ ,'email collision detected';
    };
};

subtest 'Progressive User Create' => sub {

    my $txn_guard = $users->model->_schema->txn_scope_guard;
    my $email2 = random_string(16) . '@' . random_string(16) . '.com';

    my $user = $users->build({
        email => $email2
    });

    ok( ! $user->check_password(''),        'refuse to check empty password' );
    ok( ! $user->check_password(),          'refuse to check undef password' );
    ok( ! $user->check_password($password), 'no password set' );

    $user->set_password($password);

    ok( $user->check_password($password), 'password set now' );
    isnt( $user->password, $password,     'not storing literal password');

    lives_ok { $user->save() } 'building user progressively saves ok';
};

done_testing;

sub random_string {
    my ( $length ) = @_;
    my @chars = ("A".."Z", "a".."z");

    return join('', map { $chars[rand @chars] } 1..$length );
}

1;