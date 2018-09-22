# NAME

CAD::Mesh3D - Create and Manipulate 3D Vertices and Meshes and output for 3D printing

# SYNOPSIS

    use CAD::Mesh3D qw(:create :output);
    my $vect = createVertex();
    my $tri  = createFacet($v1, $v2, $v3);
    my $mesh = createMesh();
    #addToMesh($mesh, $tri, ...);    # not implemented yet
    push @$mesh, $tri;               # manual method of addToMesh()
    ...
    outputStl($mesh, $filehandle_or_filename, $true_for_ascii_false_for_binary);

# DESCRIPTION

A framework to create and manipulate 3D vertices and meshes, suitable for generating STL files
(or other similar formats) for 3D printing.

A **Mesh** is the container for the surface of the shape or object being generated.  The surface is broken down
into locally-flat pieces known as **Facet**s.  Each Facet is a triangle made from exactly points, called
**Vertex**es or vertices.  Each Vertex is made up of three x, y, and z **coordinate**s, which are just
floating-point values to represent the position in 3D space.

# SEE ALSO

- [CAD::Format::STL](https://metacpan.org/pod/CAD::Format::STL) - includes both input and output from STL (ASCII and BINARY)

    The unaddressed Windows bug was killer for me.  I possibly would have offered
    to co-maintain and implement the bug fix, but I also wanted the possibility
    of adding sub-modules to implment other input/output formats -- in which case, the naming
    scheme is wrong.

# TODO

- Input from STL
- Plug-and-Play
    - enableFormat( _Format_ )
    - enableFormat( _Format_ => _module_, _inputFunc_, _outputFunc_ )

        Require/import the sub-module.  Maybe also callable via the `use CAD::Mesh3D qw/Format1 Format2/`.

            enableFormat( 'STL' );  # assumes CAD::Mesh3D::STL, inputStl() and outputStl()
            enableFormat( 'PNG' => 'CAD::Mesh3D::Images', 'pngInput', 'pngOutput'); # explicit about module name and function names

        _Module_ should be the name of the module.  It should default to
        'CAD::Mesh3D::_Format_'.

        _inputFunc_ should either be the name (relative to the given module) or a
        coderef of an appropriate function.  You can use `\&inputFunctionNotAvail`
        to give an error message if someone tries to use an invalid

    - input( _format_, _file_, \[_options_\])

        Inputs the mesh file given that format.

        Not all will have an input function (for example, cannot import a mesh from an image)

    - output( _format_, _file_, \[_options_\])

        Output the mesh to the appropriate format.

    - \\&inputFunctionNotAvail

        Pass this to the `enableFormat()` function

# AUTHOR

Peter C. Jones `<petercj AT cpan DOT org>`

<div>
    <a href="https://github.com/pryrt/CAD-Mesh3D/issues"><img src="https://img.shields.io/github/issues/pryrt/CAD-Mesh3D.svg" alt="issues" title="issues"></a>
    <a href="https://ci.appveyor.com/project/pryrt/CAD-Mesh3D"><img src="https://ci.appveyor.com/api/projects/status/bc5jt6b2bjmpig5x?svg=true" alt="appveyor build status" title="appveyor build status"></a>
    <a href="https://travis-ci.org/pryrt/CAD-Mesh3D"><img src="https://travis-ci.org/pryrt/CAD-Mesh3D.svg?branch=master" alt="travis build status" title="travis build status"></a>
    <a href='https://coveralls.io/github/pryrt/CAD-Mesh3D?branch=master'><img src='https://coveralls.io/repos/github/pryrt/CAD-Mesh3D/badge.svg?branch=master' alt='Coverage Status' title='Coverage Status' /></a>
</div>

# COPYRIGHT

Copyright (C) 2017,2018 Peter C. Jones

# LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See [http://dev.perl.org/licenses/](http://dev.perl.org/licenses/) for more information.
