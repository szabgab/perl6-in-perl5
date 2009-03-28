use strict;
use warnings;

use Test::More;
my $tests;
plan tests => $tests;

use Inline::Rakudo;

my $rakudo = Inline::Rakudo->rakudo;
isa_ok($rakudo, 'Inline::Rakudo');
BEGIN { $tests += 1; }

{
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
	BEGIN { $tests += 3; }
}

{
	my $code = <<'END_CODE';
sub len($str) {
	return $str.chars;
}
END_CODE

	is($rakudo->run_code($code), 'len', 'function definition returns last function name');
	is($rakudo->run_sub('len', 124), 3, 'function call with parameter successful');
	is($rakudo->run_sub('len', "abc"), 3, 'function call with parameter successful');
	is($rakudo->run_sub('len', '$xyz'), 4, 'function call with parameter successful');

	BEGIN { $tests += 4; }
}

