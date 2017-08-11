use strict;
use warnings;

use YAML::XS qw( LoadFile DumpFile );
use JSON::Validator::OpenAPI;

my $meta_config  = LoadFile('definitions.yaml');
my $config       = LoadFile('config.yaml');

while ( my ( $name, $api) = each %{$meta_config->{apis}} ) {

    next if $name eq 'defaults';

    my $output = {
        swagger => $meta_config->{swagger},
        host => $config->{server}{$name} || '',
        %{$meta_config->{apis}{defaults}},
        %$api,
        definitions => $meta_config->{definitions} || {},
    };

    my $validator = JSON::Validator::OpenAPI->new();

    print "\nProcessing $name...\n";
    eval {
        $validator->load_and_validate_schema($output);
    };
    if ( $@ ) {
        print $@ . "\n";
    }

    DumpFile($name.'.swagger.yaml', $output );
}