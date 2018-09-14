#!/usr/bin/perl
use warnings;
use strict;
use 5.010;      # for pack 'd>', and //

use Test::More 'no_plan';

use CAD::Format::STL;

{
    my $v = CAD::Format::STL->VERSION;
    my $p = $INC{'CAD/Format/STL.pm'} // '<INC error>';
    ok($v, "using CAD::Format::STL $v from '$p'\n");
}

note "\n";
note "Floats with 0x0D (CR), 0x0A (LF), or both (CRLF) embedded in the bigendian representation";
sub hex2float { unpack 'f>' => pack 'H*' => shift }
note sprintf '    %-4s => %.16f', 'CR',   my $fcr   = hex2float('3F810D00');
note sprintf '    %-4s => %.16f', 'LF',   my $flf   = hex2float('3F820A00');
note sprintf '    %-4s => %.16f', 'CRLF', my $fcrlf = hex2float('3F830D0A');
note sprintf '    %-4s => %.16f', 'LFCR', my $flfcr = hex2float('3F840A0D');
note "\n";

my $stl = CAD::Format::STL->new;
isa_ok($stl, 'CAD::Format::STL');

my $part = $stl->add_part('cube');
isa_ok($part, 'CAD::Format::STL::part');
is($part->name, 'cube', 'part name');

$part->add_facets(
  [[0,0,1], [$fcr,$flf,2], [$fcrlf,$flfcr,3]],
);
is(scalar($part->facets), 1, 'one triangles');

# write binary STL to an in-memory file (ie, string reference)
{
  my $string;
  open(my $ofh, '>', \$string) or die "could not open in-memory file";
  $stl->save(binary => $ofh);
  ok($string, 'wrote to binary filehandle');
  #diag $string;
  #diag map { sprintf '%02X ', ord $_} split //, $string;
  is index($string, qq/\x00\x0D\x81\x3F/), 108, 'includes little-endian 0x3F810D00 at right file offset';
  is index($string, qq/\x00\x0A\x82\x3F/), 112, 'includes little-endian 0x3F820A00 at right file offset';
  is index($string, qq/\x0A\x0D\x83\x3F/), 120, 'includes little-endian 0x3F830D0A at right file offset';
  is index($string, qq/\x0D\x0A\x84\x3F/), 124, 'includes little-endian 0x3F840A0D at right file offset';
}

done_testing();

# vim:ts=2:sw=2:et:sta
