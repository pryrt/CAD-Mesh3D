use 5.010;      # v5.8 equired for in-memory files; v5.10 required for named backreferences and // in the commented-note() calls
use strict;
use warnings;
use Test::More tests => 1;

use CAD::Mesh3D qw(:all);

ok(1);

done_testing();