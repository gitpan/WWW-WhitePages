##
## WWW::WhitePages::XML::API
##
package WWW::WhitePages::XML::API;

use strict;

use warnings;

#program version
#my $VERSION="0.1";

#For CVS , use following line
our $VERSION=sprintf("%d.%04d", q$Revision: 2008.0730 $ =~ /(\d+)\.(\d+)/);

BEGIN {

   require Exporter;

   @WWW::WhitePages::XML::API::ISA = qw(Exporter);

   @WWW::WhitePages::XML::API::EXPORT = qw(); ## export required

   @WWW::WhitePages::XML::API::EXPORT_OK =
   (
   ); ## export ok on request

} ## end BEGIN

require WWW::WhitePages::ML::API; ## NOTE: generic *ML

require AppConfig::Std;

require LWP::UserAgent; ## XML::API::ua (User Agent)

require Time::HiRes;

require Data::Dumper; ## get rid of this

require File::Spec;

require IO::File;

require Date::Format;

require XML::Dumper;

require HTTP::Status;

__PACKAGE__ =~ m/^(WWW::[^:]+)::([^:]+)(::([^:]+)){0,1}$/;

##debug##print( "API! $1::$2::$4\n" );

%WWW::WhitePages::XML::API::opts_type_args =
(
   'ido'            => $1,
   'iknow'          => $2,
   'iman'           => $4,
   'myp'            => __PACKAGE__,
   'opts'           => {},
   'opts_filename'  => {},
   'export_ok'      => [],
   'opts_type_flag' =>
   [
      @{$WWW::WhitePages::ML::API::opts_type_args{'opts_type_flag'}},
   ],
   'opts_type_numeric' =>
   [
      @{$WWW::WhitePages::ML::API::opts_type_args{'opts_type_numeric'}},
   ],
   'opts_type_string' =>
   [
      @{$WWW::WhitePages::ML::API::opts_type_args{'opts_type_string'}},
   ],

); ## this does the work with opts and optype_flag(s)

die( __PACKAGE__ ) if (
     __PACKAGE__ ne join( '::', $WWW::WhitePages::XML::API::opts_type_args{'ido'},
                                $WWW::WhitePages::XML::API::opts_type_args{'iknow'},
                                $WWW::WhitePages::XML::API::opts_type_args{'iman'}
                        )
                      );

WWW::WhitePages::ML::API::create_opts_types( \%WWW::WhitePages::XML::API::opts_type_args );

$WWW::WhitePages::XML::API::numeric_max_try = $WWW::WhitePages::ML::API::numeric_max_try;

$WWW::WhitePages::XML::API::numeric_delay_sec = $WWW::WhitePages::ML::API::numeric_delay_sec;

##debug##$WWW::WhitePages::XML::API::numeric_max_try++;
##debug##printf( STDERR "WWW::WhitePages::XML::API::numeric_max_try=%d\n", $WWW::WhitePages::XML::API::numeric_max_try );
##debug##printf( STDERR "WWW::WhitePages::ML::API::numeric_max_try=%d\n", $WWW::WhitePages::ML::API::numeric_max_try );

WWW::WhitePages::ML::API::register_all_opts( \%WWW::WhitePages::XML::API::opts_type_args );

push( @WWW::WhitePages::XML::API::EXPORT_OK,
      @{$WWW::WhitePages::XML::API::opts_type_args{'export_ok'}} );

#foreach my $x ( keys %{$WWW::WhitePages::XML::API::opts_type_args{'opts'}} )
#{
#   printf( "opts{%s}=%s\n", $x, $WWW::WhitePages::XML::API::opts_type_args{'opts'}{$x} );
#} ## end foreach

#foreach my $x ( @{$WWW::WhitePages::XML::API::opts_type_args{'export_ok'}} )
#{
#   printf( "ok=%s\n", $x );
#} ## end foreach

#foreach my $x ( @WWW::WhitePages::XML::API::EXPORT_OK )
#{
#   printf( "OK=%s\n", $x );
#} ## end foreach

##
## NOTE: Getopts hasn't set the options yet. (all flags = 0 right now)
##

