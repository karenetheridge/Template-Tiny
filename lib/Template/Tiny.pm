package Template::Tiny;

# Load overhead: 40k

use 5.00503;
use strict;

$Template::Tiny::VERSION = '0.10';

# Evaluatable expression
my $EXPR = qr/ [a-z_][\w.]* /xs;

# Opening [% tag including whitespace chomping rules
my $LEFT = qr/
	(?:
		(?: (?:^|\n) [ \t]* )? \[\%\-
		|
		\[\% \+?
	) \s*
/xs;

# Closing %] tag including whitespace chomping rules
my $RIGHT  = qr/
	\s* (?:
		\+? \%\]
		|
		\-\%\] (?: [ \t]* \n )?
	)
/xs;

# Preparsing run for nesting tags
my $PREPARSE = qr/
	$LEFT ( IF | UNLESS | FOREACH ) \s+
		(
			(?: \S+ \s+ IN \s+ )?
		\S+ )
	$RIGHT
	(?!
		.*?
		$LEFT (?: IF | UNLESS | FOREACH ) \b
	)
	( .*? )
	(?:
		$LEFT ELSE $RIGHT
		(?!
			.*?
			$LEFT (?: IF | UNLESS | FOREACH ) \b
		)
		( .+? )
	)?
	$LEFT END $RIGHT
/xs;

# Condition set
my $CONDITION = qr/
	\[\%\s
		( ([IUF])\d+ ) \s+
		(?:
			([a-z]\w*) \s+ IN \s+
		)?
		( $EXPR )
	\s\%\]
	( .*? )
	(?:
		\[\%\s \1 \s\%\]
		( .+? )
	)?
	\[\%\s \1 \s\%\]
/xs;

sub new {
	bless { @_[1..$#_] }, $_[0];
}

sub process {
	my $self  = shift;
	my $copy  = ${shift()};
	my $stash = shift || {};

	local $@  = '';
	local $^W = 0;

	# Preprocess to establish unique matching tag sets
	my $id = 0;
	1 while $copy =~ s/
		$PREPARSE
	/
		my $tag = substr($1, 0, 1) . ++$id;
		"\[\% $tag $2 \%\]$3\[\% $tag \%\]"
		. (defined($4) ? "$4\[\% $tag \%\]" : '');
	/sex;

	# Process down the nested tree of conditions
	$self->_process( $stash, $copy );
}

sub _process {
	my ($self, $stash, $text) = @_;

	$text =~ s/
		$CONDITION
	/
		($2 eq 'F')
			? $self->_foreach($stash, $3, $4, $5)
			: eval {
				$2 eq 'U'
				xor
				!! # Force boolification
				$self->_expression($stash, $4)
			}
				? $self->_process($stash, $5)
				: $self->_process($stash, $6)
	/gsex;

	# Resolve expressions
	$text =~ s/
		$LEFT ( $EXPR ) $RIGHT
	/
		eval {
			$self->_expression($stash, $1)
			. '' # Force stringification
		}
	/gsex;

	# Trim the document
	$text =~ s/^\s*(.+?)\s*\z/$1/s if $self->{TRIM};

	return $text;
}

# Special handling for foreach
sub _foreach {
	my ($self, $stash, $term, $expr, $text) = @_;

	# Resolve the expression
	my $list = $self->_expression($stash, $expr);
	unless ( ref $list eq 'ARRAY' ) {
		return '';
	}

	# Iterate
	return join '', map {
		$self->_process( { %$stash, $term => $_ }, $text )
	} @$list;
}

# Evaluates a stash expression
sub _expression {
	my $cursor = $_[1];
	my @path   = split /\./, $_[2];
	foreach ( @path ) {
		# Support for private keys
		return undef if substr($_, 0, 1) eq '_';

		# Split by data type
		my $type = ref $cursor;
		if ( $type eq 'ARRAY' ) {
			return '' unless /^(?:0|[0-9]\d*)\z/;
			$cursor = $cursor->[$_];
		} elsif ( $type eq 'HASH' ) {
			$cursor = $cursor->{$_};
		} elsif ( $type ) {
			$cursor = $cursor->$_();
		} else {
			return '';
		}
	}
	return $cursor;
}

1;

__END__

=pod

=head1 NAME

Template::Tiny - Template Toolkit reimplemented in as little code as possible

=head1 SYNOPSIS

  my $template = Template::Tiny->new(
      TRIM => 1,
  );
  
  $template->process( <<'END_TEMPLATE', { foo => 'World' } );
  Hello [% foo %]!
  END_TEMPLATE

=head1 DESCRIPTION

B<WARNING: THIS MODULE IS EXPERIMENTAL AND SUBJECT TO CHANGE WITHOUT NOTICE>

B<YOU HAVE BEEN WARNED!>

B<Template::Tiny> is a reimplementation of a partial subset of the
L<Template> Toolkit in as few lines of code as possible.

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

Both the [%+ +%] style explicit whitespace and the [%- -%] style explicit
chomp are support, although the [%+ +%] version is unneeded as Template::Tiny
does not support default-enabled PRE_CHOMP or POST_CHOMP.

Variable expressions in the form foo.bar.baz are supported.

Appropriate simple behaviours for ARRAY reference, HASH reference and objects
are supported, but not "VMethods" such as array lengths.

IF, ELSE and UNLESS conditions are supported, but only with simple foo.bar.baz
conditions.

Support for looping is available, in the most simple [% FOREACH item IN list %]
form.

All four IF/ELSE/UNLESS/FOREACH control structures are able to be nested to
arbitrary depth.

The treatment of C<_private> hash and method keys is compatible with Template
Toolkit, returning null or false rather than the actual content of the hash key
or method.

Anything beyond this is currently out of scope

=head1 METHODS

=head2 new

  my $template = Template::Tiny->new(
      TRIM => 1,
  );

The C<new> constructor is provided for compatibility with Template Toolkit.

The only parameter it currently supports is C<TRIM> (which removes leading
and trailing whitespace from processed templates).

Additional parameters can be provided without error, but will be ignored.

=head2 process

  $template->process( \$input, $vars );

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

Copyright 2009 - 2010 Adam Kennedy.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
