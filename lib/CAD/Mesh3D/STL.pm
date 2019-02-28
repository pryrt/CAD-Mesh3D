package CAD::Mesh3D::STL;
use warnings;
use strict;
use Carp;
use 5.010;  # M::V::R requires 5.010, so might as well make use of the defined-or // notation :-)
use Math::Vector::Real 0.18;
use CAD::Format::STL qw//;
our $VERSION = 0.001_011;

=head1 NAME

CAD::Mesh3D::STL - Used by CAD::Mesh3D to provide the STL output functionality

=head1 SYNOPSIS

 use CAD::Mesh3D qw(STL :create :output);       # enable CAD::Mesh3D::STL, and import the :create and :output
 my $v1 = createVertex(...);
 ...
 my $tri  = createFacet($v1, $v2, $v3);
 my $mesh = createMesh();
 addToMesh($mesh, $tri);
 ...
 output($mesh, STL => $filehandle_or_filename, $true_for_ascii_false_for_binary);

=head1 DESCRIPTION

A framework to create and manipulate 3D vertices and meshes, suitable for generating STL files
(or other similar formats) for 3D printing.

A B<Mesh> is the container for the surface of the shape or object being generated.  The surface is broken down
into locally-flat pieces known as B<Facet>s.  Each Facet is a triangle made from exactly points, called
B<Vertex>es or vertices.  Each Vertex is made up of three x, y, and z B<coordinate>s, which are just
floating-point values to represent the position in 3D space.

=cut

################################################################
# Exports
################################################################

use Exporter 5.57 'import';     # v5.57 needed for getting import() without @ISA
our @EXPORT_OUTPUT  = qw(outputStl);
our @EXPORT_INPUT   = qw();
our @EXPORT_OK      = (@EXPORT_OUTPUT, @EXPORT_INPUT);
our @EXPORT         = ();
our %EXPORT_TAGS = (
    output          => \@EXPORT_OUTPUT,
    input           => \@EXPORT_INPUT,
    all             => \@EXPORT_OK,
);

=head2 enableFormat

L<CAD::Mesh3D> should automatically run C<enableFormat('STL')>, though
the user can run it again, just to make sure.  This will tell C<CAD::Mesh3D>
where to find the functions for C<output(STL =E<gt> $filename)>
(and eventually C<input(STL =E<gt> $filename>).

=cut

################################################################
# _io_functions():
# CAD::Mesh3D::enableFormat('STL') calls CAD::Mesh3D::STL::_io_functions(),
# and expects it to return a hash with coderefs the 'input'
# and 'output' functions.  Use undef (or leave out the key/value entirely)
# for a direction that doesn't exist.
#   _io_functions { input => \&inputSTL, output => \&outputSTL }
#   _io_functions { input => undef, output => \&outputSTL }
#   _io_functions { output => \&outputSTL }
#   _io_functions { input => sub { ... } }
################################################################
sub _io_functions {
    return (
        output => \&outputStl,
        input => sub { croak sprintf "Sorry, %s's developer has not yet debugged inputting from STL", __PACKAGE__ },
    );
}


our %IOFUNCTIONS = (
);

################################################################
# file output
################################################################

=head2 FILE OUTPUT

The following function will output the B<Mesh> to a 3D output file.
Currently, only STL is supported.

They can be imported into your script I<en masse> using the C<:output> tag.

=cut

=head3 output

=head3 outputStl

    CAD::Mesh3D::STL::outputStl($mesh, $file, $asc);

This should really be called using the C<CAD::Mesh3D/"output()"> wrapper

    use CAD::Mesh3D qw/+STL :output/;
    output($mesh, STL => $file, $asc);

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

    #############################################################################################
    # use CAD::Format::STL to output the STL
    #############################################################################################
    my $stl = CAD::Format::STL->new;
    my $part = $stl->add_part("my part", @$mesh);

    if($asc) {
        $stl->save( ascii => $fh );
    } else {
        $stl->save( binary => $fh );
    }

    # close the file, if outputStl() is where the handle was opened (ie, not on existing fh, STDERR, or STDOUT)
    close($fh) if $doClose;
    return;
}

=head1 TODO

=over

=item * inputSTL()

=back

=head1 AUTHOR

Peter C. Jones C<E<lt>petercj AT cpan DOT orgE<gt>>

=head1 COPYRIGHT

Copyright (C) 2017,2018,2019 Peter C. Jones

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

=cut

1;