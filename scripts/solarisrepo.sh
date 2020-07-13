#!/usr/bin/bash

##
### PROBLEM: locale
##

    ## LOCAL (wls-ubuntu) (Thinkpad)
#   cd ~/
#   chmod 700 .ssh
#   chmod 644 .ssh/ssh-key-*.key.pub
#   chmod 600 .ssh/ssh-key-*.key
#   ssh -i .ssh/ssh-key-2020-07-11.key opc@129.213.99.223
    ## Migrate repo files from local machine
#   cd /mnt/c/Users/MXANA/Desktop/oraclecloud
#   scp -i ~/.ssh/ssh-key-2020-07-11.key pkg.oracle.com.certificate.pem opc@129.213.99.223:/export/home/opc
#   scp -i ~/.ssh/ssh-key-2020-07-11.key pkg.oracle.com.key.pem opc@129.213.99.223:/export/home/opc
#   scp -i ~/.ssh/ssh-key-2020-07-11.key sol-11_4-repo_1of5.zip opc@129.213.99.223:/export/home/opc
#   scp -i ~/.ssh/ssh-key-2020-07-11.key sol-11_4-repo_2of5.zip opc@129.213.99.223:/export/home/opc
#   scp -i ~/.ssh/ssh-key-2020-07-11.key sol-11_4-repo_3of5.zip opc@129.213.99.223:/export/home/opc
#   scp -i ~/.ssh/ssh-key-2020-07-11.key sol-11_4-repo_4of5.zip opc@129.213.99.223:/export/home/opc
#   scp -i ~/.ssh/ssh-key-2020-07-11.key sol-11_4-repo_5of5.zip opc@129.213.99.223:/export/home/opc
#   scp -i ~/.ssh/ssh-key-2020-07-11.key install-repo.ksh opc@129.213.99.223:/export/home/opc
#   scp -i ~/.ssh/ssh-key-2020-07-11.key sol-11_4-repo_digest.txt opc@129.213.99.223:/export/home/opc

    #housekeeping
echo "export LANG=en_US.UTF-8">>/root/.profile 
echo "export LC_ALL=en_US.UTF-8">>/root/.profile && source /root/.profile
pkg change-facet facet.locale.en_*=True
#svcprop svc:/system/environment:init
svccfg -s svc:/system/environment:init setprop environment/LANG = astring: "en_US.UTF-8"
svccfg -s svc:/system/environment:init setprop environment/LC_ALL = astring: "en_US.UTF-8"
svcadm refresh svc:/system/environment

    #setup support repo & install deps
cd ~/
mv /export/home/opc/* .
pkg set-publisher -k pkg.oracle.com.key.pem -c pkg.oracle.com.certificate.pem -G "*" -g https://pkg.oracle.com/solaris/support/ solaris
pkg update --accept
pkg install git gcc unzip SUNWpkgcmds libtool autoconf automake pkg-config

    #csw setup
pkgadd -d http://get.opencsw.org/now
PATH=/opt/csw/bin:$PATH
export PATH
pkgutil --catalog --upgrade pkgutil
    #collectd pkg
pkgutil \
--stream \
--target=sparc:5.11 \
--output /root/collectd_511.pkg \
--yes \
--download \
collectd collectd_plugins_all collectd_dev libcurl4_feature
    #cross-compile knpdb11 SPARC supplemental pkg:
pkgutil \
--stream \
--target=sparc:5.11 \
--output /root/cc-knpdb11-sparc.pkg \
--yes \
--download \
git bison automake autoconf 

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
./build.sh && ./configure --build=x86_64-sun-solaris2.10 --host=x86_64-sun-solaris2.10 --target=sparc-sun-solaris2.10 && make
#make check-TESTS
make install

    ## DEV-TST-SCENARIO=2:
    #local solaris support repo demo
chmod +x install-repo.ksh
zfs create -o atime=off rpool1/export/repoSolaris11
#zfs get atime rpool/export/repoSolaris11
mkdir -p /export/repoSolaris11/solaris
./install-repo.ksh -d /export/repoSolaris11/solaris -c -v -I
zfs snapshot rpool/export/repoSolaris11/solaris@sol-11_4