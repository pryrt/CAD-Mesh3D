use 5.010;      # v5.8 equired for in-memory files; v5.10 required for named backreferences and // in the commented-note() calls
use strict;
use warnings;
use Test::More tests => 23;
use Test::Exception;

use CAD::Mesh3D qw(+STL :all);

sub test_format {
    my $format = shift;
    my $module = shift;
    my %opt = @_;
    ok(exists $CAD::Mesh3D::EnabledFormats{$format}, "EnabledFormats{$format}");
    isa_ok( $CAD::Mesh3D::EnabledFormats{$format}{input}, 'CODE', "EnabledFormats{$format}{input}");
    isa_ok( $CAD::Mesh3D::EnabledFormats{$format}{output}, 'CODE', "EnabledFormats{$format}{output}");
    is( $CAD::Mesh3D::EnabledFormats{$format}{module}, $module, "EnabledFormats{$format}{module}");

    SKIP: {
        skip "EnableFormats{$format}{input} is real, so don't error-test it here", 1
            unless exists $opt{input} and UNIVERSAL::isa($opt{input}, 'Regexp');
        throws_ok { input( $format, 'no file') } $opt{input}, "Error Handling: EnabledFormats{$format}{input} error-test";
    }
    SKIP: {
        skip "EnableFormats{$format}{output} is real, so don't error-test it here", 1
            unless exists $opt{output} and UNIVERSAL::isa($opt{output}, 'Regexp');
        throws_ok { output( [], $format, 'no file') } $opt{output}, "Error Handling: EnabledFormats{$format}{output} error-test";
    }
}

##################################################
# enableFormat() functional coverage tests
##################################################
test_format( 'STL', 'CAD::Mesh3D::STL', input => qr/not yet debugged inputting from STL/ );

##################################################
# enableFormat(): missing input/output functions
##################################################
sub mockedFormat::MissingInput::_io_functions { output => sub { 'output' } }
$INC{'mockedFormat/MissingInput.pm'} = 1;
enableFormat( 'MissingInput' => 'mockedFormat::MissingInput' );
test_format( 'MissingInput' => 'mockedFormat::MissingInput', input => qr/Input function for MissingInput is not available/ );
is( output( [], MissingInput => 'dne' ), 'output', 'output( mesh, MissingInput => file) gives mocked response' );

sub mockedFormat::MissingOutput::_io_functions { input => sub { 'input' } }
$INC{'mockedFormat/MissingOutput.pm'} = 1;
enableFormat( 'MissingOutput' => 'mockedFormat::MissingOutput' );
test_format( 'MissingOutput' => 'mockedFormat::MissingOutput', output => qr/Output function for MissingOutput is not available/  );
is( input( MissingOutput => 'dne' ), 'input', 'input( MissingOutput => file) gives mocked response' );

##################################################
# enableFormat(): error testing
##################################################
throws_ok { enableFormat(); } qr/requires name of format/, 'Error Handling: enableFormat(missing format name)';
throws_ok { enableFormat( 'DoesNotExist' ); } qr/could not import CAD::Mesh3D::DoesNotExist/, 'Error Handling: enableFormat(unavailable module selected)';
throws_ok { enableFormat( 'JunkFormat' => 'CAD::Mesh3D' ); } qr/doesn't seem to correctly provide/, 'Error Handling: enableFormat( type => formatModule): formatModule missing_io_functions';

done_testing();