
use lib 't/lib';

unlink '/tmp/envoy';

{
    package My::TestModel;

    use Moose;
    with 'Model::Envoy';

    use My::DB;

    sub dbic { 'Test' }

    my $schema;

    sub _schema {
        $schema ||= My::DB->db_connect('/tmp/envoy');
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

My::TestModel->_schema->storage->dbh->do( My::DB::Result::Test->sql );

my $test = new My::TestModel(
    id         => 1,
    name       => 'foo',
    no_storage => 'bar',
    related    => [ new My::TestModel( id => 2 ) ],
);

subtest "Check dump" => sub {

    is_deeply( $test->dump(), {
        id => 1,
        name => 'foo',
        no_storage => 'bar',
        related => [ { id => 2 } ],
    });
};

subtest "Updating a Model" => sub {

    note "inspect before update...";

    is( $test->id, 1, "Model id");
    is( $test->name, 'foo', "Model name");
    is( $test->no_storage, 'bar', "Model property without db backing");
    is( ref $test->related, 'ARRAY', "Model relationship exists");
    is( scalar @{$test->related}, 1, "Model relationship count" );
    isa_ok( $test->related->[0], 'My::TestModel', "Related Model" );
    is( $test->related->[0]->id, 2, "Related Model id" );

    $test->update({
        name => 'new',
        related => [
            { id => 3, name => 'fizz' },
            { id => 7, name => 'buzz' },
        ]
    });

    is( $test->id, 1, "Model id");
    is( $test->name, 'new');
    is( $test->no_storage, 'bar', "Model property without db backing");
    is( ref $test->related, 'ARRAY', "Model relationship exists");
    is( scalar @{$test->related}, 2, "Model relationship count" );
    isa_ok( $test->related->[0], 'My::TestModel', "Related Model" );
    is( $test->related->[0]->id, 3, "Related Model id" );
    is( $test->related->[1]->name, 'buzz', "Related Model name" );
};

$test->delete;

done_testing;

1;