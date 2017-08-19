package RideFlow::DB;

use Moose; # we want Moose
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Schema';

use RideFlow::Config qw(configure);

sub db_connect {
    my( $schema ) = @_;

    return $schema->connect( @{configure->{db}}{qw/dsn user password/} );
}

__PACKAGE__->load_namespaces;
__PACKAGE__->meta->make_immutable;

1;
