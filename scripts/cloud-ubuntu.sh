#!/usr/bin/bash

#Deps for collectd: https://collectd.org/wiki/index.php/First_steps
#Deps for write_splunk: https://github.com/splunk/collectd-plugins
#Make a CC: https://www.cis.upenn.edu/~milom/cross-compile.html

TARGET=sparcv9-solaris2.11
PREFIX=/opt/cross
SYSROOT=$PREFIX/sysroot/
PATH=$PATH:$PREFIX/bin
REMOTE=35.171.161.127
PROFILE="/home/ubuntu/.profile"

housekeep() {
    #Done:
    apt-get update
    apt-get install build-essential
    apt-get install -y autoconf libtool pkg-config bison byacc flex
    apt-get install -y libyajl-dev libcurl4-openssl-dev

    usermod -a -G root ubuntu
    chown --recursive ubuntu:ubuntu /scratch
}

gccsparcv9() {
    (
    echo "TARGET=sparcv9-solaris2.11"
    echo "PREFIX=/opt/cross"
    echo "SYSROOT=$PREFIX/sysroot/"
    echo "PATH=$PATH:$PREFIX/bin:/usr/local/bin"
    )>> $PROFILE && source $PROFILE

    mkdir $PREFIX && mkdir $SYSROOT
    mv /home/ubuntu/*.tar $SYSROOT && cd $SYSROOT
    tar -xvf *.tar

    mkdir -p /scratch/users/build && cd /scratch/users/build

    wget http://ftp.gnu.org/gnu/texinfo/texinfo-6.7.tar.gz
    tar -zxvf texinfo-6.7.tar.gz
    mkdir build-texinfo cd build-texinfo
    ../texinfo-6.7/configure
    make all && make install

    wget http://ftp.gnu.org/gnu/binutils/binutils-2.34.tar.gz
    tar -zxvf binutils-2.34.tar.gz
    mkdir build-binutils && cd build-binutils
    ../binutils-2.34/configure -target=$TARGET --prefix=$PREFIX -with-sysroot=$SYSROOT -v
    make all && make install

    wget http://ftp.gnu.org/gnu/gcc/gcc-10.1.0/gcc-10.1.0.tar.gz
    tar -zxvf gcc-10.1.0.tar.gz
    mkdir build-gcc && cd build-gcc
    ../gcc-10.1.0/configure --target=$TARGET --with-gnu-as --with-gnu-ld  --prefix=$PREFIX -with-sysroot=$SYSROOT --disable-libgcj --enable-languages=c,c++ -v
    #Pickup here: https://gcc.gnu.org/install/prerequisites.html
    make all && make install
}

#Not done:
apt-get install libcurl libjvm libclntsh libnetsnmp libnetsnmpagent libperl libvirt libxml2
#http://developers.sun.com/solaris/
apt-get install librt libsocket libkstat libdevinfo