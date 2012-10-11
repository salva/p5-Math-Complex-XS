package Math::Complex::XS;

our $VERSION = '0.01';

use 5.010;
use strict;
use warnings;
use Exporter qw(import);

require XSLoader;
XSLoader::load('Math::Complex::XS', $VERSION);

our %EXPORT_TAGS = ( trig => [qw( pi
                                  tan
                                  csc cosec sec cot cotan
                                  asin acos atan
                                  acsc acosec asec acot acotan
                                  sinh cosh tanh
                                  csch cosech sech coth cotanh
                                  asinh acosh atanh
                                  acsch acosech asech acoth acotanh
                               )],
                     pi    => [qw(pi pi2 pi4 pip2 pip4 Inf)]
                   );

our @EXPORT_OK = @{$EXPORT_TAGS{pi}};

our @EXPORT = ( qw( i Re Im rho theta arg
                    sqrt log ln
                    log10 logn cbrt root
                    cplx cplxe
                    atan2 ),
                @{$EXPORT_TAGS{trig}} );

use overload
	'+'	=> \&_plus,
	'-'	=> \&_minus,
	'*'	=> \&_multiply,
	'/'	=> \&_divide,
	'**'	=> \&_power,
	'=='	=> \&_numeq,
	'<=>'	=> \&_spaceship,
	'neg'	=> \&_negate,
	'~'	=> \&_conjugate,
	'abs'	=> \&abs,
	'sqrt'	=> \&sqrt,
	'exp'	=> \&exp,
	'log'	=> \&log,
	'sin'	=> \&sin,
	'cos'	=> \&cos,
	'tan'	=> \&tan,
	'atan2'	=> \&atan2,
        '""'    => \&_stringify;


sub pi   () { 4 * CORE::atan2(1, 1) }

sub pi2  () { 2    * pi }
sub pi4  () { 4    * pi }
sub pip2 () { 0.5  * pi }
sub pip4 () { 0.25 * pi }

1;

__END__

=head1 NAME

Math::Complex::XS - Math::Complex replacement written in XS

=head1 SYNOPSIS

  use Math::Complex::XS;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Math::Complex::XS, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Salvador Fandiño, E<lt>salva@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Salvador Fandiño

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
