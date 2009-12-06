package Template::Tiny;

use 5.00503;
use strict;

$Template::Tiny::VERSION = '0.01';

# Parser elements
my $left  = qr/ (?: (?: \n[ \t]* )? \[\%\- | \[\% \+? ) \s* /x;
my $right = qr/ \s* (?: \+? \%\] | \-\%\] (?: [ \t]*\n )? ) /x;
my $expr  = qr/ [a-zA-Z_]\w*       /x;

sub process {
	my $stash = $_[2] || {};
	my $copy  = ${$_[1]};
	local $^W = 0;
	local $@ = '';
	$copy =~ s/
		$left ( $expr ) $right
	/
		$stash->{$1}
	/gsex;
	return $copy;
}

1;

__END__

=pod

=head1 NAME

Template::Tiny - Template Toolkit reimplemted with as little code as possible

=head1 SYNOPSIS

  Template::Tiny->process( <<'END_TEMPLATE', { foo => 'World' } );
  Hello [% foo %]!
  END_TEMPLATE

=head1 DESCRIPTION

B<WARNING: THIS MODULE IS EXPERIMENTAL AND SUBJECT TO CHANGE WITHOUT NOTICE>

B<YOU HAVE BEEN WARNED!>

B<Template::Tiny> is a reimplementation of a partial subset of the
L<Template> Toolkit, in as few lines of code as possible.

It is intended for use in light-usage, low-memory, or low-cpu templating
situations, where you may need to upgrade to the full feature set in the
future, or if you want the familiarity of TT-style templates.

It is intended to have fully-compatible template and stash usage,
with a limited by similar Perl API.

Unlike Template Toolkit, B<Template::Tiny> will process templates without a
compile phase (but despite this is still quicker, owing to heavy use of
the Perl regular expression engine.

=head2 SUPPORTED USAGE

Only the default C<[% %]> tag style is supported.

Only simple interpolations such as [% variable %] are supported.

Anything beyond this is currently out of scope

=head1 METHODS

=head2 process

  Template::Tiny->process( \$input, $vars );

The C<process> method is called to process a template. The firsts parameter
is a reference to a text string containing the template text. A reference
to a hash may be passed as the second parameter containing definitions of
template variables.

=head1 SUPPORT

Bugs should be reported via the CPAN bug tracker at

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Template-Tiny>

For other issues, or commercial enhancement or support, contact the author.

=head1 AUTHOR

Adam Kennedy E<lt>adamk@cpan.orgE<gt>

=head1 SEE ALSO

L<Config::Simple>

=head1 COPYRIGHT

Copyright 2009 Adam Kennedy.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
