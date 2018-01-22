requires 'YAML::XS', '0.65';
requires 'Mojolicious', '7.39';
requires 'JSON::Validator','1.07';
requires 'Mojolicious::Plugin::OpenAPI', '1.22';
requires 'Mojolicious::Plugin::YamlConfig', '0.2.1';
requires 'Hash::Merge::Simple', '0.051';
requires 'Template', '2.27';
requires 'Moose';
requires 'MooseX::MarkAsMethods', '0.15';
requires 'List::MoreUtils::XS', '0.423'; # required by List::MoreUtils, which is required by MooseX::NonMoose
requires 'MooseX::NonMoose', '0.26';
requires 'DBIx::Class';
requires 'DBD::Pg', '3.6.2';
requires 'UUID', '0.27';
requires 'Mojo::JWT', '0.05';
requires 'Digest::Bcrypt';
requires 'Data::Entropy::Algorithms';
requires 'DateTime';
requires 'Email::Simple';
requires 'Email::Sender::Simple';
requires 'DBD::Mock'; # For testing
requires 'Devel::Cover'; # For testing