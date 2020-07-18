#!/bin/bash

#192.168.63.20  T8-1 DB Server #1  - root domain (kdbdm01)
#   192.168.63.21	T8-1 DB Server #1 - DB LDOM DB11 (knpdb11)
#   192.168.63.22	T8-1 DB Server #1 - DB LDOM DB12 (knpdb12)
#192.168.63.30  T8-1 DB Server #2  - root domain (kdbdm02)
#   192.168.63.31	T8-1 DB Server #2 - DB LDOM DB21 (knpdb21)
#   192.168.63.32	T8-1 DB Server #2 - DB LDOM DB22 (knpdb22)
#192.168.63.40  T8-2 APP Server #1  - root domain (kappdm01)
#   192.168.63.41	T8-2 APP Server #1  - APP LDOM APP11  (knpapp11)
#   192.168.63.42	T8-2 APP Server #1  - APP LDOM APP12  (knpapp12)
#   192.168.63.43	T8-2 APP Server #1  - APP LDOM APP13  (knpapp13)
#192.168.63.50  T8-2 APP Server #2  - root domain (kappdm02)
#   192.168.63.51	T8-2 APP Server #2  - APP LDOM APP21  (knpapp21)
#   192.168.63.52	T8-2 APP Server #2  - APP LDOM APP22  (knpapp22)
#   192.168.63.53	T8-2 APP Server #2  - APP LDOM APP23  (knpapp23)
#192.168.63.60  T8-2 APP Server #3  - root domain (kappdm03)
#   192.168.63.61	T8-2 APP Server #3  - APP LDOM APP31  (knpapp31)
#   192.168.63.62	T8-2 APP Server #3  - APP LDOM APP32  (knpapp32)
#   192.168.63.63	T8-2 APP Server #3  - APP LDOM APP33  (knpapp33)
#192.168.63.70  T8-2 APP Server #4  - root domain (kappdm04)
#   192.168.63.71	T8-2 APP Server #4  - APP LDOM APP41  (knpapp41)
#   192.168.63.72	T8-2 APP Server #4  - APP LDOM APP42  (knpapp42)
#   192.168.63.73	T8-2 APP Server #4  - APP LDOM APP43  (knpapp43)
#192.168.63.80  T7-1 DEV IDAM Server #1 - root domain (kdevideamdm01)
#   192.168.63.81	T7-1 DEV IDAM Server #1 - DEV/TEST IDAM LDOM (kdevidamapp01)

REPOSDIR=/export/pkgs/repos
IPSDIR=/export/pkgs/repos/solsr
SRKEY=/root/pkg.oracle.com.key.pem
SRCERT=/root/pkg.oracle.com.certificate.pem
HTTP_PROXY=http://192.168.60.250:8008

tar -cf usrinclude.tar /usr/include && mv usrinclude.tar /export/pkgs/splunk
tar -cf lib.tar /lib && mv lib.tar /export/pkgs/splunk
tar -cf usrlib.tar /usr/lib && mv usrlib.tar /export/pkgs/splunk
tar -cf usropenwininclude.tar /usr/openwin/include && mv usropenwininclude.tar /export/pkgs/splunk
tar -cf usrdtinclude.tar /usr/dt/include && mv usrdtinclude.tar /export/pkgs/splunk
tar -cf usrx11include.tar /usr/X11/include && mv usrx11include.tar /export/pkgs/splunk
tar -cf usropenwinlib.tar /usr/openwin/lib && mv usropenwinlib.tar /export/pkgs/splunk
tar -cf usrdtlib.tar /usr/dt/lib && mv usrdtlib.tar /export/pkgs/splunk
tar -cf usrx11lib.tar /usr/X11/lib && mv usrx11lib.tar /export/pkgs/splunk

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
}

#Option2
#Relies on access to 192.168.61.132:\export/utilities-kdcprd/pkgs
reposetuplocal() {
    #create once on knpdbdm01, set all other root zones to use
    pkg install unzip
    cd /export/pkgs/repos
    unzip p31463805_1100_SOLARIS64.zip
    chmod +x install-repo.sh
    ./install-repo.sh -d /export/pkgs/repos/solsr
    #Fri July17 Waiting here for unpack to finish
}

repofix() {
    pkg set-publisher -G "*" -g /export/pkgs/repos/solsr solaris
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