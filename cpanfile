requires 'YAML::XS', '0.65';
requires 'Mojolicious', '7.39';
requires 'Mojolicious::Plugin::OpenAPI', '1.21';
requires 'Mojolicious::Plugin::YamlConfig', '0.2.1';
requires 'JSON::Validator::OpenAPI';
requires 'Hash::Merge::Simple', '0.051';
requires 'Template', '2.27';
requires 'Moose';
requires 'MooseX::MarkAsMethods', '0.15';
requires 'List::MoreUtils::XS', '0.423'; # required by List::MoreUtils, which is required by MooseX::NonMoose
requires 'MooseX::NonMoose', '0.26';
requires 'DBIx::Class';
requires 'DBD::Pg', '3.6.2';
requires 'UUID', '0.27';

#required for Javascript::Compile
requires "Path::Tiny", '0.104';
requires "JavaScript::Minifier::XS", '0.11';
