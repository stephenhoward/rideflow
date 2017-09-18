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

my $user = RideFlow::Model->m('User')->create({
    email => $username,
});

$user->set_password( $password );

sub prompt {
    my( $text ) = @_;

    print "$text: ";
    my $val = <>;
    chomp $val;

    return $val;
}