package RideFlow::Model::Base;

use Moose;
use RideFlow::DB;

my $schema;

with 'Model::Envoy' => { storage => {
    'DBIC' => {
        schema => sub {
            $schema ||= RideFlow::DB->db_connect;
        }
    },
} };

sub dbic { die "Must define 'dbic' for " . __PACKAGE__ }

sub fetch {
    my $class = shift;

    RideFlow::Model->m($class)->fetch(@_);
}

sub delete {
    my ( $self ) = @_;

    if ( $self->can_archive ) {
        $self->archived(1);
        $self->save();
    }
    else {
        $self->SUPER::delete;
    }
}

sub restore {
    my ( $self ) = @_;

    if ( $self->can_archive ) {
        $self->archived(0);
        $self->save;

        return $self;
    }

    die "Cannot restore a " . ( ref $self );
}

sub can_archive {
    my ( $self ) = @_;

    return $self->meta->find_attribute_by_name('archived');
}

1;

# inject more attribute coercion for DateTime attributes:
package MooseX::Meta::Attribute::Trait::DBIC;

use Moose::Role;
use Moose::Util::TypeConstraints;
use DateTime::Format::DateParse;

subtype 'Maybe_DateTime',
    as 'Maybe[DateTime]';

coerce 'Maybe_DateTime',
    from 'Str',
    via { DateTime::Format::DateParse->parse_datetime( $_ ) };

coerce 'DateTime',
    from 'Str',
    via { DateTime::Format::DateParse->parse_datetime( $_ ) };

around '_process_options' => sub { _coerce_datetimes(@_) };

sub _coerce_datetimes {

    my ( $orig, $self, $name, $options ) = @_;

    if ( $options->{isa} eq 'Maybe[DateTime]' ) {
        $options->{isa} = 'Maybe_DateTime';
        $options->{coerce} = 1;
    }

    return $self->$orig($name,$options);
}

1;
