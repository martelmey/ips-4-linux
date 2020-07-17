#!/bin/bash

#192.168.63.20  T8-1 DB Server #1  - root domain (kdbdm01)
#192.168.63.30  T8-1 DB Server #2  - root domain (kdbdm02)
#192.168.63.40  T8-2 APP Server #1  - root domain (kappdm01)
#192.168.63.50  T8-2 APP Server #2  - root domain (kappdm02)
#192.168.63.60  T8-2 APP Server #3  - root domain (kappdm03)
#192.168.63.70  T8-2 APP Server #4  - root domain (kappdm04)
#192.168.63.80  T7-1 DEV IDAM Server #1 - root domain (kdevideamdm01)

REPOSDIR=/export/pkgs/repos
IPSDIR=/export/pkgs/repos/solsr
SRKEY=/root/pkg.oracle.com.key.pem
SRCERT=/root/pkg.oracle.com.certificate.pem
HTTP_PROXY=http://192.168.60.250:8008

#Option1
#Relies on outbound/inbound access to 192.168.60.250:8008
reposetupremote() {
    sudo su - root
    cd ~/
    mkdir -p /export/pkgs
    mount 192.168.61.132:\export/utilities-kdcprd/pkgs /export/pkgs
    cp /export/pkgs/repos/pkg.oracle.com.*.pem .

    pkg set-publisher -k /root/pkg.oracle.com.key.pem \
    -c /root/pkg.oracle.com.certificate.pem \
    -G "*" -g https://pkg.oracle.com/solaris/support/ \
    --proxy http://192.168.60.250:8008 solaris

    pkg update --accept

    svcadm enable -s svc:/application/pkg/system-repository:default
    svccfg -v -s svc:/application/pkg/system-repository:default setprop config/http_proxy=http://192.168.60.250:8008

    svcadm enable -s svc:/application/pkg/zones-proxyd:default
}

repocheck() {
    pkg publisher solaris
    svcs \*pkg\*

    #svcs -l svc:/application/pkg/zones-proxyd:default (def=disabled)
    #svcprop -a svc:/application/pkg/zones-proxyd:default

    #svcs -l svc:/application/pkg/system-repository:default (def=disabled)
    #svcprop -a svc:/application/pkg/system-repository:default

    #svcs -l svc:/system/pkgserv:default (def=enabled)
    #svcprop -a svc:/system/pkgserv:default

    #svcs -l svc:/application/pkg/repositories-setup:default (def=enabled)
    #svcprop -a svc:/application/pkg/repositories-setup:default
}

#Option2
#Relies on access to 192.168.61.132:\export/utilities-kdcprd/pkgs
#https://docs.oracle.com/cd/E37838_01/html/E60982/cpfromzip.html#scrolltoc
reposetuplocal() {
    #create once on knpdbdm01, set all other root zones to use
    #may need to make a cswstream for unzip, and send over if not installed
    cd /export/pkgs/repos
    unzip p31463805_1100_SOLARIS64.zip
    chmod +x install-repo.sh
    ./install-repo.sh -d /export/pkgs/repos/solsr
}

buildcollectd() {
    pkg install bison gcc SUNWpkgcmds libtool autoconf automake pkg-config flex
    pkg install pkg:/runtime/perl-526@5.26.2-11.4.0.0.1.14.0
    cd /root
    cp /export/pkgs/splunk/sparc-collectd.tar .
    tar -xvf sparc-collectd.tar && cd collectd
    ./build.sh
    ./configure \
    --build=sparc-sun-solaris2.10 \
    --host=sparc-sun-solaris2.10 \
    --target=sparc-sun-solaris2.10
    make
}

pkgcollectd() {

}