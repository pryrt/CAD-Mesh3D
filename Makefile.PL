use ExtUtils::MakeMaker;
use 5.008;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
%mm_args = (
    'NAME'          => 'App::Generate3dMesh',
    'AUTHOR'        => 'Peter C. jones <petercj AT cpan.org>',
    'VERSION_FROM'  => 'lib/App/Generate3dMesh.pm',
    'ABSTRACT_FROM' => 'lib/App/Generate3dMesh.pm',
    'PREREQ_PM'     => {
        'Exporter'      => 5.57,    # needed for `use Exporter qw(import);` notation
        'warnings'      => 0,
        'strict'        => 0,
        'Carp'          => 0,
    },
);

{
    no warnings;
    if( $ExtUtils::MakeMaker::VERSION >= '6.46' ) {
        $mm_args{META_MERGE} = {
            'meta-spec' => {
                version => '2',
                url     => 'http://search.cpan.org/perldoc?CPAN::Meta::Spec',
            },
            resources => {
                bugtracker => {
                    mailto  => 'bug-App-Generate3dMesh@rt.cpan.org',
                    web     => 'https://github.com/pryrt/App-Generate3dMesh/issues',
                },
                repository => {
                    url     => 'https://github.com/pryrt/App-Generate3dMesh.git',
                    web     => 'https://github.com/pryrt/App-Generate3dMesh',
                    type    => 'git',
                },
            },
            keywords => [ '3D', 'CAD', 'STL'],
            # don't use 'provides', because it's an extra step to maintain, and
            # can cause problems (getting a mismatch between the $VERSION string and the
            # provides->{version} will really make it hard to release a next version into CPAN
        },
        # automatically determine the versions for 'provides'; MM->parse_version exists as of MM v6.31, so not a problem with >= 6.46
        #   => this comes out right when printed... but MYMETA.* shows values that look wrong
        $mm_args{META_MERGE}{provides} = {
            $mm_args{NAME} => {
                file => $mm_args{VERSION_FROM},
                version => ''.MM->parse_version( $mm_args{VERSION_FROM} ),
            }
        };
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.31' ) {
        $mm_args{LICENSE} = 'perl_5';
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.48' ) {
        $mm_args{MIN_PERL_VERSION} = '5.8.0';
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.52' ) {
        $mm_args{CONFIGURE_REQUIRES} = {
            'ExtUtils::MakeMaker' => 0,
            'warnings' => 0,
            'strict' => 0,
            'Test::More' => 0.86,
            'constant' => 0,
            'Config' => 0,
        },
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.64' ) {
        $mm_args{TEST_REQUIRES} = {
            'warnings' => 0,
            'strict' => 0,
            'Test::More' => 0.86,
            'constant' => 0,
            'Config' => 0,
        };
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.18' ) {
        $mm_args{SIGN} = 1 if MM->can('signature_target');
    }
}

sub MY::postamble {
    my (undef,%h) = @_;
    return <<'POSTAMBLE';
TEST_D = $(ABSPERLRUN) -MExtUtils::Command -e test_d --

testcover :: lib/App/Generate3dMesh.pm
	$(NOECHO) cover -test -report html

windebug ::
	$(NOECHO) for %f in ( t\*.t ) do $(NOECHO) (echo %f & perl %f & echo ----------)

#coverclean :: realclean
realclean ::
	$(NOECHO) ( $(TEST_D) cover_db && $(RM_RF) cover_db ) || $(ECHO) realclean:: skip "rm -rf cover_db"

# auto-generate the README from the lib/App/Generate3dMesh.pm
README.md :: lib/App/Generate3dMesh.pm
	podselect -section "NAME|SYNOPSIS|DESCRIPTION|AUTHOR|COPYRIGHT|LICENSE" lib/App/Generate3dMesh.pm > README.pod
	pod2markdown README.pod README.md
	$(RM_F) README.pod

POSTAMBLE
}

WriteMakefile( %mm_args )
