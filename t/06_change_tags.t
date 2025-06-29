#!/usr/bin/perl

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}
use Test::More tests => 1;
use Template::Tiny ();

sub process {
	my $stash    = shift;
	my $input    = shift;
	my $expected = shift;
	my $message  = shift || 'Template processed ok';
	my $output   = '';
	Template::Tiny->new( start_tag => '<%', end_tag => '%>' )->process( \$input, $stash, \$output );
	is( $output, $expected, $message );
}





######################################################################
# Main Tests

process( { foo => 'World' }, <<'END_TEMPLATE', <<'END_EXPECTED', 'Use non-default tags ok' );
Hello <% foo %>!
END_TEMPLATE
Hello World!
END_EXPECTED
