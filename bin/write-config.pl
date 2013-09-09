#!/usr/bin/perl
#
# Write and maintain OwnCloud configuration file
#
# Copyright (C) 2013 Johannes Ernst
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

use IndieBox::Utils;
use POSIX;

my $dir         = $varMap->{appconfig}->{contextroot};
my $appconfigid = $varMap->{appconfig}->{appconfigid};

my $autoConfFile   = "$dir/config/autoconfig.php";
my $confFile       = "$dir/config/config.php";
my $dataDir        = "${appconfig.datadir}/data";
my $configDir      = "${appconfig.datadir}/config";
my $saltFile       = "$configDir/passwordsalt.txt";
my $instanceIdFile = "$configDir/instanceid.txt";

my $apacheUname = $varMap->{apache2}->{uname};
my $apacheGname = $varMap->{apache2}->{gname};

if( 'install' eq $operation ) {
    IndieBox::Utils::myexec( "chown $apacheUname:$apacheGname '$dir/config'" );
    IndieBox::Utils::myexec( "chown $apacheUname:$apacheGname '$dir/apps'" );
    IndieBox::Utils::myexec( "chown $apacheUname:$apacheGname '$dir/index.html'" );
    IndieBox::Utils::myexec( "chmod 0770 '$dir'" );

    my $hostname = $varMap->{site}->{hostname};
    my $context  = $varMap->{appconfig}->{context};

    my $dbname = $varMap->{appconfig}->{roles}->{mysql}->{dbname}->{maindb};
    my $dbuser = $varMap->{appconfig}->{roles}->{mysql}->{dbuser}->{maindb};
    my $dbpass = $varMap->{appconfig}->{roles}->{mysql}->{dbusercredential}->{maindb};
    my $dbhost = $varMap->{appconfig}->{roles}->{mysql}->{privateipaddress};

    my $adminlogin = $varMap->{thisitem}->{customizationpoints}->{adminlogin}->{value};
    my $adminpass  = $varMap->{thisitem}->{customizationpoints}->{adminpass}->{value};

    if( -e $saltFile ) {
        # recreate confFile

        my $salt = slurp( $saltFile );
        $salt =~ s/^\s+//g;
        $salt =~ s/\s+$//g;

        my $instanceId = slurp( $instanceIdFile );
        $instanceId =~ s/^\s+//g;
        $instanceId =~ s/\s+$//g;

        my $confContent = <<CONTENT;
<?php
\$CONFIG = array (
  'instanceid'    => '$instanceId',
  'passwordsalt'  => '$salt',
  'datadirectory' => '$datadir',
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

    } else {
        # no salt

        unless( -e $confFile ) {
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
  "directory"     => "$datadir"
);
CONTENT

            IndieBox::Utils::saveFile( $autoConfFile, $autoConfContent, 0644, $apacheUname, $apacheGname );
        }

        # preserve salt and instanceid
        my $confContent = slurp( $confFile );

        if( $confContent =~ /'passwordsalt'.*'([a-z0-9]+)'/m ) {
            my $salt = $1;

            IndieBox::Utils::saveFile( $saltFile, $salt, 0640, $apacheUname, $apacheGname );
        }
        if( $confContent =~ /'instanceid'.*'([a-z0-9]+)'/m ) {
            my $instanceId = $1;

            IndieBox::Utils::saveFile( $instanceIdFile, $instanceId, 0640, $apacheUname, $apacheGname );
        }
    }
}
if( 'remove' eq $operation ) {
    if( -e $autoConfFile ) {
        IndieBox::Utils::deleteFile( $autoConfFile )
    }
    if( -e $confFile ) {
        IndieBox::Utils::deleteFile( $confFile )
    }
    if( -d "$dir/data" ) {
        # not sure where that comes from, because we write to /var, but it's there nevertheless
        IndieBox::Utils::deleteFileRecursively( "$dir/data" );
    }
    # seems owncloud generates a .htaccess file, which we need to remove
    if( -e "$dir/.htaccess" ) {
        IndieBox::Utils::deleteFile( "$dir/.htaccess" );
    }
}
1;
