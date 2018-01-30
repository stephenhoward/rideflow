package RideFlow::Model::Base;

use Moose;
use RideFlow::DB;

with 'Model::Envoy';

sub dbic { die "Must define 'dbic' for " . __PACKAGE__ }

my $schema;

sub _schema {
    $schema ||= RideFlow::DB->db_connect();
}

sub fetch {
    my $class = shift;

    RideFlow::Model->m($class)->fetch(@_);
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

around '_process_options' => sub {

    my ( $orig, $self, $name, $options ) = @_;

    if ( $options->{isa} eq 'Maybe[DateTime]' ) {
        $options->{isa} = 'Maybe_DateTime';
        $options->{coerce} = 1;
    }

    return $self->$orig($name,$options);
};

1;
