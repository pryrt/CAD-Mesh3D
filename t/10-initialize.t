use strict;
use warnings;
use Test::More;
#use Data::Dumper;

use App::Generate3dMesh ':all';

################################################################
# valid initialization
################################################################
my $v1 = createVertex(1,2,3);
is_deeply( $v1, [1,2,3], 'createVertex(1,2,3)') or diag "\texplain: ", explain $v1;
is( getx($v1), 1, '(1,2,3)->getx()');
is( gety($v1), 2, '(1,2,3)->gety()');
is( getz($v1), 3, '(1,2,3)->getz()');

my $v2 = createVertex(0,0,0);
my $v3 = createVertex(1,1,1);
my $t = createFacet($v1, $v2, $v3);
is_deeply( $t, [ [1,2,3], [0,0,0], [1,1,1] ], 'createFacet([1,2,3], [0,0,0], [1,1,1]);' ) or diag "\texplain: ", explain $t;

my ($q1, $q2) = createQuadrangleFacets( $v2, $v3, $v1, createVertex(-1,1,-1) );
is_deeply( $q1, [ [0,0,0], [1,1,1], [1,2,3]   ], 'createQuadrangleFacet([0,0,0], [1,1,1], [1,2,3], [-1,1,-1]): first  triangle') or diag "\texplain first:  ", explain $q1;
is_deeply( $q2, [ [0,0,0], [1,2,3], [-1,1,-1] ], 'createQuadrangleFacet([0,0,0], [1,1,1], [1,2,3], [-1,1,-1]): second triangle') or diag "\texplain second: ", explain $q2;

my $m = createMesh();
is_deeply( $m, [], 'empty mesh initialization');
$m = createMesh($t);
is_deeply( $m, [[ [1,2,3], [0,0,0], [1,1,1] ]], 'single triangle mesh initialization');

done_testing();