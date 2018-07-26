use 5.008;      # required for in-memory files
use strict;
use warnings;
use Test::More tests => 13;

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

# note '';
# note 'MESH:';
# note sprintf '%-8.8s   <%.9e,%.9e,%.9e> <%.9e,%.9e,%.9e> <%.9e,%.9e,%.9e>', '', map { @$_ } @$_ for @$mesh;

# define the expected values for the binary and ascii tests
my $expected_ubin = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000080bf0000000000000000000000000000003fd7b35d3f000000000000803f0000000000000000000000000000ef5b71bfabaaaa3e0000000000000000000000000000803f00000000000000000000003f3acd933eec05513f0000ec05513fef5bf13eabaaaa3e0000803f00000000000000000000003fd7b35d3f000000000000003f3acd933eec05513f0000ec0551bfef5bf13eabaaaa3e0000003fd7b35d3f000000000000000000000000000000000000003f3acd933eec05513f0000";
    # expected unpacked bin.  comments that follow help describe what's going on...
    #               "null header....................................................................................................................................................'########n1-----'n2-----'n3-----'a1-----'a2-----'a3-----'b1-----'b2-----'b3-----'c1-----'c2-----'c3-----'sss'n1-----'n2-----'n3-----'a1-----'a2-----'a3-----'b1-----'b2-----'b3-----'c1-----'c2-----'c3-----'sss'n1-----'n2-----'n3-----'a1-----'a2-----'a3-----'b1-----'b2-----'b3-----'c1-----'c2-----'c3-----'sss'n1-----'n2-----'n3-----'a1-----'a2-----'a3-----'b1-----'b2-----'b3-----'c1-----'c2-----'c3-----'sss'"
    # if the bigendian pack fails, it will be
    #               "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000bf8000000000000000000000000000003f0000003f5db3d7000000003f8000000000000000000000000000000000bf715bef3eaaaaab0000000000000000000000003f80000000000000000000003f0000003e93cd3a3f5105ec00003f5105ec3ef15bef3eaaaaab3f80000000000000000000003f0000003f5db3d7000000003f0000003e93cd3a3f5105ec0000bf5105ec3ef15bef3eaaaaab3f0000003f5db3d7000000000000000000000000000000003f0000003e93cd3a3f5105ec0000"
my $expected_ascii =<<EOA;
solid OBJECT
    facet normal   0.0000000e+000   0.0000000e+000  -1.0000000e+000
        outer loop
            vertex   0.0000000e+000   0.0000000e+000   0.0000000e+000
            vertex   5.0000000e-001   8.6602540e-001   0.0000000e+000
            vertex   1.0000000e+000   0.0000000e+000   0.0000000e+000
        endloop
    endfacet
    facet normal   0.0000000e+000  -9.4280904e-001   3.3333333e-001
        outer loop
            vertex   0.0000000e+000   0.0000000e+000   0.0000000e+000
            vertex   1.0000000e+000   0.0000000e+000   0.0000000e+000
            vertex   5.0000000e-001   2.8867513e-001   8.1649658e-001
        endloop
    endfacet
    facet normal   8.1649658e-001   4.7140452e-001   3.3333333e-001
        outer loop
            vertex   1.0000000e+000   0.0000000e+000   0.0000000e+000
            vertex   5.0000000e-001   8.6602540e-001   0.0000000e+000
            vertex   5.0000000e-001   2.8867513e-001   8.1649658e-001
        endloop
    endfacet
    facet normal  -8.1649658e-001   4.7140452e-001   3.3333333e-001
        outer loop
            vertex   5.0000000e-001   8.6602540e-001   0.0000000e+000
            vertex   0.0000000e+000   0.0000000e+000   0.0000000e+000
            vertex   5.0000000e-001   2.8867513e-001   8.1649658e-001
        endloop
    endfacet
endsolid OBJECT
EOA

