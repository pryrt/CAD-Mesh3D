use 5.008;      # required for in-memory files
use strict;
use warnings;
use Test::More;

use App::Generate3dMesh qw(:all);

my $lft = createVertex(0,0,0);
my $rgt = createVertex(1,0,0);
my $mid = createVertex(sqrt(3/12),sqrt(9/12),sqrt(0/12));
my $top = createVertex(sqrt(3/12),sqrt(1/12),sqrt(8/12));

# note sprintf '%s = <%.9e,%.9e,%.9e>', lft => @$lft;
# note sprintf '%s = <%.9e,%.9e,%.9e>', rgt => @$rgt;
# note sprintf '%s = <%.9e,%.9e,%.9e>', mid => @$mid;
# note sprintf '%s = <%.9e,%.9e,%.9e>', top => @$top;

my $mesh = createMesh();
my $tri = createFacet($lft, $mid, $rgt);
# note sprintf '%-8.8s = <%.9e,%.9e,%.9e> <%.9e,%.9e,%.9e> <%.9e,%.9e,%.9e>', floor => map { @$_ } @$tri;
push @$mesh, $tri;

$tri = createFacet($lft, $rgt, $top);
# note sprintf '%-8.8s = <%.9e,%.9e,%.9e> <%.9e,%.9e,%.9e> <%.9e,%.9e,%.9e>', front => map { @$_ } @$tri;
push @$mesh, $tri;

$tri = createFacet($rgt, $mid, $top);
# note sprintf '%-8.8s = <%.9e,%.9e,%.9e> <%.9e,%.9e,%.9e> <%.9e,%.9e,%.9e>', right => map { @$_ } @$tri;
push @$mesh, $tri;

$tri = createFacet($mid, $lft, $top);
# note sprintf '%-8.8s = <%.9e,%.9e,%.9e> <%.9e,%.9e,%.9e> <%.9e,%.9e,%.9e>', left  => map { @$_ } @$tri;
push @$mesh, $tri;

use Data::Dumper;
diag Dumper $mesh;

use CAD::Format::STL;
my $stl = CAD::Format::STL->new;
my $part = $stl->add_part("name", @$mesh);
$stl->save(binary => 'altbin.stl');
$stl->save(ascii => 'altasc.stl');

done_testing();