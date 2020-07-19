#!/usr/bin/bash

## LOCAL (wls-ubuntu)
#   cd ~/
#   cp /mnt/c/Users/martel.meyers/Desktop/oraclecloud/*.key .ssh
#   cp /mnt/c/Users/martel.meyers/Desktop/oraclecloud/*.pem .ssh
#   chmod 700 .ssh
#   chmod 644 .ssh/ssh-key-*.key.pub
#   chmod 600 .ssh/ssh-key-*.key
#   scp -i ~/.ssh/ssh-key-2020-07-17.key ~/.ssh/pkg.oracle.com.key.pem opc@150.136.102.55:/export/home/opc
#   scp -i ~/.ssh/ssh-key-2020-07-17.key ~/.ssh/pkg.oracle.com.certificate.pem opc@150.136.102.55:/export/home/opc
#   ssh -i .ssh/ssh-key-2020-07-17.key opc@150.136.102.55

REMOTE=150.136.102.55
PKGKEY="/root/pkg.oracle.com.key.pem"
PKGCERT="/root/pkg.oracle.com.certificate.pem"
SSHKEY="~/.ssh/ssh-key-2020-07-17.key"
LOCALES=/usr/lib/locale/<locale-name>/<localename>
LOCALE=

housekeep() {
    #pkg change-facet facet.locale.en_*=True
    svccfg -s svc:/system/environment:init setprop environment/LANG = astring: "C"
    svccfg -s svc:/system/environment:init setprop environment/LC_ALL = astring: "C"
    svcadm refresh svc:/system/environment

    sudo su - root
    cd ~/
    mv /export/home/opc/* .
    pkg set-publisher -k /root/pkg.oracle.com.key.pem \
    -c /root/pkg.oracle.com.certificate.pem \
    -G "*" -g https://pkg.oracle.com/solaris/support/ solaris

    sudo pkg set-publisher \
    -k /root/pkg.oracle.com.key.pem \
    -c /root/pkg.oracle.com.certificate.pem \
    -G "*" -g https://pkg.oracle.com/solarisstudio/release solarisstudio

    pkg install -–accept developerstudio-126
    pkg update --accept
    PATH=/opt/developerstudio12.6/bin:$PATH
    export PATH
    MANPATH=/opt/developerstudio12.6/man:$MANPATH
    export MANPATH

    #/opt/developerstudio12.6/bin/devstudio &
    pkg install bison git gcc unzip SUNWpkgcmds libtool autoconf automake pkg-config flex
    pkg install m4 libtoolize
}

collectdcc() {
    mkdir -p /root/git
    cd /root/git
    git clone https://github.com/splunk/collectd-plugins.git
    git clone https://github.com/collectd/collectd.git
    cd collectd && git checkout collectd-5.9
    cp -f ../collectd-plugins/src/* src/
    git apply ../collectd-plugins/add-splunk-plugins.patch
    ./build.sh

    #aclocal not found

    ./configure --build=x86_64-sun-solaris2.10 --host=x86_64-sun-solaris2.10 --target=sparc-sun-solaris2.10
    make
    #make check-TESTS
    make install
}


    ## DEV-TST-SCENARIO=2:
    #local solaris support repo demo
chmod +x install-repo.ksh
zfs create -o atime=off rpool1/export/repoSolaris11
#zfs get atime rpool/export/repoSolaris11
mkdir -p /export/repoSolaris11/solaris
./install-repo.ksh -d /export/repoSolaris11/solaris -c -v -I
zfs snapshot rpool/export/repoSolaris11/solaris@sol-11_4

#curl \
#--url <"https://pkg.oracle.com/solaris/support/"> \
#--cert "$PKGCERT" \
#--key "$PKGKEY" \
#--key-type PEM \
#--output /root/remote_summary \
#--proxy-anyauth \
#--proxy#1.0 192.168.60.250:8008 \
#--proxytunnel \
#--trace#-ascii /root/remote_summary.trc