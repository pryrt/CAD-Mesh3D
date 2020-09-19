#!/usr/bin/env perl
# If using Windows, see if you need to patch v0.2.1
use warnings;
use strict;

exit unless $^O eq 'MSWin32';

require CAD::Format::STL;

if ( v0.2.1 ne $CAD::Format::STL::VERSION ) {
    print "CAD::Format::STL ", CAD::Format::STL->VERSION, " should be okay.\n";
    exit;
}

print "CAD::Format::STL ", CAD::Format::STL->VERSION, " may need patching.\n";

# assuming I've already determined it needs patching, create a destination for the patch
patch($INC{'CAD/Format/STL.pm'});

exit;
sub patch {
    my $input = shift;

    mkdir "lib/CAD/Format" or warn "Problem making lib/CAD/Format: $!\n";
    -w "lib/CAD/Format" or die "Cannot put patched CAD::Format::STL into lib/CAD/Format";
    my $patched = 'lib/CAD/Format/STL.pm';

    warn "... copy $input to $patched, with some minor tweaks. :-)\n";

}
