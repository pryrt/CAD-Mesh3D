#!/usr/bin/perl
# additional tests to improve object-loading test coverage

use warnings;
use strict;
use 5.010;      # for //

use Test::More;

use CAD::Mesh3D::FormatSTL;

#################################################################
# some of the original coverage:
my $stl = CAD::Mesh3D::FormatSTL->new or die "ack";
my $file = 'files/cube.stl';
{
  my $check = eval {$stl->load($file)};
  ok(not $@) or die $@;
  is($check, $stl);
}

my @parts = $stl->parts;
is(scalar(@parts), 1, 'one part');

my $part = $parts[0];
is($part->name, 'cube', 'part name');
is(scalar($part->facets), 12, 'twelve triangles');

{
  my $check = $stl->part(0);
  is($check, $part, 'got part 0');
  eval {$stl->part(1)};
  like($@, qr/no part/, 'nothing there');
  is($stl->part(-1), $part, 'got part -1');
  eval {$stl->part(-2)};
  like($@, qr/no part/, 'nothing there');
  undef $@;
}

#################################################################
# cover a coule of the sub-new deficiencies
$stl->new or die "ack2";            # create new from the current
diag __LINE__, "\t", $@;
diag "expecting error if v0.2.1-based:";
eval { CAD::Mesh3D::FormatSTL::new() };   # use function call rather than class method; this doesn't give valid blessing, but still works
diag "final message: ", $@;

#################################################################
# cover all of binary=> and ascii=>
foreach my $file ('files/cube.stl', 'files/cube_binary.stl') {
  my $stl = CAD::Mesh3D::FormatSTL->new or BAIL_OUT("->new() failed in line __".__LINE__."__");
  my $str = "load($file)";
  my $expect = $stl;
  my $check = eval {$stl->load($file)};
  #diag "$str check = " . ($check//'<undef>') . " vs expect = " . ($expect//'<undef>') . "\n";
  ok($expect ? !$@ : $@, "$str \$\@") or diag("$str >>$@<<");
  is($check, $expect, "$str value");

  $stl = CAD::Mesh3D::FormatSTL->new or BAIL_OUT("->new() failed in line __".__LINE__."__");
  $str = "load(ascii => $file)";
  $expect = ($file !~ /binary/) ? $stl : undef;
  $check = eval {$stl->load(ascii => $file)} ;
  #diag "$str check = " . ($check//'<undef>') . " vs expect = " . ($expect//'<undef>') . "\n";
  ok($expect ? !$@ : $@, "$str \$\@") or diag("$str >>$@<<");
  is($check, $expect, "$str value");

  $stl = CAD::Mesh3D::FormatSTL->new or BAIL_OUT("->new() failed in line __".__LINE__."__");
  $str = "load(binary => $file)";
  $expect = ($file =~ /binary/) ? $stl : undef;
  $check = eval {$stl->load(binary => $file)};
  #diag "$str check = " . ($check//'<undef>') . " vs expect = " . ($expect//'<undef>') . "\n";
  ok($expect ? !$@ : $@, "$str \$\@") or diag("$str >>$@<<");
  is($check, $expect, "$str value");
}

# cover too many arguments to load
{
  my $stl = CAD::Mesh3D::FormatSTL->new or BAIL_OUT("->new() failed in line __".__LINE__."__");
  my $expect = undef;
  my $check = eval {$stl->load(too => many => arguments => 1)} ;
  ok($@, "too many arguments \$\@");
  is($check, $expect, "too many arguments value");
}

# allow filehandle loading
foreach my $file ( 'files/cube.stl' ) {
    open(my $fh, '<', $file) or
      BAIL_OUT "cannot open '$file' for reading $!";

  my $stl = CAD::Mesh3D::FormatSTL->new or BAIL_OUT("->new() failed in line __".__LINE__."__");
  my $str = "handle: load($fh)";
  my $expect = $stl;
  my $check = eval {$stl->load($fh)};
  ok($expect ? !$@ : $@, "$str \$\@") or diag("$str >>$@<<");
  is($check, $expect, "$str value");
}

# non-existent file
foreach my $file ( 'files/dne.stl' ) {
  my $stl = CAD::Mesh3D::FormatSTL->new or BAIL_OUT("->new() failed in line __".__LINE__."__");
  my $str = "nonexistent: load($file)";
  my $expect = undef;
  my $check = eval {$stl->load($file)};
  ok($expect ? !$@ : $@, "$str \$\@") or diag("$str >>$@<<");
  is($check, $expect, "$str value");
}

# error: no parts
{
    my $stl = CAD::Mesh3D::FormatSTL::->new or BAIL_OUT("->new() failed in line __".__LINE__."__");
    throws_ok { $stl->part(1) } qr/file has no parts/, 'verify stl with no parts';
}


done_testing();

# vim:ts=2:sw=2:et:sta
