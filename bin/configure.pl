#!/usr/bin/env perl

# yes this file is a mess.  It will get better

use strict;
use warnings;

use YAML::XS qw( LoadFile DumpFile );
use JSON::Validator::OpenAPI;
use Hash::Merge::Simple 'clone_merge';
use Template;

my $models  = LoadFile('config/models.yaml');
my $apis    = LoadFile('config/apis.yaml');
my $config  = LoadFile('config/config.yaml');
my %dbix_classes;
my $model_link = qr{#/definitions/([^\/]+)$};

my $tt = Template->new({
    INCLUDE_PATH => 'templates',
    INTERPOLATE  => 0,
}) or die "$Template::ERROR\n";

foreach my $model ( keys %$models ) {
    process_model( $model );

    if ( $models->{$model}{type} eq 'object' ) {
        $tt->process('model_attributes.tt',{ 
            model => $models->{$model},
            model_name => $model,
        },'var/lib/RideFlow/Model/Attributes/'.$model.'.pm')
            or die $tt->error();

        if ( ! -f 'lib/RideFlow/Model/'.$model.'.pm' ) {
            $tt->process('model.tt',{ 
                model => $models->{$model},
                model_name => $model,
            },'lib/RideFlow/Model/'.$model.'.pm')
                or die $tt->error();           
        }

        if ( $models->{$model}{'x-dbic-table'} ) {
            $tt->process('dbic.tt',{ 
                model => $models->{$model},
                model_name => $model,
            },'var/lib/RideFlow/DB/Result/'.$model.'.pm')
                or die $tt->error();           
        }
        remove_keys($models->{$model}, qr/^x-(?:dbic|rideflow)-/ );
    }
}

while ( my ( $name, $api) = each %{$apis->{apis}} ) {

    next if $name eq 'defaults';

    my %definitions;
    my %other_definitions;

    find_definitions( $api, \%definitions, 0 );
    find_definitions( \%definitions, \%other_definitions, 0 );

    my $output = {
        swagger => $apis->{swagger},
        host => $config->{server}{$name} || '',
        responses => $apis->{responses},
        %{$apis->{apis}{defaults}},
        %$api,
        definitions => clone_merge( \%definitions, \%other_definitions ),
    };

    DumpFile('var/config/'.$name.'.swagger.yaml', $output );
}

sub remove_keys {
    my ( $ref, $rx ) = @_;

    if ( ref $ref eq 'ARRAY' ) {
        remove_keys( $_, $rx ) foreach ( grep { ref } @$ref );
    }
    elsif( ref $ref eq 'HASH' ) {
        foreach my $key ( grep { $_ =~ $rx } keys %$ref ) {
            delete $ref->{$key};
        }
        foreach my $key ( grep { ref $ref->{$_} } keys %$ref ) {
            remove_keys( $ref->{$key}, $rx );
        }
    }
}

sub process_model {
    my ( $name ) = @_;

    my $model = $models->{$name};

    if ( $model->{allOf} ) {
        $model = clone_merge( (map {

            if( $_->{'$ref'} && $_->{'$ref'} =~ $model_link ) {
                process_model( $1 );
            }
            else {
                $_;
            }

        } @{$model->{allOf}}), $model );

        delete $model->{allOf};
    }

    process_properties( $model );

    $models->{$name} = $model;

    return $model;
}

sub process_properties {
    my ( $name ) = @_;
}

sub find_definitions {
    my( $ref, $definitions ) = @_;

    if ( ref $ref eq 'ARRAY' ) {
        find_definitions( $_, $definitions ) foreach ( grep { ref } @$ref );
    }
    elsif( ref $ref eq 'HASH' ) {
        while( my ( $key, $value ) = each %$ref ) {
            if ( $key eq '$ref' && $value =~ $model_link ) {

                if ( ! exists $definitions->{$1} ) {
                    $definitions->{$1} = $models->{$1};
                    find_definitions( $definitions->{$1}, $definitions )
                }
            }
            elsif( ref $value ) {
                find_definitions( $value, $definitions );
            }
        }
    }
}

