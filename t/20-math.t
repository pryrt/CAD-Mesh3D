use strict;
use warnings;
use Test::More tests => 12;

use CAD::Mesh3D qw(:math);

is_deeply( unitDelta([  +1,  +1,  +1], [  +1,  +1,  +1]), [         0,         0,         0], 'unitDelta(<  +1,  +1,  +1>, <  +1,  +1,  +1>)');
is_deeply( unitDelta([  +1,  +1,  +1], [  +3,  +3,  +3]), [+sqrt(1/3),+sqrt(1/3),+sqrt(1/3)], 'unitDelta(<  +1,  +1,  +1>, <  +3,  +3,  +3>)');
is_deeply( unitDelta([  +3,  +3,  +3], [  +1,  +1,  +1]), [-sqrt(1/3),-sqrt(1/3),-sqrt(1/3)], 'unitDelta(<  +3,  +3,  +3>, <  +1,  +1,  +1>)');

is_deeply( unitCross([  +1,  +1,  +1], [  +3,  +3,  +3]), [         0,         0,         0], 'unitCross(<  +1,  +1,  +1>, <  +3,  +3,  +3>)');
is_deeply( unitCross([  -4,  +1,  +1], [  -6,  +1,  +2]), [       1/3,       2/3,       2/3], 'unitCross(<  -4,  +1,  +1>, <  -6,  +1,  +2>)');
is_deeply( unitCross([  -6,  +1,  +2], [  -4,  +1,  +1]), [      -1/3,      -2/3,      -2/3], 'unitCross(<  -6,  +1,  +2>, <  -4,  +1,  +1>)');
is_deeply( unitCross([ +12,-149,-132], [ +12, +31, +12]), [      0.64,     -0.48,      0.60], 'unitCross(< +12,-149,-132>, < +12, +31, +12>)');
is_deeply( unitCross([ +12, +31, +12], [ +12,-149,-132]), [     -0.64,     +0.48,     -0.60], 'unitCross(< +12, +31, +12>, < +12,-149,-132>)');

my $lft = [sqrt( 0/12),sqrt(0/12),sqrt(0/12)];
my $rgt = [sqrt(12/12),sqrt(0/12),sqrt(0/12)];
my $mid = [sqrt( 3/12),sqrt(9/12),sqrt(0/12)];
my $top = [sqrt( 3/12),sqrt(1/12),sqrt(8/12)];

is_deeply( facetNormal( [$lft, $mid, $rgt] ), [+sqrt(0/9),+sqrt(0/9),-sqrt(9/9)], 'facetNormal(bottom)' );
is_deeply( facetNormal( [$lft, $rgt, $top] ), [+sqrt(0/9),-sqrt(8/9),+sqrt(1/9)], 'facetNormal(front )' );
is_deeply( facetNormal( [$rgt, $mid, $top] ), [+sqrt(6/9),+sqrt(2/9),+sqrt(1/9)], 'facetNormal(right )' );
is_deeply( facetNormal( [$mid, $lft, $top] ), [-sqrt(6/9),+sqrt(2/9),+sqrt(1/9)], 'facetNormal(left  )' );

done_testing();