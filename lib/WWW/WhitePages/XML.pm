##
## WWW::WhitePages::XML
##
package WWW::WhitePages::XML;

use strict;

use warnings;

#program version
#my $VERSION="0.1";

#For CVS , use following line
our $VERSION=sprintf("%d.%04d", q$Revision: 2008.0730 $ =~ /(\d+)\.(\d+)/);

BEGIN {

   require Exporter;

   @WWW::WhitePages::XML::ISA = qw(Exporter);

   @WWW::WhitePages::XML::EXPORT = qw(); ## export required

   @WWW::WhitePages::XML::EXPORT_OK =
   (

   ); ## export ok on request

} ## end BEGIN

require WWW::WhitePages::XML::API;

require XML::TreeBuilder;

require XML::Dumper;

%WWW::WhitePages::XML::opts =
(
);

__PACKAGE__ =~ m/^(WWW::[^:]+)((::([^:]+)){1}(::([^:]+)){0,1}){0,1}$/g;

##debug##print( "XML! $1::$4::$6\n" );

%WWW::WhitePages::XML::opts_type_args =
(
   'ido'            => $1,
   'iknow'          => $4,
   'iman'           => 'aggregate',
   'myp'            => __PACKAGE__,
   'opts'           => \%WWW::WhitePages::XML::opts,
   'opts_filename'  => {},
   'export_ok'      => [],
   'urls' =>
   {
   },
   'opts_type_flag' =>
   [
   ],
   'opts_type_numeric' =>
   [
   ],
   'opts_type_string' =>
   [
   ],

);

die( __PACKAGE__ ) if (
     __PACKAGE__ ne join( '::', $WWW::WhitePages::XML::opts_type_args{'ido'},
                                $WWW::WhitePages::XML::opts_type_args{'iknow'},
                                #$WWW::WhitePages::XML::opts_type_args{'iman'}
                        )
                      );

WWW::WhitePages::ML::API::create_opts_types( \%WWW::WhitePages::XML::opts_type_args );

##debug##WWW::WhitePages::ML::API::show_all_opts( \%WWW::WhitePages::XML::opts_type_args );

WWW::WhitePages::XML::register_all_opts( \%WWW::WhitePages::XML::API::opts_type_args );

#push( @WWW::WhitePages::XML::EXPORT_OK,
#      @{$WWW::WhitePages::XML::opts_type_args{'export_ok'}} );

END {

} ## end END

##
## WWW::WhitePages::XML::register_all_opts
##
sub WWW::WhitePages::XML::register_all_opts
{
   my $opts_type_args = shift || \%WWW::WhitePages::XML::API::opts_type_args;

   while ( my ( $opt_tag, $opt_val ) = each( %{$opts_type_args->{'opts'}} ) )
   {
      $WWW::WhitePages::XML::opts_type_args{'opts'}{$opt_tag} = $opt_val;

   } ## end while

   while ( my ( $opt_tag, $opt_val ) = each( %{$opts_type_args->{'urls'}} ) )
   {
      $WWW::WhitePages::XML::opts_type_args{'urls'}{$opt_tag} = $opts_type_args->{'urls'}{$opt_tag};

   } ## end while

} ## end sub WWW::WhitePages::XML::register_all_opts

##
## WWW::WhitePages::XML::show_all_opts
##
sub WWW::WhitePages::XML::show_all_opts
{
   my $opts_type_args = shift || \%WWW::WhitePages::XML::opts_type_args;

   WWW::WhitePages::ML::API::show_all_opts( $opts_type_args );

} ## end sub WWW::WhitePages::XML::show_all_opts

