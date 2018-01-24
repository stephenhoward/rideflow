package RideFlow::Model;

use Moose;

use Scalar::Util 'blessed';
use Moose::Util::TypeConstraints;

with 'Model::Envoy::Set';

sub namespace { 'RideFlow::Model' }

BEGIN {
    require RideFlow::Models;
};

1;