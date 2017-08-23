#!/usr/bin/env perl

use strict;
use warnings;

use Javascript::Compile;

my $which = $ARGV[0] || 'all';

if ( $which eq 'js' || $which eq 'all' ) {

    Javascript::Compile::compile_js( '/rideflow/static/js' => '/rideflow/var/static/js' );
}

if ( $which eq 'css' || $which eq 'all' ) {

    system('sass --update /rideflow/static/scss/:/rideflow/var/static/css/');
}


