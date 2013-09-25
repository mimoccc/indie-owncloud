#!/usr/bin/perl
#
# Write and maintain OwnCloud configuration file
#
# Copyright (C) 2013 Indie Box Project http://indieboxproject.org/
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

use strict;

use IndieBox::Utils qw( saveFile slurpFile );
use POSIX;

my $dir         = $config->getResolve( 'appconfig.apache2.dir' );
my $appsDir     = "$dir/apps";
my $dataDir     = "$dir/data";
my $configDir   = "$dir/config";

my $autoConfFile   = "$configDir/autoconfig.php";
my $confFile       = "$configDir/config.php";
my $saltFile       = "$configDir/passwordsalt.txt";
my $instanceIdFile = "$configDir/instanceid.txt";

my $apacheUname = $config->getResolve( 'apache2.uname' );
my $apacheGname = $config->getResolve( 'apache2.gname' );

if( 'install' eq $operation ) {
    my $appconfigid = $config->getResolve( 'appconfig.appconfigid' );


    my $hostname = $config->getResolve( 'site.hostname' );
    my $context  = $config->getResolve( 'appconfig.context' );

    my $dbname = $config->getResolve( 'appconfig.mysql.dbname.maindb' );
    my $dbuser = $config->getResolve( 'appconfig.mysql.dbuser.maindb' );
    my $dbpass = $config->getResolve( 'appconfig.mysql.dbusercredential.maindb' );
    my $dbhost = $config->getResolve( 'appconfig.mysql.dbhost.maindb' );

    my $adminlogin = $config->getResolve( 'appconfig.installable.customizationpoints.adminlogin.value' );
    my $adminpass  = $config->getResolve( 'appconfig.installable.customizationpoints.adminpass.value' );

    IndieBox::Utils::myexec( "chown $apacheUname:$apacheGname '$configDir'" );
    IndieBox::Utils::myexec( "chown $apacheUname:$apacheGname '$appsDir'" );
    IndieBox::Utils::myexec( "chown $apacheUname:$apacheGname '$dir/index.html'" );
    # IndieBox::Utils::myexec( "chmod 0770 '$dir'" );

    if( -e $saltFile ) {
        # recreate confFile

        my $salt = slurpFile( $saltFile );
        $salt =~ s/^\s+//g;
        $salt =~ s/\s+$//g;

        my $instanceId = slurpFile( $instanceIdFile );
        $instanceId =~ s/^\s+//g;
        $instanceId =~ s/\s+$//g;

        my $confContent = <<CONTENT;
<?php
\$CONFIG = array (
  'instanceid'    => '$instanceId',
  'passwordsalt'  => '$salt',
  'datadirectory' => '$dataDir',
  'dbtype'        => 'mysql',
  'version'       => '5.5.32',
  'dbname'        => '$dbname',
  'dbhost'        => '$dbhost',
  'dbtableprefix' => '',
  'dbuser'        => '$dbuser',
  'dbpassword'    => '$dbpass',
  'installed'     => true
);
CONTENT

        IndieBox::Utils::saveFile( $confFile, $confContent, 0644, $apacheUname, $apacheGname );

    } elsif( ! -e $confFile ) {
        # first time
        my $autoConfContent = <<CONTENT;
<?php
\$AUTOCONFIG = array(
  "dbtype"        => "mysql",
  "dbname"        => "$dbname",
  "dbuser"        => "$dbuser",
  "dbpass"        => "$dbpass",
  "dbhost"        => "$dbhost",
  "dbtableprefix" => "",
  "adminlogin"    => "$adminlogin",
  "adminpass"     => "$adminpass",
  "directory"     => "$dataDir"
);
CONTENT

        IndieBox::Utils::saveFile( $autoConfFile, $autoConfContent, 0644, $apacheUname, $apacheGname );
    }
}
if( 'uninstall' eq $operation ) {
    if( -e $autoConfFile ) {
        IndieBox::Utils::deleteFile( $autoConfFile )
    }
    if( -e $confFile ) {
        # preserve salt and instanceid
        my $confContent = slurpFile( $confFile );

        if( $confContent =~ /'passwordsalt'.*'([a-z0-9]+)'/m ) {
            my $salt = $1;

            IndieBox::Utils::saveFile( $saltFile, $salt, 0640, $apacheUname, $apacheGname );
        }
        if( $confContent =~ /'instanceid'.*'([a-z0-9]+)'/m ) {
            my $instanceId = $1;

            IndieBox::Utils::saveFile( $instanceIdFile, $instanceId, 0640, $apacheUname, $apacheGname );
        }

        IndieBox::Utils::deleteFile( $confFile )
    }
    # seems owncloud generates a .htaccess file, which we need to remove
    if( -e "$dir/.htaccess" ) {
        IndieBox::Utils::deleteFile( "$dir/.htaccess" );
    }
}
1;
