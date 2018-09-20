use ExtUtils::MakeMaker;
use 5.010;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
%mm_args = (
    'NAME'          => 'CAD::Mesh3D',
    'AUTHOR'        => 'Peter C. Jones <petercj AT cpan.org>',
    'VERSION_FROM'  => 'lib/CAD/Mesh3D.pm',
    'ABSTRACT_FROM' => 'lib/CAD/Mesh3D.pm',
    'PREREQ_PM'     => {
        'Math::Vector::Real'    => 0.18,
        'Exporter'              => 5.57,    # needed for `use Exporter qw(import);` notation
        'warnings'              => 0,
        'strict'                => 0,
        'Carp'                  => 0,
        'CAD::Format::STL'      => 0,
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
                    mailto  => 'bug-CAD-Mesh3D@rt.cpan.org',
                    web     => 'https://github.com/pryrt/CAD-Mesh3D/issues',
                },
                repository => {
                    url     => 'https://github.com/pryrt/CAD-Mesh3D.git',
                    web     => 'https://github.com/pryrt/CAD-Mesh3D',
                    type    => 'git',
                },
            },
            keywords => [ '3D', 'CAD', 'STL'],
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
        $mm_args{MIN_PERL_VERSION} = '5.10.0';
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
        $mm_args{SIGN} = 1 if MM->can('signature_target') && $ENV{MM_SIGN_DIST};
    }
}

sub MY::postamble {
    my (undef,%h) = @_;
    return <<'POSTAMBLE';
TEST_D = $(ABSPERLRUN) -MExtUtils::Command -e test_d --

testcover :: lib/CAD/Mesh3D.pm
	$(NOECHO) cover -test -report html

windebug ::
	$(NOECHO) for %f in ( t\*.t ) do $(NOECHO) (echo %f & perl %f & echo ----------)

# run author-tests on the original
authtest ::
	$(TEST_D) xt && $(MAKE) test TEST_FILES='xt/*.t'

# run author-tests on the distribution
distauthtest :: disttest
	cd $(DISTVNAME) && $(TEST_D) xt && $(MAKE) test TEST_FILES='xt/*.t'

#coverclean :: realclean
realclean ::
	$(NOECHO) ( $(TEST_D) cover_db && $(RM_RF) cover_db ) || $(ECHO) realclean:: skip "rm -rf cover_db"
	$(NOECHO) ( $(TEST_F) MYMETA.json.lock && $(RM_RF) MYMETA.json.lock ) || $(ECHO) realclean:: skip "rm -rf MYMETA.json.lock"

# auto-generate the README from the lib/CAD/Mesh3D.pm
README.md :: lib/CAD/Mesh3D.pm
	podselect -section "NAME|SYNOPSIS|DESCRIPTION|SEE ALSO|TODO|AUTHOR|COPYRIGHT|LICENSE" lib/CAD/Mesh3D.pm > README.pod
	pod2markdown README.pod README.md
	$(RM_F) README.pod

# auto-generate the LICENSE file from the lib/Math/PRBS.pm
LICENSE :: lib/CAD/Mesh3D.pm
	podselect -section "AUTHOR|COPYRIGHT|LICENSE" lib/CAD/Mesh3D.pm > LICENSE.pod
	pod2text LICENSE.pod LICENSE
	$(RM_F) LICENSE.pod

docs :: README.md LICENSE

POSTAMBLE
}

WriteMakefile( %mm_args )
