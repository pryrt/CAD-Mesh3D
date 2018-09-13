#!/usr/bin/perl -l
use Data::IEEE754::Tools ':all';

print convertToInternalHexString(1);                                # 3FF0000000000000

# CR
print "CR";
print my $v=convertFromInternalHexString( '3FF00D0000000000' );     # 1.003173828125
print convertToDecimalString($v);
print convertToInternalHexString(1.003173828125);                   # +0d1.0031738281250000p+0000

# LF
print "LF";
print my $v=convertFromInternalHexString( '3FF00A0000000000' );     # 1.00244140625
print convertToDecimalString($v);
print convertToInternalHexString(1.00244140625);                    # +0d1.0024414062500000p+0000

# CRLF
print "CRLF";
print my $v=convertFromInternalHexString( '3FF00D0A00000000' );     # 1.0031833648681641
print convertToDecimalString($v);                                   # +0d1.0031833648681641p+0000
print convertToInternalHexString(1.0031833648681641);
print convertToInternalHexString(1.0031833648681640);
print convertToInternalHexString(1.0031833648681639);
print convertToInternalHexString(1.0031833648681642);
print unpack('d>' => pack 'H*' => '3FF00D0A00000000');              # alternate, which is perl 5.010-compatible, without requiring external module