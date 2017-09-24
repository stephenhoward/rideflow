package RideFlow::Model::User;

use Moose;
use Digest;
use Data::Entropy::Algorithms 'rand_bits';
use Crypt::Eksblowfish::Bcrypt qw(en_base64 de_base64);

# attribute definitions for this class are here:
extends 'RideFlow::Model::Attributes::User';


override new => sub {
    my $class  = shift;
    my %params = @_;

    if ( $params{email} ) {
        $params{email} = lc $params{email};
    }

    my $password = delete $params{password};

    my $self = $class->SUPER::new(%params);

    if( defined $password ) {
        $self->set_password($password);
    }

    return $self;
};

sub check_password {
    my ( $self, $password ) = @_;

    if ( defined $self->salt && defined $self->password ) {

        my $bcrypt = Digest->new('Bcrypt', cost => 10, salt => de_base64( $self->salt ) );

        return 1 if $bcrypt->add($password)->b64digest eq $self->password;
    }

    return undef;
}

sub set_password {
    my ( $self, $password ) = @_;

    my $bcrypt = Digest->new('Bcrypt', cost => 10, salt => rand_bits(16*8));

    $self->salt( en_base64( $bcrypt->salt ) );
    $self->password( $bcrypt->add($password)->b64digest );

    $self->save();

    return;
}

1;