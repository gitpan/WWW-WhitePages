#!/usr/bin/perl -w
##

use strict;

use warnings;

use Module::Build;

require Config;

require File::Spec;

my $param =
{
   'NAME' => 'WWW-WhitePages',
   'CPANID' => 'ERMEYERS',
   'AUTHOR' => 'Eric R. Meyers <Eric.R.Meyers@gmail.com>',
   'VERSION' => '2008.0924',
   'LICENSE' => 'perl',
   'ABSTRACT' => 'Interface to www.whitepages.com',

};

my $build = Module::Build->new
   (
      'dist_name' => $param->{'NAME'},
      'dist_author' => $param->{'AUTHOR'},
      'dist_version' => $param->{'VERSION'},
      'license' => $param->{'LICENSE'},
      'dist_abstract' => $param->{'ABSTRACT'},
      'create_makefile_pl' => 'passthrough',
      'sign' => 1,
      'recursive_test_files' => 1,
      'build_requires' =>
      {
         'Test::More' => 0,
      },
      'requires' =>
      {
         'perl' => '5.6.1',
         'HTTP::Cookies' => 0,
         'LWP::UserAgent' => 0,

      },
      'recommends' =>
      {
         'Test::Memory::Cycle' => 0,
         'Test::Pod' => 0,
         'Test::Taint' => 0,
         'Test::Warn' => 0,

      },
      'add_to_cleanup' =>
      [
         "$param->{'NAME'}-$param->{'VERSION'}.tar.gz",

      ],
   );

$build->create_build_script();

if ( -d "./_bin" ) ## won't exist in distribution
{
   system( "./_bin/create_www_whitepages.plx $param->{'VERSION'}" );

   $build->dispatch( 'build' );
   $build->dispatch( 'test', 'verbose' => 1 );
   $build->dispatch( 'install' );

   ##debug## gpg_me();

}
else
{
   #print "##\n## Thanks to Audrey Tang, for being the first person to send me an encryption.\n##\n";

   #gpg_me();

   print "Now, please enter 'Build' to make all, 'Build test' to test, and 'Build install' to install.\n";

} ## end if

##
## can_find
##
sub can_find
{
   my $cmd = shift;

   my $abs = undef;

   foreach my $dir ( split( /$Config::Config{'path_sep'}/, $ENV{PATH} ), '.' )
   {
      $abs = File::Spec->catfile( $dir, $cmd );

      return ( $abs ) if ( -x $abs );

   } ## end foreach

   return;

} ## end sub can_find

##
## gpg_me
##
sub gpg_me
{
   print "*** Looking for GnuPG (GNU Privacy Guard, a cryptographic signature tool)...\n";

   my $gpg = can_find( 'gpg' );

   if ( defined( $gpg ) && ( `gpg --version` =~ /GnuPG/ ) && defined( `gpg --list-public-keys` ) )
   {
      print "GnuPG found ($gpg).\n";

      return ( 1 ) if grep { /^--installdeps/ } @ARGV;

      my $prmt = "Import CPAN Author $param->{'CPANID'}'s public key into GnuPG?";

      my $perm = 'n';

      eval
      {
         local $SIG{'ALRM'} = sub { die( "alarm\n" ) };

         alarm 30;

         $perm = $build->prompt( $prmt, $perm );

         alarm 0;

      }; ## end eval

      if ( $@ )
      {
         die( $@ ) unless ( $@ eq "alarm\n" );

         print "\n";

      } ## end if

      if ( $perm =~ m/^y/i )
      {
         print 'Importing public key into GnuPG keyring... ';

         system( 'gpg --quiet --import '. glob('public_keys/'.$param->{'CPANID'}.'*.pub') );

         print "done.\n";

      } ## end if

      return ( 1 );

   } ## end if

   print 'GnuPG not found anywhere in your PATH, "eek," said Audrey Tang.'."\n";

   return ( 0 );

} ## end sub gpg_me

