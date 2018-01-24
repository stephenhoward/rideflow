package RideFlow::Model;

use Moose;

use Scalar::Util 'blessed';
use Moose::Util::TypeConstraints;
use RideFlow::Models;

with 'Model::Envoy::Set';

sub namespace { 'RideFlow::Model' }

RideFlow::Models->load_all;

1;