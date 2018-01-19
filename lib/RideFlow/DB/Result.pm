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


sub _get_property {
    my ( $self, $property ) = @_;

    my $accessor = $property . '_raw';

    # preserve DBIx::Class return behavior:
    return wantarray ? ( $self->$accessor ) : scalar $self->$accessor;
}

sub _set_indexed {

    my ( $self, $bridge_name, $target, $array ) = @_;

    $array //= [];

    $self->result_source->schema->txn_do( sub {

        $self->$bridge_name->delete();

        for my $i ( 0 .. $#{$array} ) {

            $self->create_related( $bridge_name, {
                index   => $i,
                $target => $array->[$i],
            });
        }

    });
}

__PACKAGE__->meta->make_immutable;

1;
