package Inline::Rakudo;
use strict;
use warnings;
use 5.008005;

=head1 NAME

Inline::Rakudo - allow to use Rakudo from Perl 5 code

=head1 SYNOPSIS

=head2 OOP way

  use Inline::Rakudo;

  my $rakudo = Inline::Rakudo->rakudo;
  my $code  = <<'END_CODE';
  sub f($n) {
    return $n+1;
  }
  END_CODE
  
  # compile the code
  $rakudo->run_code($code);   

  # run the code (the answer should be 42)
  my $answer = $rakudo->run_code('f(41)');
  
  # provide the parameters separately
  my $other = $rakudo->run_sub('f', 41);
  
=head2 Inline way

  use Inline::Rakudo qw(f);

  my $code  = <<'END_CODE';
  sub f($n) {
    return $n+1;
  }

  sub g($a, $b, $c) {
    return $a+$b+$c;
  }

  END_CODE
  
  # compile
  $rakudo->run_code($code);

  # call it as a regular function
  my $answer = f(41);


  # this does not exist as we have not imported it
  g(1, 2, 3); 


=head1 SETUP

Needs the following environment variables:
RAKUDO_DIR needs to point to the Rakudo directory
PARROT_DIR needs to point to the directory where parrot was checked out
export LD_LIBRARY_PATH=$PARROT_DIR/blib/lib/

cwd still needs to be PARROT_DIR or I get the following error:

  "load_bytecode" couldn't find file 'PCT.pbc'
  current instr.: '' pc 743 (src/classes/Object.pir:20)
  called from Sub 'myperl6' pc 3 (EVAL_1:3)

 Before running I had to build Parrot::Embed:
 
  cd $ENV{PARROT_DIR}/ext/Parrot-Embed/
  perl Build.PL
  perl Build
  perl Build test

=cut


use Carp ();

my $rakudo;

our $VERSION = '0.01';

sub import {
	my ($class, @args) = @_;
	foreach my $sub (@args) {
		no strict 'refs';
		my $callpkg = caller(0);
		*{$callpkg . '::' . $sub} = sub { Inline::Rakudo->rakudo->run_sub($sub, @_) };
	}
}

sub new  {
	my ($class) = @_;
	Carp::croak("You should not call new twice") if $rakudo;
	my $self = bless {}, $class;
	chdir $ENV{PARROT_DIR};
	$self->{parrot} = load_rakudo();
	return $self;
}

sub rakudo {
	my ($class) = @_;
	$rakudo ||= $class->new;
	return $rakudo;
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

sub run_sub {
	my ($self, $sub, @args) = @_;
	my $code = "$sub(" . join(",", @args) . ")";
	my $res = $self->run_code($code);
	return $res;
}

=head1 COPYRIGHT

Copyright 2009 Gabor Szabo gabor@szabgab.com

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl 5 itself.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.


=cut

1;
