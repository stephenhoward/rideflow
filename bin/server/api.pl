#!/usr/bin/env perl

use strict;
use warnings;

use Mojolicious::Commands;
use List::Util 'any';

my @apps = qw( public manage vend ride );

if ( $ARGV[0] && any { $ARGV[0] eq $_ } @apps ) {

    $ENV{RIDEFLOW_APP} = shift @ARGV;

    # Start command line interface for application
    Mojolicious::Commands->start_app('RideFlow::API');
}
else {

    print "\nUsage: $0 ". join('|', @apps ) . " mojo-command\n";
    exit;
}