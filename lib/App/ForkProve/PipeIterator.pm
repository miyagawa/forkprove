package App::ForkProve::PipeIterator;
use strict;
use parent qw(TAP::Parser::Iterator::Stream);

sub new {
    my($class, $fh, $pid) = @_;
    my $self = $class->SUPER::new($fh);
    $self->{pid} = $pid;
    $self;
}

sub get_select_handles { $_[0]->{fh} }

sub DESTROY {
    waitpid $_[0]->{pid}, 0;
}

1;

