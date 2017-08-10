use strict;
use warnings;

use YAML qw( LoadFile DumpFile );

local $YAML::Preserve = 1;

my $meta_config  = LoadFile('definitions.yaml');
my $config       = LoadFile('config.yaml');

while ( my ( $name, $api) = each %{$meta_config->{apis}} ) {

    next if $name eq 'defaults';

    my $output = YAML::Node->new({});

    %$output = (
        swagger => $meta_config->{swagger},
        host => $config->{server}{$name} || '',
        %{$meta_config->{apis}{defaults}},
        %$api,
        definitions => $meta_config->{definitions} || {},
    );

    DumpFile($name.'.swagger.yaml', $output );
}