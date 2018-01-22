package My::DB::Result::Test;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Core';

__PACKAGE__->table('test');
__PACKAGE__->add_columns(

    'id'      => { data_type => 'integer', is_nullable => 0, },
    'name'    => { data_type => 'text',    },
    'test_id' => { data_type => 'integer', },
);
__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many ( 'related', 'My::DB::Result::Test', 'test_id', );

1;