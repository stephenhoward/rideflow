package RideFlow::Config;

use strict;
use warnings;

use YAML::XS 'LoadFile';

use base 'Exporter';

our @EXPORT_OK = qw( configure );

our $mode   = $ENV{MOJO_MODE} || $ENV{PLACK_ENV} || 'production';
our $config = LoadFile( "var/config/$mode.config.yaml" );

sub configure { 

    return $config;
}

1;