{
    my @v = (
        [0,0,-1], [0,0,0], [5.0e-1, 8.6602540e-1, 0], [1,0,0],
        [0,-9.4280904e-1,3.3333333e-1], [0,0,0], [1,0,0], [5.0000000e-001,2.8867513e-001,8.1649658e-001],
        [8.1649658e-001, 4.7140452e-001, 3.3333333e-001], [1.0000000e+000, 0.0000000e+000, 0.0000000e+000], [5.0000000e-001, 8.6602540e-001, 0.0000000e+000], [5.0000000e-001, 2.8867513e-001, 8.1649658e-001],
        [-8.1649658e-001, 4.7140452e-001, 3.3333333e-001], [5.0000000e-001, 8.6602540e-001, 0.0000000e+000], [0.0000000e+000, 0.0000000e+000, 0.0000000e+000], [5.0000000e-001, 2.8867513e-001, 8.1649658e-001],
   );
   my $x = '';
   $x .= sprintf "solid OBJECT\n";
   for(1..4) {
   $x .= sprintf "    facet normal %16.7e %16.7e %16.7e\n", @{ shift @v };
   $x .= sprintf "        outer loop\n";
   $x .= sprintf "            vertex %16.7e %16.7e %16.7e\n", @{ shift @v } for 1 .. 3;
   $x .= sprintf "        endloop\n";
   $x .= sprintf "    endfacet\n";
   }
   $x .= sprintf "endsolid OBJECT\n";
   #diag $x;
   #chomp $x;
   #chomp(my $exp = $expected_ascii);
   #is( $x, $exp, 'debug');
   $expected_ascii = $x;
}

foreach my $asc (undef, 0, qw(false binary bin true ascii asc), 1) {
    my $memory = '';
    open my $fh, '>', \$memory or die "in-memory handle failed: $!";
    outputStl($mesh, $fh, $asc);
    my $expected;
    if(0 != ord $memory) {  # ascii
        chomp $memory;
        chomp($expected = $expected_ascii);
    } else {                # binary (need to unpack to a string)
        $expected = $expected_ubin;
        $memory = unpack 'H*', $memory;
    }
    #note sprintf "MEMORY[%8.8s] = '%s'\n", defined $asc ? $asc : '<undef>', $memory;
    is( $memory, $expected, sprintf 'outputStl(mesh, fh, "%s")', defined $asc ? $asc : '<undef>');
    close($fh);
}
{
    my $tdir;
    for my $try ( $ENV{TEMP}, $ENV{TMP}, '/tmp', '.' ) {
        # diag "before: ", $try;
        $try =~ s{\\}{/}gx if index($try, '\\')>-1 ;        # without the if-index, died with modification of read-only value on /tmp or .
        # diag "after:  ", $try;
        next unless -d $try;
        next unless -w _;
        $tdir = $try;
        last;
    }
    # diag "final: '", $tdir // '<undef>', "'";
    die "could not find a writeable directory" unless defined $tdir && -d $tdir && -w $tdir;

    my $f1 = $tdir.'/filename';
    my $f2 = $tdir.'/namefile.stl';

    # redirect STDOUT & STDERR
    my($memout,$memerr);
    open my $fh_out, '>&', \*STDOUT or die "cannot dup STDOUT: $!";
    close STDOUT; open STDOUT, '>', \$memout or die "cannot open in-memory STDOUT: $!";

    open my $fh_err, '>&', \*STDERR or die "cannot dup STDERR: $!";
    close STDERR; open STDERR, '>', \$memerr or die "cannot open in-memory STDERR: $!";

    outputStl($mesh, $_, $_ eq $f2) for 'STDOUT', 'STDERR', $f1, $f2; # use ascii for f2

    close STDERR; open STDERR, '>&', $fh_err;
    close STDOUT; open STDOUT, '>&', $fh_out;

    $memout = unpack 'H*', $memout;
    $memerr = unpack 'H*', $memerr;
    my $slurp1 = do {
        local $/ = undef;
        $f1 .= '.stl' unless $f1 =~ /\.stl$/i;
        open my $fh, '<', $f1 or die "cannot read \"$f1\": $!";
        binmode $fh;
        my $ret = unpack 'H*', <$fh>;
        close $fh;
        print qx/ls -l $f1/;
        unlink $f1 or diag "could not unlink \"$f1\": $!";
        $ret;
    };
    my $slurp2 = do {
        local $/ = undef;
        open my $fh, '<', $f2 or die "cannot read \"$f2\": $!";
        my $ret = <$fh>;
        print qx/ls -l $f2/;
        close $fh;
        unlink $f2 or diag "could not unlink \"$f2\": $!";
        $ret;
    };

    is( $memout, $expected_ubin,  'outputStl(mesh, STDOUT > memfile, binary)' );
    is( $memerr, $expected_ubin,  'outputStl(mesh, STDERR > memfile, binary)' );
    is( $slurp1, $expected_ubin,  sprintf 'outputStl(mesh, "%s", binary)', $f1 );
    is( $slurp2, $expected_ascii, sprintf 'outputStl(mesh, "%s", ascii)', $f2 );

}

done_testing();