$WWW::WhitePages::XML::API::ua = LWP::UserAgent->new();

$WWW::WhitePages::XML::API::url = 'http://api.whitepages.com';

$WWW::WhitePages::XML::API::today = Date::Format::time2str( '%Y%m%d', time() );

$WWW::WhitePages::XML::API::daily_max = 1500;

$WWW::WhitePages::XML::API::daily_count =
{
   'date' => $WWW::WhitePages::XML::API::today,
   'count' => 0,

};

$WWW::WhitePages::XML::API::count_file = File::Spec->catfile( $ENV{'HOME'}, '.www_whitepages_dc.xml' );

$WWW::WhitePages::XML::API::config = AppConfig::Std->new();

$WWW::WhitePages::XML::API::config_file = File::Spec->catfile( $ENV{'HOME'}, '.www_whitepages_rc' );

$WWW::WhitePages::XML::API::config->define( 'dev_key', { EXPAND   => 0 } );

##
## Config file
##
if ( ! -e $WWW::WhitePages::XML::API::config_file )
{
   system( "echo 'dev_key = ' > $WWW::WhitePages::XML::API::config_file " );

} ## end if

if ( -e $WWW::WhitePages::XML::API::config_file &&
     ( ( ( stat( $WWW::WhitePages::XML::API::config_file ) )[2] & 36 ) != 0 )
   )
{
   die( "Your config file $WWW::WhitePages::XML::API::config_file is readable by others!\n" );

} ## end if

if ( -f $WWW::WhitePages::XML::API::config_file )
{
   $WWW::WhitePages::XML::API::config->file( $WWW::WhitePages::XML::API::config_file )
   || die( "reading $WWW::WhitePages::XML::API::config_file\n" );

} ## end if

##
## Count file
##
if ( -e $WWW::WhitePages::XML::API::count_file )
{
   $WWW::WhitePages::XML::API::daily_count = XML::Dumper::xml2pl( $WWW::WhitePages::XML::API::count_file );

}
else
{
   XML::Dumper::pl2xml( $WWW::WhitePages::XML::API::daily_count, $WWW::WhitePages::XML::API::count_file );

} ## end if

if ( $WWW::WhitePages::XML::API::daily_count->{'date'} ne $WWW::WhitePages::XML::API::today )
{
   $WWW::WhitePages::XML::API::daily_count->{'date'} = $WWW::WhitePages::XML::API::today;
   $WWW::WhitePages::XML::API::daily_count->{'count'} = 0;

   XML::Dumper::pl2xml( $WWW::WhitePages::XML::API::daily_count, $WWW::WhitePages::XML::API::count_file );

} ## end if

if ( $WWW::WhitePages::XML::API::daily_count->{'count'} >= $WWW::WhitePages::XML::API::daily_max )
{
   ##maybe##print "maximum daily limit reached\n";

} ## end if

##
## End
##
END {

} ## end END

##
## WWW::WhitePages::XML::API::show_all_opts
##
sub WWW::WhitePages::XML::API::show_all_opts
{
   WWW::WhitePages::ML::API::show_all_opts( \%WWW::WhitePages::XML::API::opts_type_args );

} ## end sub WWW::WhitePages::XML::API::show_all_opts

##
## WWW::WhitePages::XML::API::request_dumper
##
sub WWW::WhitePages::XML::API::request_dumper
{
   my $request = shift;

   my $ima = 'request'; ## dumper

   my $filename = $WWW::WhitePages::XML::API::opts_type_args{'opts_filename'}{"${ima}_dmp"};

   my $fh = IO::File->new();

   $fh->open( "+>${filename}.txt" ) ||
   die "opening: ${filename}.txt: $!\n";

   $fh->print( Data::Dumper->Dump( [ $request ], [ $ima ] ) );

   $fh->close();

} ## end sub WWW::WhitePages::XML::API::request_dumper

