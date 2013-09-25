#!/usr/bin/perl
#
# Access the OwnCloud installation for the first time.
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

use IndieBox::Utils;
use POSIX;

my $dir         = $config->getResolve( 'appconfig.apache2.dir' );
my $apacheUname = $config->getResolve( 'apache2.uname' );

if( 'install' eq $operation ) {
    # now we need to hit the installation ourselves, otherwise the first user gets admin access
    my $out;
    my $err;
    if( IndieBox::Utils::myexec( "cd $dir; sudo -u $apacheUname php index.php", undef, \$out, \$err ) != 0 ) {
        die( "Activating OwnCloud in $dir failed: out: $out\nerr: $err" );
    }
}

1;
