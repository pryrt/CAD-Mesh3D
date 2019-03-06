use 5.010;      # v5.8 equired for in-memory files; v5.10 required for named backreferences and // in the commented-note() calls
use strict;
use warnings;
use Test::More tests => 3*7;

use CAD::Mesh3D qw(+STL :all);

# input(): debugging
#    throws_ok { my $mesh = input(STL => 'files/cube.stl') } qr/Sorry, CAD::Mesh3D::STL's developer has not yet debugged inputting from STL/, 'Error Handling: input() has not been implemented yet';
#    throws_ok { my $mesh = CAD::Mesh3D::STL::inputStl('files/cube_binary.stl') } qr/\QCAD::Mesh3D::STL::inputStl(): not yet implemented, sorry.\E/, 'Error Handling: direct call to inputStl(), which has not been implemented yet';

use Scalar::Util qw/openhandle/;
my $memory = do { open my $fh, '<', 'files/cube.stl'; local $/; <$fh> };    # slurp
open my $memfh, '<', \$memory or die "in-memory handle failed: $!";
foreach my $file ( $memfh, 'files/cube.stl', 'files/cube_binary.stl' ) {
    # note "\n\nfile => $file\n";
    my $mesh = ($file eq $memfh) ? input(STL => $file, 'ascii') : input(STL => $file);
    isa_ok( $mesh , 'CAD::Mesh3D');
    is( @$mesh , 12 , "input(STL=>$file): 12 facets" );
    my $f = $mesh->[8];
    isa_ok( $f , 'CAD::Mesh3D::Facet' );
    is( @$f, 3 , "input(STL=>$file): 9th facet has 3 vertexes");
    my @cmpv = (createVertex(1,0,0), createVertex(1,1,0), createVertex(1,1,1));
    foreach my $i ( 0 .. $#cmpv ) {
        is_deeply( $f->[$i], $cmpv[$i] , "compare facet.v[$i] to $cmpv[$i]");
    }
}
close $memfh;

###### fault handling ######
use Test::Exception;

# output(): missing fh
#throws_ok { ... } qr/output.*: requires file handle or name/, 'Error Handling: ... TODO';

done_testing();