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