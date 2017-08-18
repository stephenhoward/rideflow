package RideFlow::Model::Base;

use Moose;

sub _build_storage {
    my( $self ) = @_;

    # use $self->storage to get the rigth dbic Result class
}

sub list {
    [];
}

1;