##
## WWW::WhitePages::ML::API
##
package WWW::WhitePages::ML::API; ## All Markup Language API

use strict;

use warnings;

#program version
##my $VERSION="0.1";

#For CVS , use following line
our $VERSION=sprintf("%d.%04d", q$Revision: 2008.0718 $ =~ /(\d+)\.(\d+)/);

BEGIN {

   require Exporter;

   @WWW::WhitePages::ML::API::ISA = qw(Exporter);

   @WWW::WhitePages::ML::API::EXPORT = qw(); ## export required

   @WWW::WhitePages::ML::API::EXPORT_OK =
   (

   ); ## export ok on request

} ## end BEGIN

__PACKAGE__ =~ m/^(WWW::[^:]+)::([^:]+)(::([^:]+)){0,1}$/;

##debug## print( "API! $1::$2::$4\n" );

##debug## exit;

require FindBin;

require Time::HiRes;

%WWW::WhitePages::ML::API::opts =
(
);

%WWW::WhitePages::ML::API::opts_type_args =
(
   'ido'            => $1,
   'iknow'          => $2,
   'iman'           => $4,
   'myp'            => __PACKAGE__,
   'opts'           => \%WWW::WhitePages::ML::API::opts,
   'urls'           => {},
   'opts_filename'  => {},
   'export_ok'      => [],
   'opts_type_flag' =>
   [
      'ua_dmp',
      'request_dmp',
      'result_dmp',
   ],
   'opts_type_numeric' =>
   [
      'max_try',
      'delay_sec',

   ],
   'opts_type_string' =>
   [
   ],

); ## this does the work with opts and optype_flag(s)

die( __PACKAGE__ ) if (
     __PACKAGE__ ne join( '::', $WWW::WhitePages::ML::API::opts_type_args{'ido'},
                                $WWW::WhitePages::ML::API::opts_type_args{'iknow'},
                                $WWW::WhitePages::ML::API::opts_type_args{'iman'}
                        )
                      );

##debug####don't##WWW::WhitePages::ML::API::create_opts_types( \%WWW::WhitePages::ML::API::opts_type_args );

$WWW::WhitePages::ML::API::numeric_max_try = 5;

$WWW::WhitePages::ML::API::numeric_delay_sec = 0.5;

##debug####don't##WWW::WhitePages::ML::register_all_opts( \%WWW::WhitePages::ML::API::opts_type_args );

##don't##push( @WWW::WhitePages::ML::API::EXPORT_OK,
##don't##      @{$WWW::WhitePages::ML::API::opts_type_args{'export_ok'}} );

#foreach my $x ( keys %{$WWW::WhitePages::ML::API::opts_type_args{'opts'}} )
#{
#   printf( "opts{%s}=%s\n", $x, $WWW::WhitePages::ML::API::opts_type_args{'opts'}{$x} );
#} ## end foreach

#foreach my $x ( @{$WWW::WhitePages::ML::API::opts_type_args{'export_ok'}} )
#{
#   printf( "ok=%s\n", $x );
#} ## end foreach

#foreach my $x ( @WWW::WhitePages::ML::API::EXPORT_OK )
#{
#   printf( "OK=%s\n", $x );
#} ## end foreach

##
## NOTE: Getopts hasn't set the options yet. (all flags = 0 right now)
##

END {

} ## end END

