package Model::Envoy::Set;

use Moose::Role;

# The parent namespace for your models is stored here:
requires 'namespace';

use Moose::Util::TypeConstraints;

has model => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

sub m {

    my ( $class, $name ) = @_;

    my $namespace = $class->namespace;

    $name =~ s/^$namespace\:://;

    return $class->new( model => "$namespace::$name" );
}

sub build {
    my( $self, $params, $no_rel ) = @_;

    if ( ! ref $params ) {
        die "Cannot build a ". $self->model ." from '$params'";
    }
    elsif( ref $params eq 'HASH' ) {
        return $self->model->new($params);
    }
    elsif( ref $params eq 'ARRAY' ) {
        die "Cannot build a ". $self->model ." from an Array Ref";
    }
    elsif( blessed $params && $params->isa( $self->model ) ) {
        return $params;
    }
    elsif( blessed $params && $params->isa( 'DBIx::Class::Core' ) ) {

        my $type = ( ( ref $params ) =~ / ( [^:]+ ) $ /x )[0];

        return $self->m( $type )->model->new_from_db($params, $no_rel);
    }
    else {
        die "Cannot coerce a " . ( ref $params ) . " into a " . $self->model;
    }
}

sub fetch {
    my $self = shift;
    my %params;

    return undef unless @_;

    if ( @_ == 1 ) {

        my ( $id ) = @_;

        $params{id} = $id;
    }
    else {

        my ( $key, $value ) = @_;

        $params{$key} = $value;
    }

    if ( my $result = ($self->model->_schema->resultset( $self->model->dbic )
        ->search(\%params))[0] ) {

        return $self->model->new_from_db($result);
    }

    return undef;
}

sub list {
    my( $self ) = @_;

    return [
        map {
            $self->model->new_from_db($_);
        }
        $self->model->_schema->resultset( $self->model->dbic )->search()
    ];
}

sub load_types {
    my ( $self, @types ) = @_;

    my $namespace = $self->namespace;

    foreach my $type ( @types ) {

        die "invalid type name '$type'" unless $type =~ /^[a-z]+$/i;

        eval "use $namespace\::$type";
        die "Could not load model type '$type': $@" if $@;
    }
}

1;