use 5.010;      # v5.8 equired for in-memory files; v5.10 required for named backreferences and // in the commented-note() calls
use strict;
use warnings;
use Test::More;

use CAD::Mesh3D qw(:all);

##################################################
# enableFormat() functional coverage tests
##################################################

##################################################
# enableFormat(): missing input/output functions
##################################################
sub mockedFormat::MissingInput::_io_functions { output => sub { 'output' } }
$INC{'mockedFormat/MissingInput.pm'} = 1;
enableFormat( 'MissingInput' => 'mockedFormat::MissingInput' );
ok(1, 'mockedFormat::MissingInput'); # TODO = figure out how to verify it worked

sub mockedFormat::MissingOutput::_io_functions { input => sub { 'input' } }
$INC{'mockedFormat/MissingOutput.pm'} = 1;
enableFormat( 'MissingOutput' => 'mockedFormat::MissingOutput' );
ok(1, 'mockedFormat::MissingOutput'); # TODO = figure out how to verify it worked


##################################################
# enableFormat(): error testing
##################################################

# enableFormat(): missing format
eval { enableFormat(); }; chomp($@);
ok($@, 'Error Handling: enableFormat(missing format name)') or diag "\texplain: ", explain $@;

# enableFormat(): `require` could not find module
eval { enableFormat( 'DoesNotExist' ); }; chomp($@);
ok($@, 'Error Handling: enableFormat(unavailable module selected)') or diag "\texplain: ", explain $@;

# enableFormat(): calls inputFunctionNotAvail
eval { inputFunctionNotAvail(); 1; }; chomp($@);
ok($@, 'Error Handling: enableFormat(inputFunctionNotAvail)') or diag "\texplain: ", explain $@;

# enableFormat(): calls inputFunctionNotAvail
eval { outputFunctionNotAvail(); 1; }; chomp($@);
ok($@, 'Error Handling: enableFormat(outputFunctionNotAvail)') or diag "\texplain: ", explain $@;

# formatModule missing _io_functions()
eval { enableFormat( 'JunkFormat' => 'CAD::Mesh3D' ); 1; }; chomp($@);
ok($@, 'Error Handling: enableFormat( type => formatModule): formatModule missing_io_functions') or diag "\texplain: ", explain $@;


done_testing();