##
## WWW::WhitePages::ML::API::create_opts_types
##
sub WWW::WhitePages::ML::API::create_opts_types
{
   my $opts_type_args = shift || \%WWW::WhitePages::ML::API::opts_type_args;

   return if ( $opts_type_args->{'myp'} eq __PACKAGE__ );

   my $Bin_dir = $FindBin::Bin;

   ##
   ## opts_type_flag: has filename and %d and init=0
   ##
   foreach my $opt_type ( @{$opts_type_args->{'opts_type_flag'}} )
   {
      my $opt_myp = $opts_type_args->{'myp'};

      my $opt_tag = "flag_$opt_type"; ## flag_x

      my $opt_ml_tag = lc( $opts_type_args->{'iknow'} ) . '_' . $opt_type; ## ml_x

      my $opt_url = "${opt_myp}::${opt_tag}"; ## __PACKAGE__::flag_x

      $opts_type_args->{'urls'}{$opt_ml_tag} = $opt_url;

      ##
      ## specifying filenames without filename suffix
      ##
      $opts_type_args->{'opts_filename'}{$opt_type} =  ## path/whitepages_ml_x
                        $Bin_dir. '/' . lc( $opts_type_args->{'ido'} ) . '_' . $opt_ml_tag;

      push( @{$opts_type_args->{'export_ok'}}, $opt_tag );

      my $mycmd =
      "\n".
      '$'.$opt_url.' = 0;' ."\n".
      "\n".
      '$opts_type_args->{\'opts\'}{"'.$opt_ml_tag.'"} = \\$'.$opt_url.';' ."\n".
      "\n".
      '##' ."\n".
      '## '.$opt_url.'_prn' ."\n".
      '##' . "\n" .
      'sub '.$opt_url.'_prn' ."\n".
      '{' ."\n".
      '   printf( "'.$opt_url.'=%d\\n", $'.$opt_url.' );' ."\n".
      "\n".
      '} ## end sub '.$opt_url.'_prn' ."\n".
      "\n";

      ##debug## print( $mycmd );

      eval $mycmd || print $mycmd;

      ##debug##      eval $opt_url.'_prn();';

   } ## end foreach

   ##
   ## opts_type_numeric: has no filename and %d and =i and init=0
   ##
   foreach my $opt_type ( @{$opts_type_args->{'opts_type_numeric'}} )
   {
      my $opt_myp = $opts_type_args->{'myp'};

      my $opt_tag = "numeric_$opt_type"; ## numeric_x

      my $opt_ml_tag = lc( $opts_type_args->{'iknow'} ) . '_' . $opt_type; ## ml_x

      my $opt_url = "${opt_myp}::${opt_tag}"; ## __PACKAGE__::numeric_x

      $opts_type_args->{'urls'}{$opt_ml_tag} = $opt_url;

      push( @{$opts_type_args->{'export_ok'}}, $opt_tag );

      my $mycmd =
      "\n".
      '$'.$opt_url.' = 0;' ."\n".
      "\n".
      '$opts_type_args->{\'opts\'}{"'.$opt_ml_tag.'=i"} = \\$'.$opt_url.';' ."\n".
      "\n".
      '##' ."\n".
      '## '.$opt_url.'_prn' ."\n".
      '##' . "\n" .
      'sub '.$opt_url.'_prn' ."\n".
      '{' ."\n".
      '   printf( "'.$opt_url.'=%d\\n", $'.$opt_url.' );' ."\n".
      "\n".
      '} ## end sub '.$opt_url.'_prn' ."\n".
      "\n";

      ##debug## print( $mycmd );

      eval $mycmd || print $mycmd;

      ##debug##      eval $opt_url.'_prn();';

   } ## end foreach

   ##
   ## opts_type_string: has no filename and %s and =s and init=undef
   ##
   foreach my $opt_type ( @{$opts_type_args->{'opts_type_string'}} )
   {
      my $opt_myp = $opts_type_args->{'myp'};

      my $opt_tag = "string_$opt_type"; ## string_x

      my $opt_ml_tag = lc( $opts_type_args->{'iknow'} ) . '_' . $opt_type; ## ml_x

      my $opt_url = "${opt_myp}::${opt_tag}"; ## __PACKAGE__::string_x

      $opts_type_args->{'urls'}{$opt_ml_tag} = $opt_url;

      push( @{$opts_type_args->{'export_ok'}}, $opt_tag );

      my $mycmd =
      "\n".
      '$'.$opt_url.' = undef;' ."\n".
      "\n".
      '$opts_type_args->{\'opts\'}{"'.$opt_ml_tag.'=s"} = \\$'.$opt_url.';' ."\n".
      "\n".
      '##' ."\n".
      '## '.$opt_url.'_prn' ."\n".
      '##' . "\n" .
      'sub '.$opt_url.'_prn' ."\n".
      '{' ."\n".
      '   if ( defined( $'.$opt_url.' ) )' ."\n".
      '   {'. "\n".
      '      printf( "'.$opt_url.'=%s\\n", $'.$opt_url.' );' ."\n".
      "\n".
      '   }' ."\n".
      '   else' ."\n".
      '   {' ."\n".
      '      print ( "'.$opt_url.'=undef\n" );' ."\n".
      "\n".
      '   } ## end if' ."\n".
      "\n".
      '} ## end sub '.$opt_url.'_prn' ."\n".
      "\n";

      ##debug## print( $mycmd );

      eval $mycmd || print $mycmd;

      ##debug##      eval $opt_url.'_prn();';

   } ## end foreach

} ## end sub WWW::WhitePages::ML::API::create_opts_types

