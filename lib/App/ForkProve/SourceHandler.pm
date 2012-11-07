package App::ForkProve::SourceHandler;
use strict;
use parent qw(TAP::Parser::SourceHandler);

use App::ForkProve::PipeIterator;
use TAP::Parser::IteratorFactory;
TAP::Parser::IteratorFactory->register_handler(__PACKAGE__);

sub can_handle {
    my($class, $src) = @_;
    return 1 if $src->meta->{file}{ext} eq '.t';
}

sub make_iterator {
    my($class, $src) = @_;

    my $path = $src->meta->{file}{dir} . $src->meta->{file}{basename};

    pipe my $reader, my $writer;
    my $pid = fork;
    if ($pid) {
        close $writer;
        return App::ForkProve::PipeIterator->new($reader, $pid);
    } else {
        close $reader;
        open STDOUT, ">&", $writer;
        _run($path);
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
        local $?; # since we aren't in an END block, this isn't relevant
        $Test::Builder::Test->_ending;
    }
}

1;
