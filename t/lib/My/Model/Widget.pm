package My::Model::Widget;

    use Moose;
    extends 'RideFlow::Model::Base';

    use My::DB;

    sub dbic { 'My::DB::Result::Widget' }

    my $schema;

    sub _schema {
        $schema ||= My::DB->db_connect('/tmp/model');
    }

    has 'id' => (
        is => 'ro',
        isa => 'Num',
        traits => ['DBIC'],
        primary_key => 1,

    );

    has 'name' => (
        is => 'rw',
        isa => 'Maybe[Str]',
        traits => ['DBIC'],
    );

    has 'date' => (
        is => 'rw',
        isa => 'Maybe[DateTime]',
        traits => ['DBIC'],
    );

1;