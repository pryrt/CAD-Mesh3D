use strict;
use warnings;
use Test::More;

use CAD::Mesh3D qw(:all);

################################################################
# error handling
################################################################

# createVertex(): wrong number of coordinates
eval { createVertex(); }; chomp($@);
ok($@, 'Error Handling: createVertex(no args)') or diag "\texplain: ", explain $@;
eval { createVertex(1,2); }; chomp($@);
ok($@, 'Error Handling: createVertex(two args)') or diag "\texplain: ", explain $@;
eval { createVertex(1..4); }; chomp($@);
ok($@, 'Error Handling: createVertex(four args)') or diag "\texplain: ", explain $@;

# createFacet(): wrong number of Vertexs
eval { createFacet(); }; chomp($@);
ok($@, 'Error Handling: createFacet(no args)') or diag "\texplain: ", explain $@;
eval { createFacet(1..2); }; chomp($@);
ok($@, 'Error Handling: createFacet(two args)') or diag "\texplain: ", explain $@;
eval { createFacet(1..4); }; chomp($@);
ok($@, 'Error Handling: createFacet(four args)') or diag "\texplain: ", explain $@;

# createFacet(): invalid Vertex
eval { createFacet( undef, [0,0,0], [1,1,1]); }; chomp($@);
ok($@, 'Error Handling: createFacet(undef first  Vertex)') or diag "\texplain: ", explain $@;
eval { createFacet( 1, [0,0,0], [1,1,1]); }; chomp($@);
ok($@, 'Error Handling: createFacet(scalar first  Vertex)') or diag "\texplain: ", explain $@;
eval { createFacet( {}, [0,0,0], [1,1,1]); }; chomp($@);
ok($@, 'Error Handling: createFacet(wrong ref first  Vertex)') or diag "\texplain: ", explain $@;
eval { createFacet( [1,2], [0,0,0], [1,1,1]); }; chomp($@);
ok($@, 'Error Handling: createFacet(short first  Vertex)') or diag "\texplain: ", explain $@;
eval { createFacet( [1..4], [0,0,0], [1,1,1]); }; chomp($@);
ok($@, 'Error Handling: createFacet(long  first  Vertex)') or diag "\texplain: ", explain $@;
eval { createFacet( [0,0,0], undef, [1,1,1]); }; chomp($@);
ok($@, 'Error Handling: createFacet(undef second Vertex)') or diag "\texplain: ", explain $@;
eval { createFacet( [0,0,0], 'txt', [1,1,1]); }; chomp($@);
ok($@, 'Error Handling: createFacet(scalar second Vertex)') or diag "\texplain: ", explain $@;
eval { createFacet( [0,0,0], \'sref', [1,1,1]); }; chomp($@);
ok($@, 'Error Handling: createFacet(wrong ref second Vertex)') or diag "\texplain: ", explain $@;
eval { createFacet( [0,0,0], [1,2], [1,1,1]); }; chomp($@);
ok($@, 'Error Handling: createFacet(short second Vertex)') or diag "\texplain: ", explain $@;
eval { createFacet( [0,0,0], [1..4], [1,1,1]); }; chomp($@);
ok($@, 'Error Handling: createFacet(long  second Vertex)') or diag "\texplain: ", explain $@;
eval { createFacet( [0,0,0], [1,1,1], undef); }; chomp($@);
ok($@, 'Error Handling: createFacet(undef third  Vertex)') or diag "\texplain: ", explain $@;
eval { createFacet( [0,0,0], [1,1,1], 3); }; chomp($@);
ok($@, 'Error Handling: createFacet(scalar third  Vertex)') or diag "\texplain: ", explain $@;
eval { createFacet( [0,0,0], [1,1,1], \*STDIN); }; chomp($@);
ok($@, 'Error Handling: createFacet(wrong ref third  Vertex)') or diag "\texplain: ", explain $@;
eval { createFacet( [0,0,0], [1,1,1], [1,2]); }; chomp($@);
ok($@, 'Error Handling: createFacet(short third  Vertex)') or diag "\texplain: ", explain $@;
eval { createFacet( [0,0,0], [1,1,1], [1..4]); }; chomp($@);
ok($@, 'Error Handling: createFacet(long  third  Vertex)') or diag "\texplain: ", explain $@;

# createQuadrangleFacets(): wrong number of Vertexes
eval { createQuadrangleFacets(); }; chomp($@);
ok($@, 'Error Handling: createQuadrangleFacets(no args)') or diag "\texplain: ", explain $@;
eval { createQuadrangleFacets(1..3); }; chomp($@);
ok($@, 'Error Handling: createQuadrangleFacets(three args)') or diag "\texplain: ", explain $@;
eval { createQuadrangleFacets(1..5); }; chomp($@);
ok($@, 'Error Handling: createQuadrangleFacets(five args)') or diag "\texplain: ", explain $@;

