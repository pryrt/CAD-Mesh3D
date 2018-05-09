package App::Generate3dMesh;
use warnings;
use strict;
use Carp;
use 5.010;  # M::V::R requires 5.010, so might as well make use of the defined-or // notation :-)
use Math::Vector::Real 0.18;
our $VERSION = 0.001_003;

=head1 NAME

App::Generate3dMesh - Create and Manipulate 3D Vertices and Meshes and output for 3D printing

=head1 SYNOPSIS

 use App::Generate3dMesh qw(:create :output);
 my $vect = createVertex();
 my $tri  = createFacet($v1, $v2, $v3);
 my $mesh = createMesh();
 #addToMesh($mesh, $tri, ...);    # not implemented yet
 push @$mesh, $tri;               # manual method of addToMesh()
 ...
 outputStl($mesh, $filehandle_or_filename, $true_for_ascii_false_for_binary);

=head1 DESCRIPTION

A framework to create and manipulate 3D vertices and meshes, suitable for generating STL files
for 3D printing.

A B<Mesh> is the container for the surface of the shape or object being generated.  The surface is broken down
into locally-flat pieces known as B<Facet>s.  Each Facet is a triangle made from exactly points, called
B<Vertex>es or vertices.  Each Vertex is made up of three x, y, and z B<coordinate>s, which are just
floating-point values to represent the position in 3D space.

=head1 FUNCTIONS

=cut

################################################################
# Exports
################################################################

use Exporter 5.57 'import';     # v5.57 needed for getting import() without @ISA
our @EXPORT_CREATE  = qw(createVertex createFacet createQuadrangleFacets createMesh);
our @EXPORT_VERTEX  = qw(createVertex getx gety getz);
our @EXPORT_MATH    = qw(unitDelta unitCross facetNormal);
our @EXPORT_OUTPUT  = qw(outputStl);
our @EXPORT_OK      = (@EXPORT_CREATE, @EXPORT_MATH, @EXPORT_OUTPUT, @EXPORT_VERTEX);
our @EXPORT         = @EXPORT_OK;
our %EXPORT_TAGS = (
    create          => \@EXPORT_CREATE,
    vertex          => \@EXPORT_VERTEX,
    math            => \@EXPORT_MATH,
    output          => \@EXPORT_OUTPUT,
    all             => \@EXPORT_OK,
);

################################################################
# "object" creation
################################################################
use constant { XCOORD=>0, YCOORD=>1, ZCOORD=>2 }; # avoid magic numbers

################################################################
# "object" creation
################################################################
# TODO = make the error checking into self-contained routines -- there's
#   too much duplicated work

=head2 OBJECT CREATION

The following functions will create the B<Mesh>, B<Triangle>, and B<Vertex> array-references.
They can be imported into your script I<en masse> using the C<:create> tag.

=head3 createVertex

 my $v = createVertex( $x, $y, $z );

Creates a B<Vertex> using the given C<$x, $y, $z> floating-point values
to represent the x, y, and z coordinates in 3D space.

=cut

sub createVertex {
    croak sprintf("!ERROR! createVertex(x,y,z): requires 3 coordinates; you supplied %d", scalar @_)
        unless 3==@_;
    return [@_];
}

=head3 createFacet

 my $f = createFacet( $a, $b, $c );

Creates a B<Facet> using the three B<Vertex> arguments as the corner points of the triangle.

Note that the order of the B<Facet>'s vertices matters, and follows the
L<right-hand rule|https://en.wikipedia.org/wiki/Right-hand_rule> to determine the "outside" of
the B<Facet>: if you are looking at the B<Facet> such that the points are arranged in a
counter-clockwise order, then everything from the B<Facet> towards you (and behind you) is
"outside" the surface, and everything beyond the B<Facet> is "inside" the surface.

=cut

sub createFacet {
    croak sprintf("!ERROR! createFacet(t1,t2,t3): requires 3 Vertices; you supplied %d", scalar @_)
        unless 3==@_;
    foreach my $v ( @_ ) {
        croak sprintf("!ERROR! createFacet(t1,t2,t3): each Vertex must be an array ref; you supplied \"%s\"", ref $v ? ref($v)."REF" : defined $v ? $v : '<undef>')
            unless 'ARRAY' eq ref $v;

        croak sprintf("!ERROR! createFacet(t1,t2,t3): each Vertex requires 3 coordinates; you supplied %d: <%s>", scalar @$v, join(",", @$v))
            unless 3==@$v;
    }
    return [@_[0..2]];
}

=head4 createQuadrangleFacets

  my @f = createQuadrangleFacets( $a, $b, $c, $d );

Creates two B<Facet>s using the four B<Vertex> arguments as the corners of a quadrangle
(like with C<createFacet>, the arguments are ordered by the right-hand rule).  This returns
a list of two triangular B<Facet>s, for the triangles B<ABC> and B<ACD>.

