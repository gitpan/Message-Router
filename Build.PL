use Module::Build;
#copied shamelessly from Pod-PseudoPod-0.18/Build.PL
my $build = Module::Build->new (
    module_name => 'Message::Router',
    license => 'perl',
    build_requires => {
        'Test::More'            => 0,
        'Message::Match'        => 0,
        'Message::Transform'    => 0
    },
    requires => {
        'Message::Match'        => 0,
        'Message::Transform'    => 0
    },
    recursive_test_files => 1,
    dist_author          => 'Dana M. Diederich <diederich@gmail.com>',
    dist_abstract        => 'Fast, simple message routing',
    script_files => [],
);
$build->create_build_script;