##
## WWW::WhitePages::ML::API::register_all_opts
##
sub WWW::WhitePages::ML::API::register_all_opts
{
   my $opts_type_args = shift || \%WWW::WhitePages::ML::API::opts_type_args;

   return if ( $opts_type_args->{'myp'} eq __PACKAGE__ );

   ##my $myp = $opts_type_args->{'myp'};

   while ( my ( $opt_tag, $opt_val ) = each( %{$opts_type_args->{'opts'}} ) )
   {
      ##
      ## used for Getopts
      ##
      ##eval ( '$'.$myp.'::opts_type_args{\'opts\'}{'.$opt_tag.'} = '.$opt_val . ';' );
      $WWW::WhitePages::ML::API::opts_type_args{'opts'}{$opt_tag} = $opt_val;

   } ## end while

   while ( my ( $opt_tag, $opt_val ) = each( %{$opts_type_args->{'urls'}} ) )
   {
      ##
      ## used for ML::API
      ##
      ##eval ( '$'.$myp.'::opts_type_args{\'urls\'}{'.$opt_tag.'} = '.$opts_type_args->{'urls'}{$opt_tag}.';' );
      $WWW::WhitePages::ML::API::opts_type_args{'urls'}{$opt_tag} = $opts_type_args->{'urls'}{$opt_tag};

   } ## end while

} ## end sub WWW::WhitePages::ML::API::register_all_opts

##
## WWW::WhitePages::ML::API::opts_type_flag_prn
##
sub WWW::WhitePages::ML::API::opts_type_flag_prn
{
   my $opts_type_args = shift || \%WWW::WhitePages::ML::API::opts_type_args;

   ##debug##   print "$opts_type\n";

   foreach my $opt_tag ( sort @{$opts_type_args->{'opt_type_flag'}} )
   {
      printf( "opt_tag=%s\n", $opt_tag );

      printf( "opt_tag_url=%s\n", $opts_type_args->{'urls'}{$opt_tag} );

      $opt_tag =~ s/[=][is]$//;

      eval $opts_type_args->{'urls'}{$opt_tag} . '_prn();';

   } ## end foreach

} ## end sub WWW::WhitePages::ML::API::opts_type_flag_prn

##
## WWW::WhitePages::ML::API::show_all_opts
##
sub WWW::WhitePages::ML::API::show_all_opts
{
   my $opts_type_args = shift || \%WWW::WhitePages::ML::API::opts_type_args;

   ##debug##print caller() . " is caller\n";

   foreach my $opt_tag ( sort keys %{$opts_type_args->{'urls'}} )
   {
      eval $opts_type_args->{'urls'}{$opt_tag} . '_prn();';

   } ## end foreach

} ## end sub WWW::WhitePages::ML::API::show_all_opts

1;
__END__ ## package WWW::WhitePages::ML::API

=head1 NAME

WWW::WhitePages::ML::API - How to Interface with WhitePages in general.

=head1 SYNOPSIS

=head1 OPTIONS

=head1 DESCRIPTION

ML::API stands for Generic Markup Language -- Application Programming Interface

=head1 SEE ALSO

I<L<WWW::WhitePages>> I<L<WWW::WhitePages::XML::API>>

=head1 AUTHOR

 Copyright (C) 2008 Eric R. Meyers E<lt>Eric.R.Meyers@gmail.comE<gt>

=cut
