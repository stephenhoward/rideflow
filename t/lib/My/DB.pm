package My::DB;

use strict;
use warnings;

use base 'DBIx::Class::Schema';
use DBI;
use DBD::Mock;

DBI->install_driver('Mock');

sub db_connect {
    my( $schema ) = @_;

    return $schema->connect( 'dbi:SQLite:dbname=/tmp/testdata','','');
}

sub db_remove {
    unlink '/tmp/testdata';
}
__PACKAGE__->load_namespaces;

1;