##
## WWW::WhitePages::XML::demo
##
sub WWW::WhitePages::XML::demo
{
   my $request = undef;

   my $result = undef;

   my $xml_tree = undef;

   $request = WWW::WhitePages::XML::API::find_person( 'firstname' => 'Larry',
                                                      'lastname'  => 'Wall',
                                                    );

   ##debug##print $request->as_string() . "\n";

   $result = WWW::WhitePages::XML::API::ua_request( $request );

   ##debug##print $result->as_string() . "\n";

   my $control =
   {
      'level' => 0,
      'xml' => [ $result->content() ],
      'order_out' => [],
      'columns_out' => [],
   };

   WWW::WhitePages::XML::parse_find_person_to_csv( $control );

   $request = WWW::WhitePages::XML::API::reverse_phone( 'phone' => '7178968092' );

   ##debug##print $request->as_string() . "\n";

   $result = WWW::WhitePages::XML::API::ua_request( $request );

   ##debug##print $result->as_string() . "\n";

   $xml_tree = XML::TreeBuilder->new();

   $xml_tree->parse( $result->content() );

   $xml_tree->eof();

   $xml_tree->delete();

   $request = WWW::WhitePages::XML::API::reverse_address( 'house'  => '105',
                                                          'street' => 'Wind Hill Dr',
                                                          'city'   => 'Halifax',
                                                          'state'  => 'PA',
                                                          'zip'    => '17032',
                                                        );

   ##debug##print $request->as_string() . "\n";

   $result = WWW::WhitePages::XML::API::ua_request( $request );

   ##debug##print $result->as_string() . "\n";

   $xml_tree = XML::TreeBuilder->new();

   $xml_tree->parse( $result->content() );

   $xml_tree->eof();

   $xml_tree->delete();

} ## end sub WWW::WhitePages::XML::demo

