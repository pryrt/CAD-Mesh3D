#!/usr/bin/env perl
# If using Windows, see if you need to patch v0.2.1
use warnings;
use strict;

exit unless $^O eq 'MSWin32';

require CAD::Format::STL;

select STDERR;

if ( v0.2.1 ne $CAD::Format::STL::VERSION ) {
    print "CAD::Format::STL ", CAD::Format::STL->VERSION, " should be okay.\n";
    #exit;
}

print "CAD::Format::STL ", CAD::Format::STL->VERSION, " may need patching.\n";

# assuming I've already determined it needs patching, create a destination for the patch
patch('patch/STL.pm', 'lib/CAD/Format', 'STL.pm');

exit;
sub patch {
    my ($input, $outdir, $outfile) = @_;

    -w $outdir or mkdir $outdir or warn "Problem making $outdir: $!\n";
    -w $outdir or die "Cannot put patched CAD::Format::STL into $outdir/$outfile";
    my $patched = $outdir . '/' . $outfile;

    #warn "... copy $input to $patched, with some minor tweaks. :-)\n";
    open my $fhi, '<', $input or die "Cannot open '$input' for input: $!\n";
    open my $fho, '>', $patched or die "Cannot open '$patched' for output: $!\n";
    while(<$fhi>) {
        print {$fho} $_;
    }
}
