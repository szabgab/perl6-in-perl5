use 5.008005;
use strict;
use inc::Module::Install 0.77;

if (not $ENV{PARROT_DIR}) {
	warn "Need to have PARROT_DIR defined.\n";
	exit 0;
}
if (not $ENV{RAKUDO_DIR}) {
	warn "Need to have RAKUDO_DIR defined.\n";
	exit 0;
}

if (not -e "$ENV{PARROT_DIR}/ext/Parrot-Embed/blib/lib/Parrot/Embed.pm") {
	warn "Need to have Parrot::Embed compiled.\n";
	exit 0;
}

unshift @INC, (
	"$ENV{PARROT_DIR}/ext/Parrot-Embed/blib/lib",
	"$ENV{PARROT_DIR}/ext/Parrot-Embed/blib/arch",
);


#####################################################################
# Normal Boring Commands

name           'Inline-Rakudo';
license        'perl';
author         'Gabor Szabo';
all_from       'lib/Inline/Rakudo.pm';
requires       'perl'                     => '5.008005';
requires       'FindBin'                  => 0;
requires       'Carp'                     => 0;
requires       'Cwd'                      => 0;

# for now we leave them out as we don't want to trigger the download of Parrot from CPAN
#requires       'Parrot::Embed'            => 0;
#requires       'Parrot::Interpreter'      => 0;

test_requires  'Test::More'               => '0.47';


# homepage       '';
# bugtracker     '';
repository     'http://github.com/szabgab/perl6-in-perl5/';

WriteAll;
