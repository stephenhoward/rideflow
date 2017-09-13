package RideFlow::Model::User;

use Moose;
use Digest;
use Data::Entropy::Algorithms 'rand_bits';

# attribute definitions for this class are here:
extends 'RideFlow::Model::Attributes::User';

sub check_password {
    my ( $self, $password ) = @_;

    if ( defined $self->salt && defined $self->password ) {

        my $bcrypt = Digest->new('Bcrypt', cost => 10, salt => $self->salt );

        return 1 if $bcrypt->add($password)->digest eq $self->password;
    }

    return undef;
}

sub set_password {
    my ( $self, $password ) = @_;

    my $bcrypt = Digest->new('Bcrypt', cost => 10, salt => rand_bits(16*8));

    $self->salt( $bcrypt->salt );
    $self->password( $bcrypt->add($password)->digest );

    $self->save();

    return;
}
1;