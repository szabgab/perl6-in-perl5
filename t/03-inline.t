use strict;
use warnings;

use Test::More;

plan tests => 3;

use Inline::Rakudo qw(f);

my $rakudo = Inline::Rakudo->rakudo;
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

is(f(41), 42, 'function call with parameter successful');


