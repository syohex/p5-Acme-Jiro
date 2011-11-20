use inc::Module::Install;
use Module::Install::AuthorTests;
use Module::Install::Repository;

name 'Acme-Jiro';
all_from 'lib/Acme/Jiro.pm';

author_tests('xt');
auto_set_repository();
WriteAll;