=cut

sub createQuadrangleFacets {
    croak sprintf("!ERROR! createQuadrangleFacets(t1,t2,t3,t4): requires 4 Vertices; you supplied %d", scalar @_)
        unless 4==@_;
    my ($a,$b,$c,$d) = @_;
    return ( createFacet($a,$b,$c), createFacet($a,$c,$d) );
}

=head4 getx

=head4 gety

=head4 getz

    my $v = createVertex(1,2,3);
    my $x = getx($v); # 1
    my $y = getx($v); # 2
    my $z = getx($v); # 3

Grabs the individual x, y, or z coordinate from a vertex

=cut

sub getx($) { shift()->[XCOORD] }
sub gety($) { shift()->[YCOORD] }
sub getz($) { shift()->[ZCOORD] }

=head3 createMesh

 my $m = createMesh();          # empty
 my $s = createMesh($f, ...);   # pre-populated

Creates a B<Mesh>, optionally pre-populating the Mesh with the supplied B<Facet>s.

=cut

sub createMesh {
    foreach my $tri ( @_ ) {
        croak sprintf("!ERROR! createMesh(...): each triangle must be defined; this one was undef")
            unless defined $tri;

        croak sprintf("!ERROR! createMesh(...): each triangle requires 3 Vertices; you supplied %d: <%s>", scalar @$tri, join(",", @$tri))
            unless 3==@$tri;

        foreach my $v ( @$tri ) {
            croak sprintf("!ERROR! createMesh(...): each Vertex must be an array ref; you supplied \"%s\"", ref $v ? ref($v)."REF" : defined $v ? $v : '<undef>')
                unless 'ARRAY' eq ref $v;

            croak sprintf("!ERROR! createMesh(...): each Vertex in each triangle requires 3 coordinates; you supplied %d: <%s>", scalar @$v, join(",", @$v))
                unless 3==@$v;
        }
    }
    return [@_];
}

################################################################
# math
################################################################

=head2 MATH FUNCTIONS

Three-dimensional math can take some special functions.  Some of those
are available to your script.

They can be imported into your script I<en masse> using the C<:math> tag.

=head3 unitDelta

 my $uAB = unitDelta( $A, $B );

Returns a vector (using same structure as a B<Vertex>), which gives the
direction from B<Vertex A> to B<Vertex B>.  This is scaled so that
the vector has a magnitude of 1.0.

=cut

sub unitDelta($$) {
    # TODO = argument checking
    my ($beg, $end) = @_;
    my $dx = $end->[XCOORD] - $beg->[XCOORD];
    my $dy = $end->[YCOORD] - $beg->[YCOORD];
    my $dz = $end->[ZCOORD] - $beg->[ZCOORD];
    my $m = sqrt( $dx*$dx + $dy*$dy + $dz*$dz );
    return $m ? [ $dx/$m, $dy/$m, $dz/$m ] : [0,0,0];
}

=head3 unitCross

 my $uN = unitCross( $uAB, $uBC );

Returns the cross product for the two vectors, which gives a vector
perpendicular to both.  This is scaled so that the vector has a
magnitude of 1.0.

A typical usage would be for finding the direction to the "outside"
(the normal-vector) using the right-hand rule.  For a B<Facet> with
points A, B, and C, first, find the direction from A to B, and from B
to C; the C<unitCross> of those two deltas gives you the normal-vector
(and, in fact, that's how S<C<facetNormal()>> is implemented).

 my $uAB = unitDelta( $A, $B );
 my $uBC = unitDelta( $B, $C );
 my $uN  = unitCross( $uAB, $uBC );

=cut

sub unitCross($$) {
    # TODO = argument checking
    my ($v1, $v2) = @_; # two vectors
    my $dx = $v1->[1]*$v2->[2] - $v1->[2]*$v2->[1];
    my $dy = $v1->[2]*$v2->[0] - $v1->[0]*$v2->[2];
    my $dz = $v1->[0]*$v2->[1] - $v1->[1]*$v2->[0];
    my $m = sqrt( $dx*$dx + $dy*$dy + $dz*$dz );
    return $m ? [ $dx/$m, $dy/$m, $dz/$m ] : [0,0,0];
}

=head3 unitCross

 my $uN = facetNormal( $facet );

Uses S<C<unitDelta()>> and  S<C<unitCross()>> to find the normal-vector
for the given B<Facet>, given the right-hand rule order for the B<Facet>'s
vertices.

=cut

sub facetNormal($) {
    # TODO = argument checking
    my ($A,$B,$C) = @{ shift() };   # three vertices of the facet
    my $uAB = unitDelta( $A, $B );
    my $uBC = unitDelta( $B, $C );
    return    unitCross( $uAB, $uBC );
}

################################################################
# file output
################################################################

=head2 FILE OUTPUT

The following function will output the B<Mesh> to a 3D output file.
Currently, only STL is supported.

They can be imported into your script I<en masse> using the C<:output> tag.

=cut

# need to decide whether to use the perl>=v5.010's pack 'f<' notation,
#   or mimic it based on the endianness of packed floats
if( $] lt '5.010' ) {
    my $str = join('', unpack("H*", pack 'f' => 1));
    if('0000803f' eq $str) {        # little endian, so can use native pack
        *__f3pack = sub { pack 'f3', @_ };
    } elsif('3f800000' eq $str) {   # big endian, so need to swizzle things
        *__f3pack = sub { my $p; $p .= reverse pack('f', $_) for @_; return $p };
    }
} else {
    *__f3pack = sub { pack 'f<3', @_ };
}

