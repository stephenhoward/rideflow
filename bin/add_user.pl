#!/usr/bin/env perl

use strict;
use warnings;

use RideFlow::Model;


my $username = prompt('email');

if ( my $u = RideFlow::Model->m('User')->fetch( email => $username ) ) {
    print "email already in use\n";
    exit;
}

my $password  = prompt('password');
my $password2 = prompt('repeat password');

if ( $password ne $password2 ) {
    print "passwords do not match\n";
    exit;
}

my $user = RideFlow::Model->m('User')->build({
    email    => $username,
})->save();

$user->set_password($password);

my $user_check = RideFlow::Model->m('User')->fetch( id => $user->id );

sub prompt {
    my( $text ) = @_;

    print "$text: ";
    my $val = <>;
    chomp $val;

    return $val;
}
