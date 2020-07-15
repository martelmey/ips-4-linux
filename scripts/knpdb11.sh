#!/usr/bin/bash

##
### PROBLEM: broken pkg
##

#cd /mnt/c/Users/martel.meyers/Vagrant/solaris
#scp -P 2022 cc-knpdb11-sparc.pkg martel.meyers@65.110.171.190:/home/martel.meyers

#Fix solaris repo
sudo su - root
cd ~/
echo "HTTP_PROXY=http://192.168.60.250:8008">>/root/.profile
cp /export/pkgs/splunk/pkg.oracle.com.certificate.pem .
cp /export/pkgs/splunk/pkg.oracle.com.key.pem .
pkg set-publisher -k /root/pkg.oracle.com.key.pem \
-c /root/pkg.oracle.com.certificate.pem \
-G "*" \
-g https://pkg.oracle.com/solaris/support/ \
--proxy http://192.168.60.250:8008 \
solaris

#Install deps
#pkg update --accept
#pkg install git gcc unzip SUNWpkgcmds libtool autoconf automake pkg-config
cp /export/pkgs/splunk/pkg-knpdb11-sparc.p5p .
cp /export/pkgs/splunk/cc-knpdb11-sparc.pkg .
pkgadd -d cc-knpdb11-sparc.pkg all
PATH=/opt/csw/bin:$PATH
export PATH
#pkg install -g file:////root/pkg-knpdb11-sparc.p5p

#Clone plugin repos
#On dev-hial1: (publisher=collectd)
cp /export/pkgs/splunk/sparc-collectd.tar .
tar -xvf sparc-collectd.tar && cd collectd
./build.sh
./configure \
--build=sparc-sun-solaris2.10 \
--host=sparc-sun-solaris2.10 \
--target=sparc-sun-solaris2.10
make
#Errors start here - Tues July14