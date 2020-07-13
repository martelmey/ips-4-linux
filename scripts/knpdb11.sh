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
pkg update --accept
pkg install git gcc unzip SUNWpkgcmds libtool autoconf automake pkg-config
cp /export/pkgs/splunk/cc-knpdb11-sparc.pkg .
pkgadd -d cc-knpdb11-sparc.pkg all #(git, bison, automake, autoconf)

#Clone plugin repos
git config --global http.proxy http://192.168.60.250:8008
#git config --global --get http.proxy
git clone https://github.com/splunk/collectd-plugins.git
git clone https://github.com/collectd/collectd.git
cd collectd && git checkout collectd-5.9
cp -f ../collectd-plugins/src/* src/
git apply ../collectd-plugins/add-splunk-plugins.patch
./build.sh
./configure --build=x86_64-sun-solaris2.10 --host=x86_64-sun-solaris2.10 --target=sparc-sun-solaris2.10
make
make check-TESTS
make install