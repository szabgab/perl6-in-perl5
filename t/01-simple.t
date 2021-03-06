use strict;
use warnings;

use Test::More;

plan tests => 4;

use Inline::Rakudo;

my $rakudo = Inline::Rakudo->rakudo;
isa_ok($rakudo, 'Inline::Rakudo');

my $code  = <<'END_CODE';
sub f($n) {
	return $n+1;
}
END_CODE
is($rakudo->run_code($code), 'f', 'function definition returns function name');

is($rakudo->run_code('f(41)'), 42, 'function call successful');


eval {
	Inline::Rakudo->new;
};
like $@, qr/You should not call new twice/, 'second new() dies';
