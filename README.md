# NAME

App::Generate3dMesh - Create and Manipulate 3D Vertices and Meshes and output for 3D printing

# SYNOPSIS

    use App::Generate3dMesh qw(:create :output);
    my $vect = createVertex();
    my $tri  = createFacet($v1, $v2, $v3);
    my $mesh = createMesh();
    #addToMesh($mesh, $tri, ...);    # not implemented yet
    push @$mesh, $tri;               # manual method of addToMesh()
    ...
    outputStl($mesh, $filehandle_or_filename, $true_for_ascii_false_for_binary);

# DESCRIPTION

A framework to create and manipulate 3D vertices and meshes, suitable for generating STL files
for 3D printing.

A **Mesh** is the container for the surface of the shape or object being generated.  The surface is broken down
into locally-flat pieces known as **Facet**s.  Each Facet is a triangle made from exactly points, called
**Vertex**es or vertices.  Each Vertex is made up of three x, y, and z **coordinate**s, which are just
floating-point values to represent the position in 3D space.

# AUTHOR

Peter C. Jones `<petercj AT cpan DOT org>`

<div>
    <a href="https://github.com/pryrt/App-Generate3dMesh/issues"><img src="https://img.shields.io/github/issues/pryrt/App-Generate3dMesh.svg" alt="issues" title="issues"></a>
    <a href="https://ci.appveyor.com/project/pryrt/App-Generate3dMesh"><img src="https://ci.appveyor.com/api/projects/status/r4o672g0ua4dvt11?svg=true" alt="appveyor build status" title="appveyor build status"></a>
    <a href="https://travis-ci.org/pryrt/App-Generate3dMesh"><img src="https://travis-ci.org/pryrt/App-Generate3dMesh.svg?branch=master" alt="travis build status" title="travis build status"></a>
    <a href='https://coveralls.io/github/pryrt/App-Generate3dMesh?branch=master'><img src='https://coveralls.io/repos/github/pryrt/App-Generate3dMesh/badge.svg?branch=master' alt='Coverage Status' title='Coverage Status' /></a>
</div>

# COPYRIGHT

Copyright (C) 2017,2018 Peter C. Jones

# LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See [http://dev.perl.org/licenses/](http://dev.perl.org/licenses/) for more information.
