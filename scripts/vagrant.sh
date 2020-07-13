#!/usr/bin/bash

sudo su - root
cd ~/
cp /vagrant/pkg.oracle.com.certificate.pem .
cp /vagrant/pkg.oracle.com.key.pem .
pkg set-publisher -k pkg.oracle.com.key.pem -c pkg.oracle.com.certificat
e.pem -G "*" -g https://pkg.oracle.com/solaris/support/ solaris
pkg update --accept

pkgadd -d http://get.opencsw.org/now
PATH=/opt/csw/bin:$PATH
export PATH
pkgutil --catalog --upgrade pkgutil
pkgutil \
--stream \
--target=sparc:5.11 \
--output /root/collectd_511.pkg \
--yes \
--download \
collectd collectd_plugins_all collectd_dev libcurl4_feature
pkgutil \
--stream \
--target=sparc:5.11 \
--output /root/cc-knpdb11-sparc.pkg \
--yes \
--download \
git bison automake autoconf
cp cc-knpdb11-sparc.pkg /vagrant