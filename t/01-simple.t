#!/usr/bin/perl 
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Inline::Rakudo;

my $rakudo = Inline::Rakudo->new;
#print $rakudo->run_code('"world".say'). "\n";

my $code  = <<'END_CODE';
sub f($n) {
	return $n+1;
}
END_CODE
$rakudo->run_code($code);

print $rakudo->run_code('f(41)'). "\n";