##
## WWW::WhitePages::XML::parse_find_person_to_csv
##
sub WWW::WhitePages::XML::parse_find_person_to_csv
{
   my $control = shift;

   my $xml_tree = XML::TreeBuilder->new();

   $xml_tree->parse( $control->{'xml'}->[$control->{'level'}] );

   $xml_tree->eof();

   my $wp_result = $xml_tree->find_by_tag_name( 'wp:result' );

   if ( ( $wp_result->attr( 'wp:type' ) eq 'success' ) &&
        ( $wp_result->attr( 'wp:code' ) eq 'Found Data' )
      )
   {
      @{$control->{'order_out'}} = qw(Type Lastname Firstname House Street City State Zip Phone);

      @{$control->{'columns_out'}} = ();

      my @columns_out = undef;

      my %map_out = ();

      for ( my $i = 0; $i <= $#{$control->{'order_out'}}; $i++ )
      {
         $map_out{$control->{'order_out'}->[$i]} = $i;

      } ## end for

      #my $wp_recordrange = $xml_tree->find_by_tag_name( 'wp:recordrange' );
      #my $wp_firstrecord = $wp_recordrange->attr( 'wp:firstrecord' );
      #my $wp_lastrecord =  $wp_recordrange->attr( 'wp:lastrecord' );

      foreach my $wp_listing ( $xml_tree->find_by_tag_name( 'wp:listing' ) )
      {
         foreach my $wp_person ( $wp_listing->find_by_tag_name( 'wp:person' ) )
         {
            for ( my $i = 0; $i <= $#{$control->{'order_out'}}; $i++ )
            {
               $columns_out[$i] = '';

            } ## end for

            my $wp_firstname = $wp_person->find_by_tag_name( 'wp:firstname' );

            $columns_out[$map_out{'Firstname'}] = $wp_firstname->content()->[0];

            $columns_out[$map_out{'Firstname'}] = '' if ( ! defined( $columns_out[$map_out{'Firstname'}] ) );

            my $wp_middlename = $wp_person->find_by_tag_name( 'wp:middlename' );

            if ( defined( $wp_middlename ) && defined( $wp_middlename->content() ) )
            {
               $columns_out[$map_out{'Firstname'}] .= ' ' . $wp_middlename->content()->[0];

            } ## end if

            my $wp_lastname = $wp_person->find_by_tag_name( 'wp:lastname' );

            $columns_out[$map_out{'Lastname'}] = $wp_lastname->content()->[0];

            push( @{$control->{'columns_out'}}, [@columns_out] );

         } ## end foreach

         #foreach my $wp_business ( $wp_listing->find_by_tag_name( 'wp:business' ) )
         #{
         #   ##debug##printf( "businessname=%s\n", $wp_business->find_by_tag_name( 'wp:businessname' )->content()->[0] );
         #} ## end foreach

         foreach my $wp_phone ( $wp_listing->find_by_tag_name( 'wp:phone' ) )
         {
            for( my $i = 0; $i <= $#{$control->{'columns_out'}}; $i++ )
            {
               my $wp_fullphone = $wp_phone->find_by_tag_name( 'wp:fullphone' );

               $control->{'columns_out'}->[$i][$map_out{'Phone'}] = $wp_fullphone->content()->[0];

               $control->{'columns_out'}->[$i][$map_out{'Phone'}] =~ s/^[(](\d\d\d)[)] (\d\d\d)[-](\d\d\d\d)/$1$2$3/;

               $control->{'columns_out'}->[$i][$map_out{'Type'}] = $wp_phone->attr( 'wp:type' );

            } ## end for

         } ## end foreach

         foreach my $wp_address ( $wp_listing->find_by_tag_name( 'wp:address' ) )
         {
            for( my $i = 0; $i <= $#{$control->{'columns_out'}}; $i++ )
            {
               my $wp_house = $wp_address->find_by_tag_name( 'wp:house' );

               if ( defined( $wp_house ) )
               {
                  $control->{'columns_out'}->[$i][$map_out{'House'}] = $wp_house->content()->[0];

               } ## end if

               my $wp_street = $wp_address->find_by_tag_name( 'wp:street' );

               if ( defined( $wp_street ) )
               {
                  $control->{'columns_out'}->[$i][$map_out{'Street'}] = $wp_street->content()->[0];

               } ## end if

               my $wp_city = $wp_address->find_by_tag_name( 'wp:city' );

               if ( defined( $wp_city ) )
               {
                  $control->{'columns_out'}->[$i][$map_out{'City'}] = $wp_city->content()->[0];

               } ## end if

               my $wp_state = $wp_address->find_by_tag_name( 'wp:state' );

               if ( defined( $wp_state ) )
               {
                  $control->{'columns_out'}->[$i][$map_out{'State'}] = $wp_state->content()->[0];

               } ## end if

               my $wp_zip = $wp_address->find_by_tag_name( 'wp:zip' );

               if ( defined( $wp_zip ) )
               {
                  $control->{'columns_out'}->[$i][$map_out{'Zip'}] = $wp_zip->content()->[0];

               } ## end if

               my $wp_zip4 = $wp_address->find_by_tag_name( 'wp:zip4' );

               if ( defined( $wp_zip4 ) )
               {
                  $control->{'columns_out'}->[$i][$map_out{'Zip'}] .= $wp_zip4->content()->[0];

               } ## end if

            } ## end for

         } ## end foreach

      } ## end foreach

   } ## end if

   $xml_tree->delete();

} ## end sub WWW::WhitePages::XML::parse_find_person_to_csv

1;
__END__ ## package WWW::WhitePages::XML

=head1 NAME

WWW::WhitePages::XML - General Extensible Markup Language capabilities go in here.

=head1 SYNOPSIS

require WWW::WhitePages::XML;

WWW::WhitePages::XML::demo();

-OR-

require WWW::WhitePages::XML;

require Text::CSV;

my $request = WWW::WhitePages::XML::API::find_person( 'firstname' => 'Larry',
                                                      'lastname'  => 'Wall',
                                                    );

my $result = WWW::WhitePages::XML::API::ua_request( $request );

my $control =
{
   'level' => 0,
   'xml' => [ $result->content() ],
   'order_out' => [],
   'columns_out' => [],
};

WWW::WhitePages::XML::parse_find_person_to_csv( $control );

my $csv_out = Text::CSV->new();

my $status_out = $csv_out->combine( $control->{'order_out'} );

print $csv_out->string() . "\n"; ## prints header

for ( my $i = 0; $i <= $#{$control->{'columns_out'}}; $i++ )
{
   $status_out = $csv_out->combine( @{$control->{'columns_out'}->[$i]} );

   print $csv_out->string() . "\n"; prints data

} ## end for

=head1 OPTIONS

NONE

=head1 DESCRIPTION

=over

=item WWW::WhitePages::XML::demo();

This is a simple demo, better read than run.

=item WWW::WhitePages::XML::parse_find_person_to_csv( $control );

Parses find_person XML into tabular array of data.

=back

=head1 SEE ALSO

I<L<WWW::WhitePages>> I<L<WWW::WhitePages::XML::API>>

=head1 AUTHOR

 Copyright (C) 2008 Eric R. Meyers E<lt>Eric.R.Meyers@gmail.comE<gt>

=cut

