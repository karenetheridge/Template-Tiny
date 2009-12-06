#!/usr/bin/perl

use strict;
use vars qw{$VAR1};
use Test::More;
use File::Spec::Functions ':ALL';
use Template::Tiny ();

my $SAMPLES = catdir( 't', 'samples' );
unless ( -d $SAMPLES ) {
	die("Failed to find samples directory");
}

opendir( DIR, $SAMPLES ) or die("opendir($SAMPLES): $!");
my @TEMPLATES = grep { /\.tt$/ } readdir(DIR);
closedir( DIR ) or die("closedir($SAMPLES): $!");

plan( tests => scalar(@TEMPLATES) * 5 );





######################################################################
# Main Tests

foreach my $template ( @TEMPLATES ) {
	$template    =~ s/\.tt$//;
	my $file     = catfile( $SAMPLES, $template );
	my $tt_file  = "$file.tt";
	my $var_file = "$file.var";
	my $txt_file = "$file.txt";
	ok( -f $tt_file,  "$template: Found $tt_file"  );
	ok( -f $txt_file, "$template: Found $txt_file" );
	ok( -f $var_file, "$template: Found $var_file" );

	# Load the resources
	my $tt  = slurp($tt_file);
	my $var = slurp($var_file);
	my $txt = slurp($txt_file);
	eval $var; die $@ if $@;
	is( ref($VAR1), 'HASH', "$template: Loaded stash from file" );

	# Execute the template
	my $out = Template::Tiny->process( \$tt, $VAR1 );
	is( $out, $txt, "$template: Output matches expected" );
}

sub slurp {
	my $f    = shift;
	local $/ = undef;
	open( VAR, $f ) or die("open($f): $!");
	my $buffer = <VAR>;
	close VAR;
	return $buffer;
}
