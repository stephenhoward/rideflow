package RideFlow::Model::PasswordReset;

use Moose;
use RideFlow::Email;

# attribute definitions for this class are here:
extends 'RideFlow::Model::Attributes::PasswordReset';

sub issue_reset {

    my( $class, $user ) = @_;

    die "user required"
        unless ref $user && $user->isa('RideFlow::Model::User');

    if ( my $reset = $class->fetch( user_id => $user->id ) ) {

        if ( ! $reset->expired ) {
            $reset->expires( $class->new_expiration_timestamp );
            return $reset;
        }

        $reset->delete;
    }

    return $class->new({
        user    => $user,
        expires => $class->new_expiration_timestamp,
    })->save();
}

sub new_expiration_timestamp {
    return DateTime->now()->add( hours => 6 );
}

sub expired {
    my ( $self ) = @_;

    return 1 if ( $self->expires <= DateTime->now() );
}

sub send {
    my ( $self ) = @_;

    die "user has no email" unless $self->user->email;

    RideFlow::Email->send_message(
        headers {
            To => $self->user->email,
        },
        template => 'password_reset.tt',
        args => {
            token => $self,
            user  => $self->user,
        },
    );
}

1;