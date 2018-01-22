
use lib 't/lib';

{
    package My::TestModel;

    use Moose;
    with 'MooseX::Storage::DBIC';

    use My::DB;

    sub dbic { 'Test' }

    sub _schema {
        return My::DB->db_connect();
    }

    has 'id' => (
        is => 'ro',
        isa => 'Num',
        traits => ['DBIC'],
        primary_key => 1,

    );

    has 'name' => (
        is => 'rw',
        isa => 'Maybe[Str]',
        traits => ['DBIC'],
    );

    has 'no_storage' => (
        is => 'rw',
        isa => 'Maybe[Str]',
    );

    has 'related' => (
        is => 'rw',
        isa => 'ArrayRef[My::TestModel]',
        traits => ['DBIC'],
        rel => 'has_many',
    );
}

use Test::More;

my $test = new My::TestModel(
    id         => 1,
    name       => 'foo',
    no_storage => 'bar',
    related    => [ new My::TestModel( id => 2 ) ],
);

subtest "Check Metadata" => sub {
    ok( $test->meta->get_attribute('id')->is_primary_key );
    ok( $test->meta->get_attribute('related')->is_relationship );
    ok( ! $test->meta->get_attribute('name')->is_relationship );
};

subtest "Saving a Model" => sub {

    note "inspect before save...";

    is( $test->id, 1, "Model id");
    is( $test->name, 'foo', "Model name");
    is( $test->no_storage, 'bar', "Model property without db backing");
    is( ref $test->related, 'ARRAY', "Model relationship exists");
    is( scalar @{$test->related}, 1, "Model relationship count" );
    isa_ok( $test->related->[0], 'My::TestModel', "Related Model" );
    is( $test->related->[0]->id, 2, "Related Model id" );

    not( $test->_dbic_result->id, 1, "DB id");
    not( $test->_dbic_result->name, 'foo', "DB name");
    is( scalar $test->_dbic_result->related->all, 0, "DB Relationship" );

    $test->db_save;

    note "inspect after save...";

    is( $test->id, 1);
    is( $test->name, 'foo');
    is( $test->no_storage, 'bar');
    is( ref $test->related, 'ARRAY');
    is( scalar @{$test->related}, 1 );
    isa_ok( $test->related->[0], 'My::TestModel' );
    is( $test->related->[0]->id, 2 );

    is( $test->_dbic_result->id, 1);
    is( $test->_dbic_result->name, 'foo');
    is( scalar $test->_dbic_result->related->all, 1 );
};

$test->db_delete;

subtest 'Model from DB Result' => sub {

    my $schema = My::TestModel->_schema;

    my $db_test = $schema->resultset('Test')->new({
        id => 3,
        name => 'baz',
    });
    isa_ok( $db_test, 'My::DB::Result::Test' );

    my $test2 = My::TestModel->new_from_db($db_test);

    is( My::TestModel->new_from_db(),undef);
    is( $test2->id, 3 );
    is( $test2->name, 'baz' );

};

done_testing;

1;