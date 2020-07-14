#!/usr/bin/bash

    #Housekeeping
sudo su - root
cd ~/
cp /vagrant/pkg.oracle.com.certificate.pem .
#cp /oraclecloud/pkg.oracle.com.certificate.pem .
cp /vagrant/pkg.oracle.com.key.pem .
#cp /oraclecloud/pkg.oracle.com.key.pem .
    #Create PKCS of cert&key to obtain offline pkgs:
    #(Using dom. pass:)
openssl pkcs12 -export -in /root/pkg.oracle.com.certificate.pem \
-inkey /root/pkg.oracle.com.key.pem -out /root/pkg.oracle.com.p12
cp pkg.oracle.com.p12 /oraclecloud

    #Setup repos, install deps
pkg set-publisher -k pkg.oracle.com.key.pem \
-c pkg.oracle.com.certificate.pem \
-G "*" -g https://pkg.oracle.com/solaris/support/ solaris
#pkg update --accept
pkgadd -d http://get.opencsw.org/now
PATH=/opt/csw/bin:$PATH
export PATH
pkgutil --catalog --upgrade pkgutil
pkg install bison git gcc unzip SUNWpkgcmds libtool autoconf automake pkg-config

    #collectd pkg
pkgutil \
--stream \
--target=sparc:5.11 \
--output /root/collectd_511.pkg \
--yes \
--download \
collectd collectd_plugins_all collectd_dev libcurl4_feature
    #cross-compile knpdb11 SPARC supplemental pkg:
    #for files 
pkgutil \
--stream \
--target=sparc:5.11 \
--output /root/cc-knpdb11-sparc.pkg \
--yes \
--download \
git bison automake autoconf gcc5core libtool pkgconfig
    #download .pkgs for what csw can't provide,
    #and broken pkg repo won't download:
    #gcc libtool pkg-config SUNWpkgcmds
pkgrecv --newest \
-s http://pkg.oracle.com/solaris/release/ \
#-s https://pkg.oracle.com/solaris/support/ \
-d /root/pkg-knpdb11-sparc.p5p -a \
-r \
developer/versioning/git \
developer/gcc \
developer/build/libtool \
developer/build/pkg-config \
SUNWpkgcmds \
#--key /root/pkg.oracle.com.key.pem \
#--cert /root/pkg.oracle.com.certificate.pem

#pkgrecv -c

cd ~/ && mkdir pkgs && cd pkgs

cp * /oraclecloud

## DEV-TST-SCENARIO=1:
    #write_splunk cross-compile
    #Trying with collectd-5.10.0
pkgutil --install bison automake autoconf --yes
mkdir -p /root/git
cd /root/git
git clone https://github.com/splunk/collectd-plugins.git
git clone https://github.com/collectd/collectd.git
cd collectd && git checkout collectd-5.9
cp -f ../collectd-plugins/src/* src/
git apply ../collectd-plugins/add-splunk-plugins.patch
./build.sh
./configure --build=x86_64-sun-solaris2.10 --host=x86_64-sun-solaris2.10 --target=sparc-sun-solaris2.10
make
#make check-TESTS
make install