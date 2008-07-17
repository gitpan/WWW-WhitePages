##
## WWW::WhitePages
##
package WWW::WhitePages;

use strict;

use warnings;

#program version
#my $VERSION="0.1";

#For CVS , use following line
our $VERSION = sprintf("%d.%04d", "Revision: 2008.0718" =~ /(\d+)\.(\d+)/);

BEGIN {

   require Exporter;

   @WWW::WhitePages::ISA = qw(Exporter);

   @WWW::WhitePages::EXPORT = qw(); ## export required

   @WWW::WhitePages::EXPORT_OK =
   (

   ); ## export ok on request

} ## end BEGIN

require WWW::WhitePages::XML;

require File::Basename;

require Date::Format;

require XML::Dumper;

require Text::CSV;

require IO::File;

require IO::Zlib;

require Text::CSV;

require File::Spec;

require FindBin;

%WWW::WhitePages::opts =
(
); ## General Public

__PACKAGE__ =~ m/^(WWW::[^:]+)((::([^:]+))(::([^:]+))){0,1}$/g;

##debug##print( "BL! $1::$4::$6\n" );

%WWW::WhitePages::opts_type_args =
(
   'ido'            => $1,
   'iknow'          => 'bl',
   'iman'           => 'aggregate',
   'myp'            => __PACKAGE__,
   'opts'           => \%WWW::WhitePages::opts,
   'opts_filename'  => {},
   'export_ok'      => [],
   'urls'           =>
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
     __PACKAGE__ ne join( '::', $WWW::WhitePages::opts_type_args{'ido'},
                                #$WWW::WhitePages::opts_type_args{'iknow'},
                                #$WWW::WhitePages::opts_type_args{'iman'}
                        )
                      );

WWW::WhitePages::ML::API::create_opts_types( \%WWW::WhitePages::opts_type_args );

##debug## WWW::WhitePages::ML::API::show_all_opts( \%WWW::WhitePages::opts_type_args );

WWW::WhitePages::register_all_opts( \%WWW::WhitePages::XML::opts_type_args );

#push( @WWW::WhitePages::EXPORT_OK,
#      @{$WWW::WhitePages::opts_type_args{'export_ok'}} );

END {

} ## end END

##
## WWW::WhitePages::register_all_opts
##
sub WWW::WhitePages::register_all_opts
{
   my $opts_type_args = shift || \%WWW::WhitePages::XML::opts_type_args;

   while ( my ( $opt_tag, $opt_val ) = each( %{$opts_type_args->{'opts'}} ) )
   {
      $WWW::WhitePages::opts_type_args{'opts'}{$opt_tag} = $opt_val;

   } ## end while

   while ( my ( $opt_tag, $opt_val ) = each( %{$opts_type_args->{'urls'}} ) )
   {
      $WWW::WhitePages::opts_type_args{'urls'}{$opt_tag} = $opts_type_args->{'urls'}{$opt_tag};

   } ## end while

} ## end sub WWW::WhitePages::register_all_opts

##
## WWW::WhitePages::show_all_opts
##
sub WWW::WhitePages::show_all_opts
{
   my $opts_type_args = shift || \%WWW::WhitePages::opts_type_args;

   WWW::WhitePages::XML::show_all_opts( $opts_type_args );

} ## end sub WWW::WhitePages::XML::show_all_opts

