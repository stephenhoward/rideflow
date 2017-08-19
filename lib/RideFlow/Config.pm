package RideFlow::Config;

use strict;
use warnings;

use YAML::XS 'LoadFile';

use base 'Exporter';

our @EXPORT_OK = qw( configure );

our $config = LoadFile( 'config/config.yaml' );

sub configure { 

    return $config;
}

1;
