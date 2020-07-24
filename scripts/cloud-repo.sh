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
OCIAPI="https://iaas.us-ashburn-1.oraclecloud.com"
SOLSTUDIO="/opt/developerstudio12.6/bin/devstudio"
GCC_SRCDIR=/scratch/users/build/gcc-10.1.0
#CONFIG_SHELL=/bin/ksh
#export CONFIG_SHELL

housekeep() {
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

    pkg install bison git gcc unzip SUNWpkgcmds libtool autoconf pkg-config wget zip developerstudio-126 \
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
    x11/header 
}

$SOLSTUDIO &

gccsparcv9() {
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
    
    #checking whether the C compiler works... no
    #configure: error: in `/export/home/opc/build-gcc':
    #configure: error: C compiler cannot create executables

    #configure:4465: checking whether the C compiler works
    #configure:4487: gcc    conftest.c  >&5
    #ld: fatal: library -lgcc: not found

    ../gcc-10.1.0/./configure --build=x86_64-sun-solaris2.10 \
    --host=x86_64-sun-solaris2.10 \
    --target=sparc-sun-solaris2.10

}

collectdcc() {
    wget https://ips-4-lin-xgcc.s3.amazonaws.com/collectd-5.9-wpatch.tar.gz
    tar -zxvf collectd-5.9-wpatch.tar.gz
    cd collectd
    ./build.sh

    #aclocal not found

    ./configure --build=x86_64-pc-solaris2.11 --host=x86_64-pc-solaris2.11 --target=sparc-sun-solaris2.11
    make
    make check-TESTS
    make install
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