use strict;
use warnings;

use Test::More;

plan tests => 4;

use Inline::Rakudo;

my $rakudo = Inline::Rakudo->new;
isa_ok($rakudo, 'Inline::Rakudo');

my $code  = <<'END_CODE';
sub f($n) {
	return $n+1;
}

sub g($a, $b, $c) {
	return $a+$b+$c;
}

END_CODE
is($rakudo->run_code($code), 'g', 'function definition returns last function name');

is($rakudo->run_sub('f', 41), 42, 'function call with parameter successful');

is($rakudo->run_sub('g', 1, 2, 3), 6, 'function call with 3 params is ok');


