#!/usr/bin/env perl
# If using Windows, see if you need to patch v0.2.1
use warnings;
use strict;

exit unless $^O eq 'MSWin32';

require CAD::Format::STL;

select STDERR;

if ( v0.2.1 lt $CAD::Format::STL::VERSION ) {
    print "CAD::Format::STL ", CAD::Format::STL->VERSION, " should be okay.\n";
    exit;
}

my $dest = shift @ARGV or die "no destination file\n";

print "Patching CAD::Format::STL ", CAD::Format::STL->VERSION, " using \"$dest\".\n";

# assuming I've already determined it needs patching, create a destination for the patch
patch('patch/STL.pm', $dest);
print qx{ls -latrR $dest};

# needs to be in both lib and blib/lib
patch('patch/STL.pm', "blib/$dest");
print qx{ls -latrR blib/$dest};

exit;
sub patch {
    my ($input, $outfile) = @_;

    (my $outdir = $outfile) =~ s/STL.pm$//;
    $outfile =~ s{^.*/}{};

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
