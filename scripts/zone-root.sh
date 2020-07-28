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
tar -cd usrlocallib.tar /usr/local/lib && mv usrlocallib.tar /export/pkgs/splunk
tar -cd usrlocalinclude.tar /usr/local/include && mv usrlocalinclude.tar /export/pkgs/splunk

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

    sudo pkg set-publisher \
    -k /root/pkg.oracle.com.key.pem \
    -c /root/pkg.oracle.com.certificate.pem \
    -G "*" -g https://pkg.oracle.com/solarisstudio/release \
    --proxy http://192.168.60.250:8008 solarisstudio
}

reposetuplocal() {
    pkg install unzip
    cd /export/pkgs/repos
    unzip p31463805_1100_SOLARIS64.zip
    chmod +x install-repo.sh
    ./install-repo.sh -d /export/pkgs/repos/solsr
}

repofix() {
    # Change request:
    # (1) Correct publisher
    # (2) Configure svc:/pkg/mirror
    pkg set-publisher -k /root/pkg.oracle.com.key.pem \
    -c /root/pkg.oracle.com.certificate.pem \
    -G "*" -g https://pkg.oracle.com/solaris/support/ \
    --proxy http://192.168.60.250:8008 solaris

    svcadm enable mirror:default
}

installdeps() {
    pkg update --accept
    pkg install -–accept developerstudio-126
    PATH=/opt/developerstudio12.6/bin:$PATH
    export PATH
    MANPATH=/opt/developerstudio12.6/man:$MANPATH
    export MANPATH
    pkg install git \
    developer/build/ant \
    developer/build/automake \
    developer/build/gnu-make \
    developer/build/pkg-config \
    developer/dtrace/toolkit \
    developer/debug/gdb \
    developer/debug/mdb \
    developer/java/jdk \
    developer/gcc-48 \
    developer/lexer/flex \
    group/feature/developer-gnu \
    runtime/perl-512 \
    system/header \
    x11/header \
    bison \
    SUNWpkgcmds \
    libtool \
    autoconf \
    pkg-config \
    wget \
    zip \
    flex

    echo "usr/perl5/5.22/bin" >> ~/.profile && source ~/.profile
    export NM=/usr/bin/gnm
}

# wget https://ips-4-lin-xgcc.s3.amazonaws.com/collectd-5.9-wpatch.tar.gz
buildcollectd() {
    pkg install bison gcc SUNWpkgcmds libtool autoconf automake pkg-config flex runtime/perl-526@5.26.2
    cd /export/home/martel.meyers/build
    cp /export/pkgs/splunk/collectd-5.9-wpatch.tar.gz .
    tar -xvf collectd-5.9-wpatch.tar.gz && cd collectd
    ./build.sh
    NM=/usr/bin/gnm PERL=/usr/perl5/5.26/bin/perl ./configure \
    --with-gnu-ld \
    --disable-perl \
    --disable-python

    # remove global-pipe from libtool: export_symbols_cmds=
    gmake
    gmake install

    # Generate package
    cd ~/ && mkdir proto && mkdir solaris-reference
    cd proto && cp -r /opt/collectd . && cd ../
    pkgsend generate proto | pkgfmt > collectd-splunk-sparc.p5m.1

    (
        echo "set name=pkg.fmri value='collectd@5.9.1'"
        echo "set name=pkg.description value='Collectd 5.9 compiled for SPARC w/ write_splunk'"
        echo "set name=pkg.summary value='Collectd SPARC'"
        echo "set name=variant.arch value='sparc'"
        echo "set name=info.classification value='org.opensolaris.category.2008:Applications/Accessories'"
    )>>collectd-splunk-sparc.p5m.1

    # Get & resolve package deps
    pkgdepend generate -md proto collectd-splunk-sparc.p5m.1 | pkgfmt > collectd-splunk-sparc.p5m.3
    pkgdepend resolve -m collectd-splunk-sparc.p5m.3

    # Create hialplis-ports
    cd /export/pkgs/repos
    mkdir cache
    pkgrepo create hialplis-ports
    pkgrepo -s hialplis-ports set publisher/prefix=hialplis-ports

    # Copy deps
    http_proxy=http://192.168.60.250:8008 pkgrecv -s https://pkg.oracle.com/solaris/support/ \
    -d hialplis-ports -c cache -m all-versions \
    --key ~/pkg.oracle.com.key.pem \
    --cert ~/pkg.oracle.com.certificate.pem \
    -r developer/base-developer-utilities library/libidn2 library/libssh2 library/libxml2 library/nghttp2 library/security/libgpg-error \
    library/security/openssl library/zlib security/kerberos-5 system/library/libpcap system/library/math \
    system/library/security/libgcrypt system/library system/management/snmp/net-snmp system/network/ldap/openldap web/curl

    # Verify package & deps
    cd /export/home/martel.meyers
    http_proxy=http://192.168.60.250:8008 pkglint -c ./solaris-reference -r https://pkg.oracle.com/solaris/support/ collectd-splunk-sparc.p5m.3.res
    pkgesend -s /export/pkgs/repos/hialplis-ports publish -d proto collectd-splunk-sparc.p5m.3.res
    pkgrepo verify -s hialplis
    pkgsign -s hialplis -a sha256 '*'
}

# wget https://ips-4-lin-xgcc.s3.amazonaws.com/gcc-10.1.0-wreqs.tar.gz
buildgcc() {
    # Build on SPARC
    # Make GCC, compiles SPARC code on x86_64-PC-Solaris2.11
    cd /home/martel.meyers
    cp cp /export/pkgs/splunk/gcc-10.1.0-wreqs.tar.gz .
    tar -xvf gcc-10.1.0-wreqs.tar.gz
    mkdir build-gcc

    ../gcc-10.1.0/configure --host x86_64-pc-solaris2.11 \
    --build sparcv9-solaris2.11 --target sparcv9-solaris2.11 \
    --with-nan-emulation \
    --with-fp-layout
}