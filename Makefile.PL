use ExtUtils::MakeMaker;

#copied shamelessly from Pod-PseudoPod-0.18/Makefile.PL
# The list of tests has to be explicitly generated on Win98.
my @tests;
for my $dir (qw(t)) {
    opendir my $dh, $dir or die $!;
    push @tests, map { "$dir/$_" } grep { /\.t$/ } readdir $dh;
    closedir $dh;
}

WriteMakefile(
    NAME         => 'Message::Router',
    VERSION_FROM => 'lib/Message/Router.pm', # finds $VERSION
    PREREQ_PM    => {
    },
    test =>
        {TESTS => "@tests"},
    AUTHOR       => 'Dana M. Diederich <diederich@gmail.com>',
    ABSTRACT     => 'Fast, simple message routing', 
    PL_FILES => {}, # ignore the Build.PL file
    EXE_FILES => [],
    LICENSE => 'perl',
);
