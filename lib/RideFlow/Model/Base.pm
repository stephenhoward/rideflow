package RideFlow::Model::Base;

use Moose;

has 'dbic' => ( is => 'ro', lazy_load => 1 );

sub _build_storage {
    my( $self ) = @_;

    # use $self->storage to get the rigth dbic Result class
}