# createMesh(): invalid triangle
eval { createMesh( undef ); }; chomp($@);
ok($@, 'Error Handling: createMesh(undef triangle)') or diag "\texplain: ", explain $@;
eval { createMesh( [] ); }; chomp($@);
ok($@, 'Error Handling: createMesh(no Vertexs)') or diag "\texplain: ", explain $@;
eval { createMesh( [1..2] ); }; chomp($@);
ok($@, 'Error Handling: createMesh(two Vertexs)') or diag "\texplain: ", explain $@;
eval { createMesh( [1..4] ); }; chomp($@);
ok($@, 'Error Handling: createMesh(four Vertexs)') or diag "\texplain: ", explain $@;
eval { createMesh( [undef, [0,0,0], [1,1,1]] ); }; chomp($@);
ok($@, 'Error Handling: createMesh(first  Vertex undef)') or diag "\texplain: ", explain $@;
eval { createMesh( [1, [0,0,0], [1,1,1]] ); }; chomp($@);
ok($@, 'Error Handling: createMesh(first  Vertex scalar)') or diag "\texplain: ", explain $@;
eval { createMesh( [{}, [0,0,0], [1,1,1]] ); }; chomp($@);
ok($@, 'Error Handling: createMesh(first  Vertex wrong ref)') or diag "\texplain: ", explain $@;
eval { createMesh( [[], [0,0,0], [1,1,1]] ); }; chomp($@);
ok($@, 'Error Handling: createMesh(first  Vertex empty)') or diag "\texplain: ", explain $@;
eval { createMesh( [[1..2], [0,0,0], [1,1,1]] ); }; chomp($@);
ok($@, 'Error Handling: createMesh(first  Vertex short)') or diag "\texplain: ", explain $@;
eval { createMesh( [[1..4], [0,0,0], [1,1,1]] ); }; chomp($@);
ok($@, 'Error Handling: createMesh(first  Vertex long)') or diag "\texplain: ", explain $@;
eval { createMesh( [[1,2,3], 2, [1,1,1]] ); }; chomp($@);
ok($@, 'Error Handling: createMesh(second Vertex invalid)') or diag "\texplain: ", explain $@;
eval { createMesh( [[1,2,3], [0,0,0], 3] ); }; chomp($@);
ok($@, 'Error Handling: createMesh(third  Vertex invalid)') or diag "\texplain: ", explain $@;

# will need a valid mesh for the remaining outputStl tests
my $lft = [sqrt( 0/12),sqrt(0/12),sqrt(0/12)];
my $rgt = [sqrt(12/12),sqrt(0/12),sqrt(0/12)];
my $mid = [sqrt( 3/12),sqrt(9/12),sqrt(0/12)];
my $top = [sqrt( 3/12),sqrt(1/12),sqrt(8/12)];
my $mesh = [[$lft, $mid, $rgt], [$lft, $rgt, $top], [$rgt, $mid, $top], [$mid, $lft, $top]];

# addToMesh():
eval { addToMesh( undef ); }; chomp($@);
ok($@, 'Error Handling: addToMesh(undef): no mesh') or diag "\texplain: ", $@;
eval { addToMesh( $mesh, undef ); }; chomp($@);
ok($@, 'Error Handling: addToMesh(mesh, undef): no triangle(s)') or diag "\texplain: ", $@;
eval { addToMesh( $mesh, 5 ); }; chomp($@);
ok($@, 'Error Handling: addToMesh(mesh, 5): scalar instead of triangle') or diag "\texplain: ", $@;
eval { addToMesh( $mesh, {} ); }; chomp($@);
ok($@, 'Error Handling: addToMesh(mesh, {}): triangle is wrong kind of reference') or diag "\texplain: ", $@;
eval { addToMesh( $mesh, [] ); }; chomp($@);
ok($@, 'Error Handling: addToMesh(mesh, []): empty triangle') or diag "\texplain: ", $@;
eval { addToMesh( $mesh, [$lft, $top, undef] ); }; chomp($@);
ok($@, 'Error Handling: addToMesh(mesh, [left, top, undef]): one vertex undef') or diag "\texplain: ", $@;
eval { addToMesh( $mesh, [$lft, 7, $mid] ); }; chomp($@);
ok($@, 'Error Handling: addToMesh(mesh, [left, scalar, middle]): one vertex scalar') or diag "\texplain: ", $@;
eval { addToMesh( $mesh, [$lft, $top, {}] ); }; chomp($@);
ok($@, 'Error Handling: addToMesh(mesh, [left, top, {}]): one vertex wrong reference type') or diag "\texplain: ", $@;
eval { addToMesh( $mesh, [[], $top, $mid] ); }; chomp($@);
ok($@, 'Error Handling: addToMesh(mesh, [[], top, mid]): one vertex empty') or diag "\texplain: ", $@;

# outputStl(): missing fh
eval { outputStl($mesh) }; chomp($@);
ok($@, 'Error Handling: outputStl(missing fh)') or diag "\texplain: ", explain $@;

# outputStl(): cannot write to fh
eval { outputStl($mesh, '/path/does/not/exist') }; chomp($@);
ok($@, 'Error Handling: outputStl(missing fh)') or diag "\texplain: ", explain $@;

# outputStl(): non-recognized $ascii argument
eval { outputStl($mesh, \*STDERR, 'bad') }; chomp($@);
ok($@, 'Error Handling: outputStl(bad ascii switch)') or diag "\texplain: ", explain $@;

done_testing();