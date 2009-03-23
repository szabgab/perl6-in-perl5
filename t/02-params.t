use strict;
use warnings;

use Test::More;

plan tests => 3;

use Inline::Rakudo;

my $rakudo = Inline::Rakudo->new;
isa_ok($rakudo, 'Inline::Rakudo');

my $code  = <<'END_CODE';
sub f($n) {
	return $n+1;
}
END_CODE
is($rakudo->run_code($code), 'f', 'function definition returns function name');

is($rakudo->run_sub('f', 41), 42, 'function call with parameter successful');