##
## WWW::WhitePages::XML::API::result_dumper
##
sub WWW::WhitePages::XML::API::result_dumper
{
   my $result = shift;

   my $ima = 'result'; ## dumper

   my $filename = $WWW::WhitePages::XML::API::opts_type_args{'opts_filename'}{"${ima}_dmp"};

   my $fh = IO::File->new();

   ##
   ## .xml
   ##
   $fh->open( "+>${filename}.xml" ) ||
   die "opening: ${filename}.xml: $!\n";

   $fh->print( $result->content() );

   $fh->close();

   ##
   ## .txt
   ##
   $fh->open( "+>${filename}.txt" ) ||
   die "opening: ${filename}.txt: $!\n";

   $fh->print( Data::Dumper->Dump( [ $result ], [ $ima ] ) );

   $fh->close();

} ## end sub WWW::WhitePages::XML::API::result_dumper

##
## WWW::WhitePages::XML::API::ua_request
##
sub WWW::WhitePages::XML::API::ua_request
{
   my $request = shift;

   my $result = undef;

   my $ua_info = 'sprintf( "WWW::WhitePages::XML::API::ua_request failed: %s \$itry=%dof%d\n",
                            $result->status_line(), $itry-1, $max_try
                         )';

   my ( $itry, $max_try ) = ( 1, $WWW::WhitePages::XML::API::numeric_max_try );

   while ( $itry++ <= $max_try )
   {
      last if ( $WWW::WhitePages::XML::API::daily_count->{'count'} >= $WWW::WhitePages::XML::API::daily_max );

      $WWW::WhitePages::XML::API::daily_count->{'count'}++;

      XML::Dumper::pl2xml( $WWW::WhitePages::XML::API::daily_count, $WWW::WhitePages::XML::API::count_file );
      Time::HiRes::sleep( $WWW::WhitePages::XML::API::numeric_delay_sec );

      $result = $WWW::WhitePages::XML::API::ua->request( $request );

      if ( $result->is_success() )
      {
         last;

      }
      else
      {
         if ( $result->code() == HTTP::Status::RC_FORBIDDEN() )
         {
            $WWW::WhitePages::XML::API::daily_count->{'count'}--;

            XML::Dumper::pl2xml( $WWW::WhitePages::XML::API::daily_count, $WWW::WhitePages::XML::API::count_file );
            die( "forbidden usage at the moment\n" );

         } ## end if

      } ## end if

      print( STDERR eval( $ua_info ) ) if ( $itry > $max_try );

   } ## end while

   if ( $WWW::WhitePages::XML::API::daily_count->{'count'} >= $WWW::WhitePages::XML::API::daily_max )
   {
      die( "maximum daily limit reached\n" );

   } ## end if

   WWW::WhitePages::XML::API::request_dumper( $request ) if ( $WWW::WhitePages::XML::API::flag_request_dmp );

   if ( $WWW::WhitePages::XML::API::flag_ua_dmp )
   {
      printf( STDERR "---- request ----\n%s\n", $request->as_string() );

      printf( STDERR "---- result  ----\n%s\n", $result->as_string() );

   } ## end if

   if ( ! $result->is_success() )
   {
      printf( STDERR "Failed: %s\n", $result->status_line() );

   }
   else
   {
      WWW::WhitePages::XML::API::result_dumper( $result ) if ( $WWW::WhitePages::XML::API::flag_result_dmp );

   } ## end if

   return ( $result );

} ## end sub WWW::WhitePages::XML::API::ua_request

sub WWW::WhitePages::XML::API::find_person
{
   my @query = @_;

   my $request = HTTP::Request->new();

   my $uri = URI->new( $WWW::WhitePages::XML::API::url . '/find_person/1.0/' );

   push( @query, 'api_key' );

   push( @query, $WWW::WhitePages::XML::API::config->dev_key() );

   $uri->query_form( @query );

   $request->method( 'GET' );

   $uri =~ s/[&]/;/g;

   $request->uri( $uri );

   return( $request );

} ## end sub WWW::WhitePages::XML::API::find_person

sub WWW::WhitePages::XML::API::reverse_phone
{
   my @query = @_;

   my $request = HTTP::Request->new();

   my $uri = URI->new( $WWW::WhitePages::XML::API::url . '/reverse_phone/1.0/' );

   push( @query, 'api_key' );

   push( @query, $WWW::WhitePages::XML::API::config->dev_key() );

   $uri->query_form( @query );

   $request->method( 'GET' );

   $uri =~ s/[&]/;/g;

   $request->uri( $uri );

   return( $request );

} ## end sub WWW::WhitePages::XML::API::reverse_phone

