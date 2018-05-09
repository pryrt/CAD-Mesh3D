use strict;
use warnings;
use Test::More;
#use Data::Dumper;

use App::Generate3dMesh ':all';

################################################################
# valid initialization
################################################################
my $v123 = createVertex(1,2,3);
is_deeply( [@$v123], [1,2,3], 'createVertex(1,2,3)') or diag "\texplain: ", explain $v123;
is( getx($v123), 1, '(1,2,3)->getx()');
is( gety($v123), 2, '(1,2,3)->gety()');
is( getz($v123), 3, '(1,2,3)->getz()');

my $v000 = createVertex(0,0,0);
my $v111 = createVertex(1,1,1);
my $t = createFacet($v123, $v000, $v111);
#is_deeply( $t, [ [1,2,3], [0,0,0], [1,1,1] ], 'createFacet([1,2,3], [0,0,0], [1,1,1]);' ) or diag "\texplain: ", explain $t;
is_deeply( $t->[0], $v123, 'createFacet([1,2,3], [0,0,0], [1,1,1]) v0' ) or diag "\texplain: ", explain $t;
is_deeply( $t->[1], $v000, 'createFacet([1,2,3], [0,0,0], [1,1,1]) v1' ) or diag "\texplain: ", explain $t;
is_deeply( $t->[2], $v111, 'createFacet([1,2,3], [0,0,0], [1,1,1]) v2' ) or diag "\texplain: ", explain $t;

my $vN1N = createVertex(-1,1,-1);
my ($q1, $q2) = createQuadrangleFacets( $v000, $v111, $v123, $vN1N );
#is_deeply( $q1, [ [0,0,0], [1,1,1], [1,2,3]   ], 'createQuadrangleFacet([0,0,0], [1,1,1], [1,2,3], [-1,1,-1]): first  triangle') or diag "\texplain first:  ", explain $q1;
is_deeply( $q1->[0], $v000, 'createQuadrangleFacet([0,0,0], [1,1,1], [1,2,3], [-1,1,-1]): first  triangle v0') or diag "\texplain first:  ", explain $q1;
is_deeply( $q1->[1], $v111, 'createQuadrangleFacet([0,0,0], [1,1,1], [1,2,3], [-1,1,-1]): first  triangle v1') or diag "\texplain first:  ", explain $q1;
is_deeply( $q1->[2], $v123, 'createQuadrangleFacet([0,0,0], [1,1,1], [1,2,3], [-1,1,-1]): first  triangle v2') or diag "\texplain first:  ", explain $q1;
#is_deeply( $q2, [ [0,0,0], [1,2,3], [-1,1,-1] ], 'createQuadrangleFacet([0,0,0], [1,1,1], [1,2,3], [-1,1,-1]): second triangle') or diag "\texplain second: ", explain $q2;
is_deeply( $q2->[0], $v000, 'createQuadrangleFacet([0,0,0], [1,1,1], [1,2,3], [-1,1,-1]): second triangle v0') or diag "\texplain second: ", explain $q2;
is_deeply( $q2->[1], $v123, 'createQuadrangleFacet([0,0,0], [1,1,1], [1,2,3], [-1,1,-1]): second triangle v1') or diag "\texplain second: ", explain $q2;
is_deeply( $q2->[2], $vN1N, 'createQuadrangleFacet([0,0,0], [1,1,1], [1,2,3], [-1,1,-1]): second triangle v2') or diag "\texplain second: ", explain $q2;

my $m = createMesh();
is_deeply( $m, [], 'empty mesh initialization');
$m = createMesh($t);
#is_deeply( $m, [[ [1,2,3], [0,0,0], [1,1,1] ]], 'single triangle mesh initialization');
is_deeply( $m->[0][0], $v123, 'single triangle mesh initialization v0');
is_deeply( $m->[0][1], $v000, 'single triangle mesh initialization v1');
is_deeply( $m->[0][2], $v111, 'single triangle mesh initialization v2');

done_testing();