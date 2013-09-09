# Maintainer: http://indieboxproject.org/

pkgname=indie-owncloud
pkgver=5.0.10
pkgrel=1
pkgdesc="Your Cloud, Your Data, Your Way!"
arch=('any')
url="http://owncloud.org/"
license=('custom:AGPLv3')
groups=()
depends=()
backup=()
source=("http://download.owncloud.org/community/owncloud-${pkgver}.tar.bz2")
md5sums=('76ef522124a23e3d65fe65de00ae487a')

package() {
# Manifest
    mkdir -p $pkgdir/var/lib/indie-box/
    install -m644 $startdir/indie-box-manifest.json $pkgdir/var/lib/indie-box/indie-owncloud.json

# Code
    mkdir -p $pkgdir/usr/share/indie-owncloud/bin
    install -m755 $startdir/bin/write-config.pl $pkgdir/usr/share/indie-owncloud/bin/
    install -m755 $startdir/bin/web-install.pl  $pkgdir/usr/share/indie-owncloud/bin/

    mkdir -p $pkgdir/usr/share/indie-owncloud/tmpl
    install -m755 $startdir/tmpl/htaccess.tmpl $pkgdir/usr/share/indie-owncloud/tmpl/

    cp -dr --no-preserve=ownership $startdir/src/owncloud $pkgdir/usr/share/indie-owncloud/

# License
    mkdir -p $pkgdir/usr/share/licenses/indie-owncloud
    install -m644 $startdir/owncloud/COPYING-AGPL $pkgdir/usr/share/licenses/indie-owncloud/LICENSE
}
