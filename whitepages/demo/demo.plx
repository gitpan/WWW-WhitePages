#!/usr/bin/perl -w
##

use strict;

use warnings;

#program version
##my $VERSION="0.1";

#For CVS , use following line
our $VERSION=sprintf("%d.%04d", q$Revision: 2008.0717 $ =~ /(\d+)\.(\d+)/);

BEGIN {

   ##debug## push( @ARGV, '--xml_ua_dmp' );
   ##debug## push( @ARGV, '--xml_request_dmp' );
   ##debug## push( @ARGV, '--xml_result_dmp' );

} ## end BEGIN

use WWW::WhitePages;

use Getopt::Long;

use Pod::Usage;

my $man = 0;
my $help = 0;

##debug##%WWW::WhitePages::opts = %WWW::WhitePages::opts; ## dummy

my %opts =
(
   'man' => \$man,
   'help|?' => \$help,
   %WWW::WhitePages::opts,

);

##debug##WWW::WhitePages::show_all_opts(); exit;

GetOptions( %opts ) || pod2usage( 2 );

pod2usage( 1 ) if ( $help );

pod2usage( '-exitstatus' => 0, '-verbose' => 2 ) if ( $man );

##debug## WWW::WhitePages::show_all_opts();
##debug## WWW::WhitePages::ML::API::show_all_opts();
##debug## WWW::WhitePages::XML::show_all_opts();
##debug## WWW::WhitePages::XML::API::show_all_opts();

WWW::WhitePages::XML::demo();

END {

} ## end END

__END__

=head1 NAME

B<whitepages/demo/demo.plx> - WhitePages Developers Interface, XML API demo.

=head1 SYNOPSIS

=over

=item It's time for you to see the WhitePages Developer API's page: L<http://developer.whitepages.com>

B<$ mkdir> ~/whitepages

B<$ mkdir> ~/whitepages/demo

=item Options;

--help|? brief help message

--man full documentation

=back

=head1 OPTIONS

=over

=item B<--help|?>

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

WhitePages XML API demo for initial testing, training and your own WWW::WhitePages Development Environment setup purpose.

=head1 SEE ALSO

I<L<WWW::WhitePages>> I<L<WWW::WhitePages::Com>> I<L<WWW::WhitePages::ML>> I<L<WWW::WhitePages::XML>> I<L<WWW::WhitePages::HTML>>

=head1 AUTHOR

 Copyright (C) 2006 Eric R. Meyers E<lt>ermeyers@adelphia.netE<gt>

=cut
