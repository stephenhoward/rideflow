#!/usr/bin/env perl

use strict;
use warnings;

use Mojolicious::Commands;

$ENV{RIDEFLOW_APP} = 'public';

# Start command line interface for application
Mojolicious::Commands->start_app('RideFlow::API');
