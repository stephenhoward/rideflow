package RideFlow::Model;

use Moose;

use Scalar::Util 'blessed';
use Moose::Util::TypeConstraints;

with 'Model::Envoy::Set';

has model => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

sub namespace { 'RideFlow::Model' }

sub _load_types {
    my ( $self, @types ) = @_;

    subtype 'Array_of_HashRef',
        as 'ArrayRef[HashRef]';

    foreach my $type ( @types ) {

        die "inalid type name '$type'" unless $type =~ /^[a-z]+$/i;

        my $package = "RideFlow::Model::$type";

        subtype "Array_of_$type",
            as "ArrayRef[$package]";

        subtype "Maybe_$type",
            as "Maybe[$package]";

        subtype "Array_of_DB_$type",
            as "ArrayRef[RideFlow::DB::Result::$type]";

        coerce   "Array_of_$type",
            from "Array_of_DB_$type",
            via  { [ map { $package->new_from_db($_) } @{$_} ] },

            from 'Array_of_HashRef',
            via  { [ map { $package->new($_) } @{$_} ] };

        coerce   "Maybe_$type",
            from "RideFlow::DB::Result::$type",
            via  { $package->new_from_db($_) },

            from 'HashRef',
            via { $package->new($_) };

        coerce   "RideFlow::Model::$type",
            from "RideFlow::DB::Result::$type",
            via  { $package->new_from_db($_) },

            from 'HashRef',
            via { $package->new($_) };
    }

    foreach my $type ( @types ) {
        eval "use RideFlow::Model::$type";
        die "Could not load model type '$type': $@" if $@;
    }

}

BEGIN {
    require RideFlow::Models;
};

1;