=head3 outputStl

 outputStl($mesh, $file, $asc);

Outputs the given C<$mesh> to the indicated file.

The C<$file> argument is either an already-opened filehandle, or the name of the file
(if the full path is not specified, it will default to your script's directory),
or "STDOUT" or "STDERR" to direct the output to the standard handles.

The C<$asc> argument determines whether to use STL's ASCII mode: a non-zero numeric value,
or the case-insensitive text "ASCII" or "ASC" will select ASCII mode; a missing or undefined
C<$asc> argument, or a zero value or empty string, or the case-insensitive text "BINARY"
or "BIN" will select BINARY mode; if the argument contains a string other than those mentioned,
S<C<outputStl()>> will cause the script to die.

=cut

# outputStl(mesh, file, asc)
sub outputStl {
    # verify it's a valid mesh
    my $mesh = shift;
    for($mesh) { # TODO = error handling
    }   # /check_mesh

    # process the filehandle / filename
    my $doClose = 0;    # don't close the filehandle when done, unless it's a filename
    my $fh = my $fn = shift;
    for($fh) {
        croak sprintf('!ERROR! outputStl(mesh, fh, opt): requires file handle or name') unless $_;
        $_ = \*STDOUT if /^STDOUT$/i;
        $_ = \*STDERR if /^STDERR$/i;
        if( 'GLOB' ne ref $_ ) {
            $fn .= '.stl' unless $fn =~ /\.stl$/i;
            open my $tfh, '>', $fn or croak sprintf('!ERROR! outputStl(): cannot write to "%s": %s', $fn, $!);
            $_ = $tfh;
            $doClose++; # will need to close the file
        }
    }   # /check_fh

    # determine whether it's ASCII or binary
    my $asc = shift || 0;   check_asc: for($asc) {
        $_ = 1 if /^(?:ASC(?:|II)|true)$/i;
        $_ = 0 if /^(?:bin(?:|ary)|false)$/i;
        croak sprintf('!ERROR! outputStl(): unknown asc/bin switch "%s"', $_) if $_ && /\D/;
    }   # /check_asc
    binmode $fh unless $asc;

    # actually output things...
    # printf STDERR "DEBUG  outputStl(%s) | %s %s # %f\n", join(',', $mesh, "${fn}:${fh}", $asc), $fh, scalar localtime, rand 100;
    if($asc) {
        printf $fh "solid %s\n", 'OBJECT';
    } else {
        # PREFIX/HEADER (80 NULL bytes)
        print $fh pack 'x[80]', 0;
        # number of triangles in the mesh
        print $fh pack 'V', scalar @$mesh;
    }
    foreach my $tri (@$mesh) {
        # output normal
        my $cr = facetNormal($tri);
        if($asc) {
            printf $fh "    facet normal %16.7e %16.7e %16.7e\n", @$cr;
            printf $fh "        outer loop\n";
        } else {
            print $fh __f3pack(@$cr);
        }

        # output each vertex
        foreach my $v (@$tri) {
            if($asc) {
                printf $fh "            vertex %16.7e %16.7e %16.7e\n", @$v;
            } else {
                print $fh __f3pack(@$v);
            }
        }

        # end of this facet
        if($asc) {
            printf $fh "        endloop\n";
            printf $fh "    endfacet\n";
        } else {
            print $fh pack 'v', 0x0000; # the attribute byte count = 0
        }
    }
    printf $fh "endsolid %s\n", 'OBJECT'    if $asc;

    # close the file, if outputStl() is where the handle was opened (ie, not on existing fh, STDERR, or STDOUT)
    close($fh) if $doClose;
}

=head1 AUTHOR

Peter C. Jones C<E<lt>petercj AT cpan DOT orgE<gt>>

=head1 COPYRIGHT

Copyright (C) 2017 Peter C. Jones

=head1 LICENCE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

=cut

1;