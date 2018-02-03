package RideFlow::Model;

use Moose;

use Scalar::Util 'blessed';
use RideFlow::Models;

with 'Model::Envoy::Set';

sub namespace { 'RideFlow::Model' }

RideFlow::Models->load_all;

around list => sub { _list(@_) };

sub _list {
    my $next = shift;
    my $self = shift;

    my @args = @_;

    if ( $self->model->can_archive ) {

        my $is_false = { '=', [ 'f', undef ] };

        if ( ref $args[0] eq 'ARRAY' ) {
            if ( $args[0][0] eq '-and' ) {
                push @{$args[0][1]}, { archived => $is_false };
            }
            else {
                $args[0] = [
                    -and =>
                        { archived => $is_false },
                        @args,
                ];
            }
        }
        elsif ( ref $args[0] eq 'HASH' ) {
            $args[0]->{'archived'} = $is_false;
        }
    }

    return $self->$next(@args);
}

1;