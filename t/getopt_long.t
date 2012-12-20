use Test::More;

use App::ForkProve;

ok(App::ForkProve->run('t/run_under_forkprove/getopt_long.t'));

done_testing;
