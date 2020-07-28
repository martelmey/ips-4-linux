#!/usr/bin/bash

BUILD=x86_64-pc-solaris2.11
HOST=x86_64-pc-solaris2.11
TARGET=sparcv9-solaris2.11
REMOTE=150.136.102.55
PROFILE=/export/home/opc
PKGKEY="/root/pkg.oracle.com.key.pem"
PKGCERT="/root/pkg.oracle.com.certificate.pem"
SSHKEY="~/.ssh/ssh-key-2020-07-17.key"
LOCALES="/usr/lib/locale/<locale-name>/<localename>"
LOCALE="C"
SOLSTUDIO="/opt/developerstudio12.6/bin/devstudio"\

installdeps() {
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

    pkg update --accept
    PATH=/opt/developerstudio12.6/bin:$PATH
    export PATH
    MANPATH=/opt/developerstudio12.6/man:$MANPATH
    export MANPATH

    pkg install \
    bison \
    git \
    gcc \
    unzip \
    SUNWpkgcmds \
    libtool \
    autoconf \
    pkg-config \
    wget \
    developerstudio-126 \
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
    system/header \
    x11/header \
    library/ncurses \
    developer/gnu-binutils-cross-sparc \
    developer/gnu-binutils \
    developer/gcc/gcc-c++-9 \
    developer/gcc/gcc-common-9 \
    developer/macro/cpp \
    text/gnu-patch \
    system/core-os \
    network/rsync \
    runtime/perl-526 \
    runtime/perl-common

    cd /usr/bin/aclocal
    cp aclocal-1.15 aclocal-1.15.bak
    mv aclocal-1.15 aclocal

    # /usr/gcc/9/bin
    # /usr/lib/
    # /opt/developerstudio12.6/bin
    # /opt/developerstudio12.6/lib
    # /usr/gnu/sparcv9-sun-solaris2.11/bin
    # /usr/gnu/sparcv9-sun-solaris2.11/lib
    # /usr/gnu/x86_64-pc-solaris2.11/bin
    # /usr/gnu/x86_64-pc-solaris2.11/lib
    # /opt/cross/sysroot/usr/include
    # /opt/cross/sysroot/usr/lib
    # /opt/cross/sysroot/lib

    # /usr/share/automake-1.15
}

buildroot() {
    # not-as root
    wget https://buildroot.org/downloads/buildroot-2020.05.tar.gz
    tar -zxvf buildroot-2020.05.tar.gz && cd buildroot-2020.05
    make menuconfig
    make
}

buildgcc() {
    (
    echo "TARGET=sparcv9-solaris2.11"
    echo "PREFIX=/opt/cross"
    echo "SYSROOT=$PREFIX/sysroot/"
    echo "PATH=$PATH:$PREFIX/bin"
    )>> $PROFILE && source $PROFILE

    mkdir $PREFIX && mkdir $SYSROOT
    cd /export/home/opc
    mv *.tar $SYSROOT
    cd $SYSROOT
    tar -xvf *.tar
    chown --recursive opc:staff $SYSROOT
    mkdir /scratch/users/build
    chown --recursive opc:staff /scratch/users/build
    cd /scratch/users/build

    wget https://ips-4-lin-xgcc.s3.amazonaws.com/gcc-10.1.0-wreqs.tar.gz
    tar -zxvf gcc-10.1.0.tar.gz
    mkdir build-gcc && cd build-gcc
    # Build on x86_Solaris, run on x86_Solaris, generate SPARC_Solaris bins
    ../gcc-10.1.0/configure --build=x86_64-pc-solaris2.11 \
     --host=x86_64-pc-solaris2.11 \
     --target=sparcv9-solaris2.11 \
     --prefix=$PREFIX -with-sysroot=$SYSROOT \
     --with-gnu-as --with-gnu-ld
}

buildcollectd() {
    wget https://ips-4-lin-xgcc.s3.amazonaws.com/collectd-5.9-wpatch.tar.gz
    tar -zxvf collectd-5.9-wpatch.tar.gz
    cd collectd
    ./build.sh
    ./configure --build=x86_64-pc-solaris2.11 \
    --host=x86_64-pc-solaris2.11 \
    --target=sparc-sun-solaris2.11
    make
    make check-TESTS
    make install
    
    pkglint -c ./solaris-reference -r http://pkg.oracle.com/solaris/release collectd-splunk-sparc.p5m.3.res
}

repo () {
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
}