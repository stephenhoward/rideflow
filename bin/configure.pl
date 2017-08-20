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

my $openapi_to_pg_types = {
    'boolean' => 'boolean',
    'string'  => {
        'uuid'      => 'uuid',
        'date'      => 'datetime',
        'date-time' => 'datetime',
        'default'   => 'text',
    },
    'number'  => 'numeric',
    'integer' => 'int',
};

my $tt = Template->new({
    INCLUDE_PATH => 'templates',
    INTERPOLATE  => 0,
}) or die "$Template::ERROR\n";

foreach my $name ( keys %$models ) {
    process_model( $name );

    model_output( $name, $models->{$name} ) if $models->{$name}{type} eq 'object';
    db_output( $name, $models->{$name} ) if $models->{$name}{'x-dbic-table'};

}
my $schema = build_schema( $models );
sql_output( $schema );
remove_keys($models->{$_}, qr/^x-(?:dbic|rideflow)-/ ) foreach keys %$models;

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

sub model_output {
    my ( $name, $model ) = @_;

    $tt->process('model_attributes.tt',{ 
        model      => $model,
        model_name => $name,
    },'var/lib/RideFlow/Model/Attributes/'.$name.'.pm')
        or die $tt->error();

    if ( ! -f 'lib/RideFlow/Model/'.$name.'.pm' ) {
        $tt->process('model.tt',{ 
            model      => $model,
            model_name => $name,
        },'lib/RideFlow/Model/'.$name.'.pm')
            or die $tt->error();           
    }
}

sub build_schema {

    my ( $models ) = @_;
    my %schema;

    while( my ( $model, $m ) = each %$models ) {

        next unless $m->{'x-dbic-table'};

        while( my( $property, $p ) = each %{$m->{properties}} ) {
            if ( my $rel = $p->{'x-dbic-rel'} ) {

                if ( $rel eq 'belongs_to' ) {
                    $schema{$model}{columns}{$p->{'x-dbic-key'}} = {
                        data_type      => 'uuid',
                        is_foreign_key => 1,
                    };
                }

            }
            else {

                $schema{$model}{columns}{$property}{data_type} = pg_attr_type( $property, $p ) || '';
                $schema{$model}{columns}{$property}{not_null}  = 1 if $property eq $m->{'x-dbic-key'};
            }
        }

        if ( my $pk = $m->{'x-dbic-key'} ) {
            $schema{$model}{primary_key} = $pk;
        }

    }

    return \%schema;
}

sub sql_output {
    my ( $schema ) = @_;
    $tt->process('sql_schema.tt',{ 
        schema => $schema
    },'db/schema.sql' )
        or die $tt->error();               
}

sub pg_attr_type {
    my ( $name, $property ) = @_;

    warn "$name has no 'type'" if ! defined $property->{type};

    if ( $property->{type} eq 'string' ) {

        return $openapi_to_pg_types->{string}{ $property->{format} || 'default' } || 'text';
    }

    return $openapi_to_pg_types->{ $property->{type} };
}

sub db_output {
    my ( $name, $model ) = @_;

    $tt->process('dbic_attributes.tt',{ 
        model      => $model,
        model_name => $name,
        pg_attr_type => \&pg_attr_type,
    },'var/lib/RideFlow/DB/Result/Attributes/'.$name.'.pm')
        or die $tt->error();           

    if ( ! -f 'lib/RideFlow/DB/Result/'.$name.'.pm' ) {
        $tt->process('dbic.tt',{ 
            model      => $model,
            model_name => $name,
        },'lib/RideFlow/DB/Result/'.$name.'.pm')
            or die $tt->error();
    }
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

