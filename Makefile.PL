use inc::Module::Install;

name 'forkprove';
all_from 'lib/App/ForkProve.pm';
abstract_from 'bin/forkprove';
readme_from('bin/forkprove');

requires 'version';
requires 'App::Prove', 3.25;
requires 'TAP::Harness', 3.25;
requires 'parent', 0.221;

install_script 'bin/forkprove';

build_requires 'Test::More', 0.88;
test_requires 'Test::Requires';
auto_set_repository();
auto_provides;
WriteAll;
