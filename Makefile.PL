use inc::Module::Install;

name 'forkprove';
all_from 'lib/App/ForkProve.pm';
readme_from('bin/forkprove');

requires 'App::Prove', 3.25;
requires 'TAP::Harness', 3.25;

install_script 'bin/forkprove';

build_requires 'Test::More', 0.88;
test_requires 'Test::Requires';
auto_set_repository();
auto_provides;
WriteAll;
