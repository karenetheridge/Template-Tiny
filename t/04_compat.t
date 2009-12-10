#!/usr/bin/perl

use strict;
use vars qw{$VAR1};
use Test::More;
use File::Spec::Functions ':ALL';
eval "require Template";
if ( $@ ) {
	plan( skip_all => 'Template Toolkit is not installed' );
}

my $SAMPLES = catdir( 't', 'samples' );
unless ( -d $SAMPLES ) {
	die("Failed to find samples directory");
}

opendir( DIR, $SAMPLES ) or die("opendir($SAMPLES): $!");
my @TEMPLATES = grep { /\.tt$/ } readdir(DIR);
closedir( DIR ) or die("closedir($SAMPLES): $!");

plan( tests => scalar(@TEMPLATES) * 6 + 1 );

my $template = Template->new(
	INCLUDE_PATH => $SAMPLES,
);
isa_ok( $template, 'Template' );





######################################################################
# Main Tests

foreach my $name ( @TEMPLATES ) {
	$name    =~ s/\.tt$//;
	my $file     = catfile( $SAMPLES, $name );
	my $tt_file  = "$file.tt";
	my $var_file = "$file.var";
	my $txt_file = "$file.txt";
	ok( -f $tt_file,  "$name: Found $tt_file"  );
	ok( -f $txt_file, "$name: Found $txt_file" );
	ok( -f $var_file, "$name: Found $var_file" );

	# Load the resources
	my $tt  = slurp($tt_file);
	my $var = slurp($var_file);
	my $txt = slurp($txt_file);
	eval $var; die $@ if $@;
	is( ref($VAR1), 'HASH', "$name: Loaded stash from file" );

	# Execute the template
	my $out = '';
	ok( $template->process( \$tt, $VAR1, \$out ), "$name: ->process returns true" );
	is( $out, $txt, "$name: Output matches expected" );
}

sub slurp {
	my $f    = shift;
	local $/ = undef;
	open( VAR, $f ) or die("open($f): $!");
	my $buffer = <VAR>;
	close VAR;
	return $buffer;
}





######################################################################
# Support Classes for object tests

SCOPE: {
	package UpperCase;

	sub foo {
		uc $_[0]->{foo};
	}

	1;
}

SCOPE: {
	package False;

	use overload 'bool' => sub { 0 };
	use overload '""'   => sub { 'Hello' };

	1;
}