##
## Crs to wp
##
sub WWW::WhitePages::crs2wp
{
   chdir $FindBin::Bin;

   my $fh_in = IO::Zlib->new( 'crs2wp.txt.gz', 'rb' );

   my $fh_out = IO::Zlib->new( 'wp.csv.gz', 'wb9' );

   my $csv_in = Text::CSV->new();

   my $csv_out = Text::CSV->new();

   my $status_in = undef;

   my $status_out = undef;

   my @order_in = undef;

   my @order_out = qw(Group Control Lastname Firstname House Street City State Zip NeedAddress);

   my %map_in = ();

   my %map_out = ();

   for ( my $i = 0; $i <= $#order_out; $i++ )
   {
      $map_out{$order_out[$i]} = $i;

   } ## end for

   my @columns_in = undef;

   my @columns_out = undef;

   my %seen = ();

   while( my $line_in = <$fh_in> )
   {
      $line_in =~ s/^\s+//;

      if ( $. == 1 )
      {
         $status_in = $csv_in->parse( $line_in );

         @order_in = $csv_in->fields();

         for ( my $i = 0; $i <= $#order_in; $i++ )
         {
            $map_in{$order_in[$i]} = $i;

         } ## end for

         $status_out = $csv_out->combine( @order_out );

         print $fh_out $csv_out->string() . "\n";

      }
      else
      {
         next if ( $line_in =~ m/^\s*$/ );

         next if ( $line_in =~ m/^["][[]/ );

         $status_in = $csv_in->parse( $line_in );

         @columns_in = $csv_in->fields();

         for ( my $i = 0; $i <= $#columns_in; $i++ )
         {
            $columns_in[$i] =~ s/^\s+//;

            $columns_in[$i] =~ s/\s+$//;

         } ## end for

         for ( my $i = 0; $i <= $#order_out; $i++ )
         {
            $columns_out[$i] = '';

         } ## end for

         next if ( defined( $seen{$columns_in[$map_in{'[DB_NO]'}]} ) );

         $seen{$columns_in[$map_in{'[DB_NO]'}]} = 1;

         $columns_out[$map_out{'Group'}] = $columns_in[$map_in{'[CC]'}];

         $columns_out[$map_out{'Control'}] = $columns_in[$map_in{'[DB_NO]'}];

         $columns_out[$map_out{'Lastname'}] = $columns_in[$map_in{'[DB_LAST_NAME]'}];

         $columns_out[$map_out{'Firstname'}] = $columns_in[$map_in{'[DB_FIRST_NAME]'}];

         if ( $columns_in[$map_in{'[DB_ADDRESS]'}] =~ m/^[P]*[.]*\s*[O]*[.]*\s*BOX/ )
         {
            $columns_out[$map_out{'Street'}] = $columns_in[$map_in{'[DB_SECOND_ADDRESS]'}];

         }
         else
         {
            $columns_out[$map_out{'Street'}] = $columns_in[$map_in{'[DB_ADDRESS]'}];

         } ## end if

         if ( $columns_out[$map_out{'Street'}] =~ m/^(\d+)\s+/ )
         {
            $columns_out[$map_out{'House'}] = $1;

            $columns_out[$map_out{'Street'}] =~ s/^(\d+)\s+//;

         } ## end if

         $columns_out[$map_out{'City'}] = $columns_in[$map_in{'[DB_CITY_ONLY]'}];

         $columns_out[$map_out{'State'}] = $columns_in[$map_in{'[DB_STATE]'}];

         $columns_out[$map_out{'Zip'}] = $columns_in[$map_in{'[DB_ZIP]'}];

         $columns_out[$map_out{'Zip'}] =~ s/[-]//;

         if ( $columns_in[$map_in{'[MAIL_RETURN]'}] eq 'Y' )
         {
            $columns_out[$map_out{'NeedAddress'}] = 1;

         }
         else
         {
            $columns_out[$map_out{'NeedAddress'}] = 0;

         } ## end if

         $status_out = $csv_out->combine( @columns_out );

         print $fh_out $csv_out->string() . "\n";

      } ## end if

   } ## end while

   $fh_in->close();

   $fh_out->close();

} ## end sub WWW::WhitePages::crs2wp

##
## 00 Starter
##
sub WWW::WhitePages::00_starter
{
   chdir $FindBin::Bin;

   my $fh_in = IO::Zlib->new( 'wp.csv.gz', 'rb' );

   my $csv_in = Text::CSV->new();

   my $status_in = undef;

   my @order_in = undef;

   my %map_in = ();

   my @columns_in = undef;

   while ( my $line_in = <$fh_in> )
   {
      if ( $. == 1 )
      {
         $status_in = $csv_in->parse( $line_in );

         @order_in = $csv_in->fields();

         for ( my $i = 0; $i <= $#order_in; $i++ )
         {
            $map_in{$order_in[$i]} = $i;

         } ## end for

      }
      else
      {
         $status_in = $csv_in->parse( $line_in );

         @columns_in = $csv_in->fields();

         if ( -e File::Spec->catfile( 'data', $columns_in[$map_in{'Control'}] . '.xml.gz' ) )
         {
            ##debug## print 'Skipping ' . $columns_in[$map_in{'Control'}] . "\n";

         }
         else
         {
            ##debug##
            print 'Processing ' . $columns_in[$map_in{'Control'}] . "\n";

            my $control =
            {
               'level' => -1,
               'parsed' => -1,
               'reviewed' => -1,
               'order_in' => [@order_in],
               'columns_in' => [@columns_in],
               'xml' => [],
               'order_out' => [],
               'columns_out' => [],
               'reported' => 0,

            };

            XML::Dumper::pl2xml( $control, File::Spec->catfile( 'data', $columns_in[$map_in{'Control'}] . '.xml.gz' ) );

         } ## end if

      } ## end if

   } ## end while

   $fh_in->close();

} ## end sub WWW::WhitePages::00_starter

##
## 01 Get them
##
sub WWW::WhitePages::01_getthem
{
   chdir $FindBin::Bin;

   chdir 'data';

   my @input = <*.xml.gz>;

   foreach my $control_file ( sort @input )
   {
      my $control = XML::Dumper::xml2pl( $control_file );

      if ( ( $control->{'level'} == -1 ) ||
           (
             ( $control->{'level'} == 0 ) &&
             ( $control->{'parsed'} == 0 ) &&
             ( $control->{'reviewed'} == 0 ) &&
             ( $control->{'reported'} == 0 )
           )
         )
      {
         ##debug##
         print 'Processing ' . $control_file . "\n";

         my %map_in = ();

         for ( my $i = 0; $i <= $#{$control->{'order_in'}}; $i++ )
         {
            $map_in{$control->{'order_in'}->[$i]} = $i;

         } ## end for

         my $request = undef;

         if ( $control->{'level'} == -1 )
         {
            $request = WWW::WhitePages::XML::API::find_person(
                          'lastname'  => $control->{'columns_in'}->[$map_in{'Lastname'}],
                          'firstname' => $control->{'columns_in'}->[$map_in{'Firstname'}],
                          'house'     => $control->{'columns_in'}->[$map_in{'House'}],
                          'street'    => $control->{'columns_in'}->[$map_in{'Street'}],
                          'city'      => $control->{'columns_in'}->[$map_in{'City'}],
                          'state'     => $control->{'columns_in'}->[$map_in{'State'}],
                          'zip'       => $control->{'columns_in'}->[$map_in{'Zip'}],
                                                             );

         }
         else
         {
            $request = WWW::WhitePages::XML::API::find_person(
                          'lastname'  => $control->{'columns_in'}->[$map_in{'Lastname'}],
                          'firstname' => $control->{'columns_in'}->[$map_in{'Firstname'}],
                          'city'      => $control->{'columns_in'}->[$map_in{'City'}],
                          'state'     => $control->{'columns_in'}->[$map_in{'State'}],
                          'zip'       => $control->{'columns_in'}->[$map_in{'Zip'}],
                          'metro'     => 1,
                                                             );

         } ## end if

         my $result = WWW::WhitePages::XML::API::ua_request( $request );

         if ( $result->is_success() )
         {
            $control->{'level'}++;

            $control->{'xml'}->[$control->{'level'}] = $result->content();

            XML::Dumper::pl2xml( $control, $control_file );

         } ## end if

      } ## end if

   } ## end foreach

} ## end sub WWW::WhitePages::01_getthem

##
## 02 Process
##
sub WWW::WhitePages::02_process
{
   chdir $FindBin::Bin;

   chdir 'data';

   my @input = <*.xml.gz>;

   foreach my $control_file ( sort @input )
   {
      my $control = XML::Dumper::xml2pl( $control_file );

      if ( $control->{'parsed'} < $control->{'level'} )
      {
         ##debug##
         print 'Processing ' . $control_file . "\n";

         WWW::WhitePages::XML::parse_find_person_to_csv( $control );

         $control->{'parsed'} = $control->{'level'};

         XML::Dumper::pl2xml( $control, $control_file );

      } ## end if

   } ## end foreach

} ## end sub WWW::WhitePages::02_process

##
## 03 Reports
##
sub WWW::WhitePages::03_reports
{
   chdir $FindBin::Bin;

   chdir 'data';

   my $runtime = Date::Format::time2str( "%Y%m%d%H%M%S", time() );

   my $csv_out = Text::CSV->new();

   my $status_out = undef;

   my @input = <*.xml.gz>;

   foreach my $control_file ( sort @input )
   {
      my $control = XML::Dumper::xml2pl( $control_file );

      if ( ( $control->{'parsed'} == $control->{'level'} ) &&
           ( $control->{'reviewed'} < $control->{'level'} )
         )
      {
         if ( $#{$control->{'columns_out'}} >= 0 )
         {
            ##debug##
            print 'Processing ' . $control_file . "\n";

            my @output = ();

            my %map_in = ();

            for ( my $i = 0; $i <= $#{$control->{'order_in'}}; $i++ )
            {
               $map_in{$control->{'order_in'}->[$i]} = $i;

            } ## end for

            foreach my $x ( @{$control->{'columns_out'}} )
            {
               if ( $control->{'columns_in'}->[$map_in{'NeedAddress'}] )
               {
                  push( @output, $x );

               }
               else
               {
                  push( @output, $x ) if ( $x->[0] ne '' ); ## with phone numbers only

               } ## end if

            } ## end foreach

            if ( $#output >= 0 )
            {
               my $fh_out = IO::File->new( File::Spec->catfile( '..', 'output', 'group_' . $control->{'columns_in'}->[$map_in{'Group'}] . "_$runtime" . '.txt' ), 'a' );

               my @columns_in = @{$control->{'columns_in'}};

               shift( @columns_in );

               $status_out = $csv_out->combine( @columns_in );

               print $fh_out $csv_out->string() . "\n";

               foreach my $x ( @output )
               {
                  $status_out = $csv_out->combine( @{$x} );

                  print $fh_out $csv_out->string() . "\n";

               } ## end foreach

               print $fh_out "\n";

               $fh_out->close();

               $control->{'reported'} = 1;

            } ## end if

         } ## end if

         $control->{'reviewed'} = $control->{'level'};

         XML::Dumper::pl2xml( $control, $control_file );

      } ## end if

   } ## end foreach

} ## end sub WWW::WhitePages::03_reports

##
## 04 Tallier
##
sub WWW::WhitePages::04_tallier
{
   chdir $FindBin::Bin;

   chdir 'data';

   my ( $count_in, $count_tried, $count_found ) = ( 0, 0, 0 );

   my @input = <*.xml.gz>;

   foreach my $control_file ( @input )
   {
      $count_in++;

      my $control = XML::Dumper::xml2pl( $control_file );

      $count_tried++ if ( $control->{'level'} >= 0 );

      $count_found++ if ( $control->{'reported'} );

   } ## end foreach

   printf( "counted %d=tried and %d=found of %d=total\n", $count_tried, $count_found, $count_in );

} ## end sub WWW::WhitePages::04_tallier

1;
__END__ ## package WWW::WhitePages

=head1 NAME

B<WWW::WhitePages> - WhitePages Development Interface (WPDI)

=head1 SYNOPSIS

B<require WWW::WhitePages;>

mkdir 'data'; ## do once

mkdir 'output'; ## do once

WWW::WhitePages::crs2wp(); ## example file conversion

WWW::WhitePages::00_starter(); ## run once

WWW::WhitePages::01_getthem(); ## run daily

WWW::WhitePages::02_process(); ## run as needed

WWW::WhitePages::03_reports(); ## run as needed

=head1 OPTIONS

=head1 DESCRIPTION

B<WWW::WhitePages> is the B<Public> I<WhitePages Development Interface> (WPDI).

We need your private B<dev_key> defined in ~/.www_whitepages_rc.

WWW::WhitePages uses WWW::WhitePages::XML::API to find people's addresses and phone numbers.
There is a "maximum daily limit" of 1500 imposed by www.whitepages.com.

See http://developer.whitepages.com for details.

=over

=item WWW::WhitePages::crs2wp();

This procedure converts crs2wp.txt.gz into wp.csv.gz.

=item WWW::WhitePages::00_starter();

This procedure produces a <data/*.xml.gz> file for each record in wp.csv.gz.

The wp.csv.gz file has the following fields:

B<Group>: Used for grouping records into output group files.

=over

Group names the <output/group_*_{timestamp}.txt> files.

=back

B<Control>: Used for a unique key in each record.

=over

Control names the <data/*.xml.gz> control files.

=back

B<Lastname>: Last name (like Meyers)

B<Firstname>: First name (like Eric R)

B<House>: House number

B<Street>: Street name (without House number)

B<City>: City name

B<State>: State abbreviation

B<Zip>: Zip+4 zipcode (no dash)

B<NeedAddress>: 0/1 boolean flag

=item WWW::WhitePages::01_getthem();

This procedure performs the 1500 "find_person" searches per day. It uses the data as provided in wp.csv.gz to perform the initial query.

=item WWW::WhitePages::02_process();

This procedure processes the XML into CSV.

=item WWW::WhitePages::03_reports();

This procedure generates the outputed group files.  If you don't need addresses, only records returned with phone numbers will be output.  The group files can be printed in landscape mode, using Open-office Calc or Writer.  Control logic is employed to report only once on a returned record.

The fields output are qw(Type Lastname Firstname House Street City State Zip Phone), where Type can be blank, 'home' or 'work' for the Phone number.

=back

=head1 SEE ALSO

I<L<WWW::WhitePages::XML>>

=head1 AUTHOR

 Copyright (C) 2008 Eric R. Meyers E<lt>Eric.R.Meyers@gmail.comE<gt>

=head1 LICENSE

perl

=cut

