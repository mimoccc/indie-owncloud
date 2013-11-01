_developer=http://owncloud.org/
_maintainer=http://indieboxproject.org/
pkgname=indie-owncloud
pkgver=5.0.10
pkgrel=3
pkgdesc="Your Cloud, Your Data, Your Way!"
arch=('any')
url=$_developer
_license=AGPLv3
license=("custom:$_license")
groups=()
depends=()
backup=()
source=("http://download.owncloud.org/community/owncloud-${pkgver}.tar.bz2")
options=('!strip')
md5sums=('76ef522124a23e3d65fe65de00ae487a')
_description=$(sed ':a;N;$!ba;s/\n/ /g' $startdir/description.html)
# from http://stackoverflow.com/questions/1251999/sed-how-can-i-replace-a-newline-n
_parameterize=$(cat <<END
    s!##pkgname##!$pkgname!g;
    s/##pkgdesc##/$pkgdesc/g;
    s!##developer##!$_developer!g;
    s!##maintainer##!$_maintainer!g;
    s!##pkgver##!$pkgver!g;
    s!##pkgrel##!$pkgrel!g;
    s!##license##!$_license!g;
    s!##description##!$_description!g;
END
)

package() {
# Manifest
    mkdir -p $pkgdir/var/lib/indie-box/manifests
    perl -pe "$_parameterize" $startdir/indie-box-manifest.json > $pkgdir/var/lib/indie-box/manifests/indie-owncloud.json
    chmod 0644 $pkgdir/var/lib/indie-box/manifests/indie-owncloud.json

# Code
    mkdir -p $pkgdir/usr/share/indie-owncloud/bin
    install -m755 $startdir/bin/write-config.pl $pkgdir/usr/share/indie-owncloud/bin/
    install -m755 $startdir/bin/web-install.pl  $pkgdir/usr/share/indie-owncloud/bin/

    mkdir -p $pkgdir/usr/share/indie-owncloud/tmpl
    install -m755 $startdir/tmpl/htaccess.tmpl $pkgdir/usr/share/indie-owncloud/tmpl/

    cp -dr --no-preserve=ownership $startdir/src/owncloud $pkgdir/usr/share/indie-owncloud/

# License
    mkdir -p $pkgdir/usr/share/licenses/indie-owncloud
    install -m644 $startdir/src/owncloud/COPYING-AGPL $pkgdir/usr/share/licenses/indie-owncloud/LICENSE
}
