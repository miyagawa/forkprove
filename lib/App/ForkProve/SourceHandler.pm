package App::ForkProve::SourceHandler;
use strict;
use parent qw(TAP::Parser::SourceHandler);
use Capture::Tiny qw(capture_stdout);
use File::Temp qw(tempfile);

use TAP::Parser::IteratorFactory;
TAP::Parser::IteratorFactory->register_handler(__PACKAGE__);

sub can_handle {
    my($class, $src) = @_;
    return 1 if $src->meta->{file}{ext} eq '.t';
}

sub make_iterator {
    my($class, $src) = @_;

    my $path = $src->meta->{file}{dir} . $src->meta->{file}{basename};

    # Used to use pipe to communicate TAP output, but Test::More's
    # skip_all makes an immediate exit inside a test so that we can't
    # write to the pipe. If there's a way to make Capture::Tiny to
    # redirect STDOUT to a pipe that'd be simpler and we don't have to
    # use a tempfile.
    my($tap_fh, $tap_file) = tempfile(UNLINK => 1);

    my $pid = fork;
    if ($pid) {
        waitpid $pid, 0;

        open my $fh, "<", $tap_file;
        return TAP::Parser::Iterator::Stream->new($fh);
    } else {
        capture_stdout { _run($path) } stdout => $tap_fh;
        exit;
    }
}

sub _run {
    my $t = shift;

    # Many tests especially Exception tests rely on test file name being
    # passed as t/foo.t without a leading path
    local $0 = $t;
    _setup();
    eval qq{ package main; do \$t; 1 } or die $!;
    _teardown();
}

sub _setup {
    # $FindBin::Bin etc. has to be refreshed with the current $0
    if (defined &FindBin::init) {
        FindBin::init()
    }
}

sub _teardown {
    # Tests with no_plan rely on END to call done_testing
    if (defined $Test::Builder::Test) {
        $Test::Builder::Test->_ending;
    }
}

1;
