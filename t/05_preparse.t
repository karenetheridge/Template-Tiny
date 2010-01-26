#!/usr/bin/perl

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}
use Test::More tests => 3;
use Template::Tiny ();

sub preparse {
	my $template = shift;
	my $expected = shift;
	my $message  = shift || 'Template preparsed ok';
	Template::Tiny->new->_preparse( \$template );
	is( $template, $expected, $message );
}





######################################################################
# Main Tests

preparse( <<'END_TEMPLATE', <<'END_EXPECTED', 'Simple IF' );
foo
[% IF foo %]
foobar
[% END %]
bar
END_TEMPLATE
foo
[% I1 foo %]
foobar
[% I1 %]
bar
END_EXPECTED

preparse( <<'END_TEMPLATE', <<'END_EXPECTED', 'Simple UNLESS' );
foo
[% UNLESS foo %]
foobar
[% END %]
bar
END_TEMPLATE
foo
[% U1 foo %]
foobar
[% U1 %]
bar
END_EXPECTED

preparse( <<'END_TEMPLATE', <<'END_EXPECTED', 'Simple FOREACH' );
foo
[% FOREACH element IN lists %]
foobar
[% END %]
bar
END_TEMPLATE
foo
[% F1 element IN lists %]
foobar
[% F1 %]
bar
END_EXPECTED
