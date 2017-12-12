package RideFlow::DB::Result;
use base 'DBIx::Class';

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
use MooseX::NonMoose;

extends 'DBIx::Class::Core';

__PACKAGE__->load_components(qw(
    InflateColumn::DateTime
    InflateColumn::PgGeometry
));

__PACKAGE__->meta->make_immutable;

1;
