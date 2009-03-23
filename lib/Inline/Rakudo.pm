package Inline::Rakudo;
use strict;
use warnings;

# Needs the following environment variables:
# RAKUDO_DIR needs to point to the Rakudo directory
# PARROT_DIR needs to point to the directory where parrot was checked out
# export LD_LIBRARY_PATH=$PARROT_DIR/blib/lib/

# cwd still needs to be PARROT_DIR or I get the following error:
#"load_bytecode" couldn't find file 'PCT.pbc'
#current instr.: '' pc 743 (src/classes/Object.pir:20)
#called from Sub 'myperl6' pc 3 (EVAL_1:3)

# Before running I had to build Parrot::Embed:
# cd $ENV{PARROT_DIR}/ext/Parrot-Embed/
# perl Build.PL
# perl Build
# perl Build test

sub new  {
	my ($class) = @_;
	my $self = bless {}, $class;
	chdir $ENV{PARROT_DIR};
	$self->{parrot} = load_rakudo();
	return $self;
}

sub load_rakudo {
	die "need PARROT_DIR" if not $ENV{PARROT_DIR};
	unshift @INC, (
			"$ENV{PARROT_DIR}/ext/Parrot-Embed/blib/lib",
			"$ENV{PARROT_DIR}/ext/Parrot-Embed/blib/arch",
			);
			
	require Parrot::Embed;
	my $interp = Parrot::Interpreter->new;

	my $load_rakudo =<<"END_PIR";
.sub load_rakudo
    load_bytecode '$ENV{RAKUDO_DIR}/perl6.pbc'
.end
END_PIR
	my $eval   = $interp->compile( $load_rakudo );
	my $rakudo = $interp->find_global('load_rakudo');
	my $pmc    = $rakudo->invoke( 'PS', '' );
	return $interp;
}

sub run_code {
	my ($self, $code) = @_;

	my $perl6 =<<"END_PIR";
.sub myperl6
        .param string    in_string
        .local pmc compiler, invokable
        .local string result
        compiler = compreg 'Perl6'
        invokable = compiler.'compile'(in_string)
        result = invokable()
        .return(result)
.end
END_PIR


	my $eval = $self->{parrot}->compile( $perl6 );
	my $foo = $self->{parrot}->find_global('myperl6');
	my $pmc = $foo->invoke( 'PS', $code );
	return $pmc->get_string();
}


1;
