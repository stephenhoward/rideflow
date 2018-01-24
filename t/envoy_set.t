use lib 't/lib';

{
    package My::Envoy::Models;

    use Moose;
    with 'Model::Envoy::Set';

    sub namespace { 'My::Envoy' }

    1;
}

unlink '/tmp/envoy';

use Test::More;
use My::Envoy::Widget;
use My::DB::Result::Widget;

My::Envoy::Widget->_schema->storage->dbh->do( My::DB::Result::Widget->sql );

my $set = My::Envoy::Models->m('Widget');

is( $set->model, 'My::Envoy::Widget', 'get set by model name');

my $params = {
    id => 1,
    name => 'foo',
    no_storage => 'bar',
    related => [
        {
            id => 2,
            name => 'baz',
        },
    ],
};

my $model = $set->build($params);

is_deeply( $model->dump, $params );

done_testing;