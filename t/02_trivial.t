#!/usr/bin/perl

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}
use Test::More tests => 2;
use Template::Tiny ();
use Capture::Tiny qw(capture);

sub process {
	my $stash    = shift;
	my $input    = shift;
	my $expected = shift;
	my $message  = shift || 'Template processed ok';
	Template::Tiny->new->process( \$input, $stash, \my $output );
	is( $output, $expected, $message );
	my ( $stdout, $stderr) = capture {
		Template::Tiny->new->process( \$input, $stash );
	};
	is( $stdout, $expected, $message.' (to STDOUT)' );
}





######################################################################
# Main Tests

process( { foo => 'World' }, <<'END_TEMPLATE', <<'END_EXPECTED', 'Trivial ok' );
Hello [% foo %]!
END_TEMPLATE
Hello World!
END_EXPECTED
