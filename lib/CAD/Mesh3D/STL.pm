package CAD::Mesh3D::STL;
use warnings;
use strict;
use Carp;
use 5.010;  # M::V::R requires 5.010, so might as well make use of the defined-or // notation :-)
use CAD::Format::STL qw//;
use CAD::Mesh3D qw/:create/;
our $VERSION = 0.001_011;

=head1 NAME

CAD::Mesh3D::STL - Used by CAD::Mesh3D to provide the STL format-specific functionality

=head1 SYNOPSIS

 use CAD::Mesh3D qw(+STL :create :formats);       # enable CAD::Mesh3D::STL, and import the :create and :formats tags
 my $v1 = createVertex(...);
 ...
 my $tri  = createFacet($v1, $v2, $v3);
 my $mesh = createMesh();
 addToMesh($mesh, $tri);
 ...
 $mesh->output(STL => $filehandle_or_filename, $true_for_ascii_false_for_binary);

=head1 DESCRIPTION

This module is used by L<CAD::Mesh3D> to provide the STL format-specific functionality, including
saving B<Mesh>es as STL files, or loading a B<Mesh>es from STL files.

L<STL|https://en.wikipedia.org/wiki/STL_(file_format)> ("stereolithography") files are a CAD format used as inputs in the 3D printing process.

The module supports either ASCII (plain-text) or binary (encoded) STL files.

=cut

################################################################
# Exports
################################################################

use Exporter 5.57 'import';     # v5.57 needed for getting import() without @ISA
our @EXPORT_OK      = ();
our @EXPORT         = ();
our %EXPORT_TAGS = (
    all             => \@EXPORT_OK,
);

=head2 enableFormat

You need to tell L<CAD::Mesh3D> where to find this STL module.  You can
either specify C<+STL> when you C<use CAD::Mesh3D>:

 use CAD::Mesh3D qw(+STL :create :formats);

Or you can independently enable the STL format sometime later:

 use CAD::Mesh3D qw(:create :formats);
 enableFormat( 'STL' );

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
        input => \&inputStl, # sub { croak sprintf "Sorry, %s's developer has not yet debugged inputting from STL", __PACKAGE__ },
    );
}

################################################################
# file output
################################################################

=head2 FILE OUTPUT

=head3 output

=head3 outputStl

To output your B<Mesh> using the STL format, you should use CAD::Mesh3D's C<output()>
wrapper method.  You can also call it as a function, which is included in the C<:formats> import tag.

 use CAD::Mesh3D qw/+STL :formats/;
 $mesh->output(STL => $file, $asc);
 # or
 output($mesh, STL => $file, $asc);

The wrapper will call the C<CAD::Mesh3D::STL::outputStl()> function internally, but
makes it easy to keep your code compatible with other 3d-file formats.

If you insist on calling the STL function directly, it is possible, but not
recommended, to call

 CAD::Mesh3D::STL::outputStl($mesh, $file, $asc);

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
    for($fh) { # check_fh
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

=head2 FILE INPUT

=head3 input

=head3 inputStl

NOT YET IMPLEMENTED

To input your B<Mesh> from an STL file, you should use L<CAD::Mesh3D>'s C<input()> wrapper function,
which is included in the C<:formats> import tag.

 use CAD::Mesh3D qw/+STL :formats/;
 my $mesh = input(STL => $file, $asc);

The wrapper will call the C<CAD::Mesh3D::STL::inputStl()> function internally, but makes it easy to
keep your code compatible with other 3d-file formats.

If you insist on calling the STL function directly, it is possible, but not recommended, to call

 my $mesh = CAD::Mesh3D::STL::inputStl($file, $asc);

The C<$file> argument is either an already-opened filehandle, or the name of the file
(if the full path is not specified, it will default to your script's directory),
or "STDIN" to receive the input from the standard input handle.

The C<$asc> argument determines whether to use STL's ASCII mode: a non-zero numeric value,
or the case-insensitive text "ASCII" or "ASC" will select ASCII mode; a missing or undefined
C<$asc> argument, or a zero value or empty string, or the case-insensitive text "BINARY"
or "BIN" will select BINARY mode; if the argument contains a string other than those mentioned,
S<C<inputStl()>> will cause the script to die.

=cut

sub inputStl {
    my ($file, $asc_or_bin) = @_;
    my @pass_args = ($file);
    if( !defined($asc_or_bin) || ('' eq $asc_or_bin)) { # automatic
        # automatic won't work on in-memory files, for which stat() will give an "unopened filehandle" warning
        in_memory_check: {
            local $SIG{__WARN__} = sub {
                # uncoverable branch false
                if( $_[0] =~ /\Qstat() on unopened filehandle\E/ ) {
                    croak "\ninputStl($file): ERROR\n",
                        "\tin-memory file handles are not allowed without explicit ASCII or BINARY setting\n",
                        "\tplease rewrite the call with an explicit\n",
                        "\t\tinputStl(\$in_mem_fh, \$asc_or_bin)\n",
                        "\tor\n",
                        "\t\tinput(STL => \$in_mem_fh, \$asc_or_bin)\n",
                        "\twhere \$asc_or_bin is either 'ascii' or 'binary'\n",
                        " ";
                } else {
                    carp @_; # uncoverable statement
                }
            };
            my $size = (stat($file))[7];    # this will cause the warning if it's in-memory
            carp "stat() on unopened filehandle" unless defined $size;  # force the warning on 5.16-5.20, which for some reason didn't warn...
        }
    } elsif ( $asc_or_bin =~ /(asc(?:ii)?|bin(?:ary)?)/i ) {
        # we found an explicit 'ascii/binary' indicator
        unshift @pass_args, $asc_or_bin;
    } else { # otherwise, error
        croak "\ninputStl($file, '$asc_or_bin'): ERROR: unknown mode '$asc_or_bin'\n ";
    }

    my $stl = CAD::Format::STL->new()->load(@pass_args); # CFS claims it take handle or name
        # TODO: bug report <https://rt.cpan.org/Public/Dist/Display.html?Name=CAD-Format-STL>:
        #   examples show ->reader() and ->writer(), but that example code doesn't compile
    my @stlf = $stl->part()->facets();

    # facets() returns an array of array-refs;
    # each of those has four array-refs -- three for the vertexes, and a fourth for the normal
    # I need to igore the normal, and transform to the proper objects, in-place
    my @facets = ();
    foreach (@stlf) {
        shift @$_; # ignore the normal vector
        my @verts = ();
        for my $v (@$_) {
            push @verts, createVertex( @$v );
        }
        push @facets, createFacet(@verts);
    }
    return createMesh( @facets );
}

=head1 TODO

=over

=item * implement inputSTL()

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