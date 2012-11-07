package App::ForkProve;

use strict;
use 5.008_001;
our $VERSION = '0.1.4';

use App::Prove;
use Getopt::Long ':config' => 'pass_through';

use App::ForkProve::SourceHandler;

sub run {
    my($class, @args) = @_;

    local @ARGV = @args;

    @ARGV = map { /^(-M)(.+)/ ? ($1,$2) : $_ } @ARGV;

    my @modules;
    my $lib;
    my $blib;
    my @inc;
    Getopt::Long::GetOptions('M=s@', \@modules);
    Getopt::Long::GetOptionsFromArray([@ARGV],
        'l|lib',  \$lib,
        'b|blib', \$blib,
        'I=s@',   \@inc,
    );

    if ($lib) {
        unshift @inc, 'lib';
    }

    if ($blib) {
        unshift @inc, 'blib/lib', 'blib/arch';
    }

    for (@modules) {
        local @INC = (@inc, @INC);
        my($module, @import) = split /[=,]/;
        eval "require $module" or die $@;
        $module->import(@import);
    }

    my $app = App::Prove->new;
    $app->process_args(@ARGV);
    $app->run;
}

1;
__END__

=encoding utf-8

=head1 NAME

App::ForkProve - forking prove

=head1 SYNOPSIS

  use App::ForkProve;
  App::ForkProve->run(@ARGV);

=head1 DESCRIPTION

App::ForkProve is a backend for L<forkprove>.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 COPYRIGHT

Copyright 2012- Tatsuhiko Miyagawa

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<forkprove>

=cut
