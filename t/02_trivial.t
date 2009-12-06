#!/usr/bin/perl

use strict;
use Test::More tests => 1;
use Template::Tiny ();

sub process {
	my $stash    = shift;
	my $input    = shift;
	my $expected = shift;
	my $message  = shift || 'Template processed ok';
	my $output   = Template::Tiny->process( \$input, $stash );
	is( $output, $expected, $message );
}





######################################################################
# Main Tests

process( { foo => 'World' }, <<'END_TEMPLATE', <<'END_EXPECTED', 'Trivial ok' );
Hello [% foo %]!
END_TEMPLATE
Hello World!
END_EXPECTED
