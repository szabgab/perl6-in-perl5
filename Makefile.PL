use 5.008005;
use strict;
use inc::Module::Install 0.77;





#####################################################################
# Normal Boring Commands

# NOTE: Core modules that aren't dual-life should always have a version of 0

name           'Inline-Rakudo';
license        'perl';
author         'Gabor Szabo';
all_from       'lib/Inline/Rakudo.pm';
requires       'perl'                     => '5.008005';
requires       'FindBin'                  => 0;
requires       'Carp'                     => 0;
requires       'Cwd'                      => 0;
test_requires  'Test::More'               => '0.47';


# homepage       '';
# bugtracker     '';
repository     'http://github.com/szabgab/perl6-in-perl5/';

WriteAll;