sub WWW::WhitePages::XML::API::reverse_address
{
   my @query = @_;

   my $request = HTTP::Request->new();

   my $uri = URI->new( $WWW::WhitePages::XML::API::url . '/reverse_address/1.0/' );

   push( @query, 'api_key' );

   push( @query, $WWW::WhitePages::XML::API::config->dev_key() );

   $uri->query_form( @query );

   $request->method( 'GET' );

   $uri =~ s/[&]/;/g;

   $request->uri( $uri );

   return( $request );

} ## end sub WWW::WhitePages::XML::API::reverse_address

1;
__END__ ## package WWW::WhitePages::XML::API

=head1 NAME

WWW::WhitePages::XML::API - How to Interface with WhitePages using HTTP Protocol and XML-RPC API.

=head1 SYNOPSIS

require WWW::WhitePages::XML::API;

my $request = WWW::WhitePages::XML::API::find_person( 'firstname' => 'Larry',
                                                      'lastname' => 'Wall'
                                                    );

my $result = WWW::WhitePages::XML::API::ua_request( $request );

my $xml_tree = XML::TreeBuilder->new();

$xml_tree->parse( $result->content() );

$xml_tree->eof();

## DO SOMETHING HERE ##

$xml_tree->delete();

=head1 OPTIONS

=over

--xml_* options:

opts_type_flag:

=over

=item --xml_ua_dmp

user agent transaction dump

=item --xml_request_dmp

transaction request dump

=item --xml_result_dmp

transaction result dump

=back

opts_type_numeric:

=over

=item --xml_max_try

Maximum number of tries

=item --xml_delay_sec

Seconds of delay between tries

=back

opts_type_string:

=over

   NONE

=back

=back

=head1 DESCRIPTION

XML::API stands for XML Application Programming Interface

See:	http://developer.whitepages.com

=head2	Demo

=over

WWW::WhitePages::XML::demo()

=back

=head2 find_person search method

=over

See: http://developer.whitepages.com/docs/Methods/find_person

my $request = WWW::WhitePages::XML::API::find_person( 'firstname' => 'Larry',
                                                      'lastname'  => 'Wall',
                                                    );

my $result = WWW::WhitePages::XML::API::ua_request( $request );

my $xml_tree = XML::TreeBuilder->new();

$xml_tree->parse( $result->content() );

$xml_tree->eof();

## DO SOMETHING HERE ##

$xml_tree->delete();

=back

=head2 reverse_phone search method

=over

See: http://developer.whitepages.com/docs/Methods/reverse_phone

my $request = WWW::WhitePages::XML::API::reverse_phone( 'phone' => '7178968092' );

my $result = WWW::WhitePages::XML::API::ua_request( $request );

my $xml_tree = XML::TreeBuilder->new();

$xml_tree->parse( $result->content() );

$xml_tree->eof();

## DO SOMETHING HERE ##

$xml_tree->delete();

=back

=head2 reverse_address search method

=over

See: http://developer.whitepages.com/docs/Methods/reverse_address

my $request = WWW::WhitePages::XML::API::reverse_address( 'house'  => '105',
                                                          'street' => 'Wind Hill Dr',
                                                          'city'   => 'Halifax',
                                                          'state'  => 'PA',
                                                          'zip'    => '17032',
                                                        );

my $result = WWW::WhitePages::XML::API::ua_request( $request );

my $xml_tree = XML::TreeBuilder->new();

$xml_tree->parse( $result->content() );

$xml_tree->eof();

## DO SOMETHING HERE ##

$xml_tree->delete();

=back

=head1 SEE ALSO

I<L<WWW::WhitePages>> I<L<WWW::WhitePages::ML::API>> I<L<WWW::WhitePages::XML>>

=head1 AUTHOR

 Copyright (C) 2008 Eric R. Meyers E<lt>Eric.R.Meyers@gmail.comE<gt>

=cut

