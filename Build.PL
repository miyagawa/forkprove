
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "forking prove",
  "dist_author" => [
    "Tatsuhiko Miyagawa <miyagawa\@bulknews.net>"
  ],
  "dist_name" => "forkprove",
  "dist_version" => "v0.4.7",
  "license" => "perl",
  "module_name" => "forkprove",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "App::Prove" => "3.25",
    "TAP::Harness" => "3.25",
    "parent" => "0.221",
    "perl" => "5.008001",
    "version" => "0.77"
  },
  "script_files" => [
    "script/forkprove"
  ],
  "test_requires" => {
    "Test::More" => "0.88",
    "Test::Requires" => 0
  }
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  my $tr = delete $module_build_args{test_requires};
  my $br = $module_build_args{build_requires};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
