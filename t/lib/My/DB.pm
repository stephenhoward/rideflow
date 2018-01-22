package My::DB;

use strict;
use warnings;

use base 'DBIx::Class::Schema';
use DBI;
use DBD::Mock;

DBI->install_driver('Mock');

sub db_connect {
    my( $schema ) = @_;

    return $schema->connect( 'dbi:Mock:','','');
}

__PACKAGE__->load_namespaces;

1;
