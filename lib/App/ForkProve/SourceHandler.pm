package App::ForkProve::SourceHandler;
use strict;
use parent qw(TAP::Parser::SourceHandler);

use App::ForkProve::PipeIterator;
use TAP::Parser::IteratorFactory;
TAP::Parser::IteratorFactory->register_handler(__PACKAGE__);

sub can_handle {
    my($class, $src) = @_;
    return 1 if $src->meta->{file}{ext} eq '.t' && !$class->ignore($src->meta->{file});
}

sub ignore {
    my($class, $file) = @_;
    $ENV{PERL_FORKPROVE_IGNORE} && ($file->{dir} . $file->{basename}) =~ /$ENV{PERL_FORKPROVE_IGNORE}/;
}

sub make_iterator {
    my($class, $src) = @_;

    my $path = $src->meta->{file}{dir} . $src->meta->{file}{basename};
    my @inc = map { s/^-I//; $_ } grep { /^-I/ } @{ $src->switches };

    pipe my $reader, my $writer;
    my $pid = fork;
    if ($pid) {
        close $writer;
        return App::ForkProve::PipeIterator->new($reader, $pid);
    } else {
        close $reader;
        open STDOUT, ">&", $writer;
        _run($path, \@inc);
        exit;
    }
}

sub _run {
    my ($t, $inc) = @_;

    # Many tests especially Exception tests rely on test file name being
    # passed as t/foo.t without a leading path
    local $0 = $t;
    local @INC = (@$inc, @INC);

    # if FindBin is preloaded, reset it with the new $0
    if (defined &FindBin::init) {
        FindBin::init()
    }

    # reset the state of empty pattern matches, so that they have the same
    # behavior as running in a clean process.
    # see "The empty pattern //" in perlop.
    # note that this has to be dynamically scoped and can't go to other subs
    "" =~ /^/;

    eval q{ package main; do $t; 1 } or die $!;
}

1;
