#!/usr/bin/bash

#Deps for collectd: https://collectd.org/wiki/index.php/First_steps
#Deps for write_splunk: https://github.com/splunk/collectd-plugins
#Make a CC: https://www.cis.upenn.edu/~milom/cross-compile.html

BUILD=x86_64-linux-gnu
HOST=x86_64-linux-gnu
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
    chown --recursive opc:staff $SYSROOT

    mkdir -p /scratch/users/build && cd /scratch/users/build
    chown --recursive opc:staff /scratch/users/build

    # https://gcc.gnu.org/install/prerequisites.html
    wget http://ftp.gnu.org/gnu/texinfo/texinfo-6.7.tar.gz
    tar -zxvf texinfo-6.7.tar.gz
    mkdir build-texinfo cd build-texinfo
    ../texinfo-6.7/configure --host=$TARGET --prefix=$PREFIX -with-sysroot=$SYSROOT -v
    make all && make install

    wget http://ftp.gnu.org/gnu/binutils/binutils-2.34.tar.gz
    tar -zxvf binutils-2.34.tar.gz
    mkdir build-binutils && cd build-binutils
    ../binutils-2.34/configure -target=$TARGET --prefix=$PREFIX -with-sysroot=$SYSROOT -v
    make all && make install

    wget https://gmplib.org/download/gmp/gmp-6.2.0.tar.xz
    wget https://gcc.gnu.org/pub/gcc/infrastructure/gmp-6.1.0.tar.bz2
    bunzip2 gmp-6.1.0.tar.bz2
    tar -xvf gmp-6.1.0.tar
    cd gmp-6.1.0
    ../gmp-6.1.0/configure -target=$TARGET --prefix=$PREFIX -with-sysroot=$SYSROOT -v
    make
    make check
    make install
    ldconfig

    # https://www.mpfr.org/mpfr-current/mpfr.html#Installing-MPFR
    wget https://www.mpfr.org/mpfr-current/mpfr-4.1.0.tar.bz2
    bunzip2 mpfr-4.1.0.tar.bz2
    tar -xvf mpfr-4.1.0.tar
    cd mpfr-4.1.0
    ./configure --with-gmp-include=/usr/local/include --with-gmp-lib=/usr/local/lib
    make
    make check
    make install
    ldconfig

    wget https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz
    tar -zxvf mpc-1.1.0.tar.gz
    cd mpc-1.1.0
    ./configure --with-gmp-include=/usr/local/include --with-gmp-lib=/usr/local/lib \
    --with-mpfr-include=/usr/local/include --with-mpfr-lib=/usr/local/lib
    make
    make check
    make install
    ldconfig

    wget http://ftp.gnu.org/gnu/gcc/gcc-10.1.0/gcc-10.1.0.tar.gz
    tar -zxvf gcc-10.1.0.tar.gz
    cd gcc-10.1.0
    ./contrib/download_prerequisites
    cd ..
    mkdir build-gcc && cd build-gcc
    
    ../gcc-10.1.0/configure

    ../gcc-10.1.0/configure --target=$TARGET --with-gnu-as --with-gnu-ld  \
    --prefix=$PREFIX -with-sysroot=$SYSROOT --disable-libgcj --enable-languages=c,c++\
    --with-mpc=/usr/local --with-mpfr=/usr/local --with-gmp=/usr/local -v 

    ../gcc-10.1.0/configure --target=$TARGET --with-gnu-as --with-gnu-ld  \
    --prefix=$PREFIX -with-sysroot=$SYSROOT --disable-libgcj --enable-languages=c,c++ -v
    
    make all && make install
}

#Not done:
apt-get install libcurl libjvm libclntsh libnetsnmp libnetsnmpagent libperl libvirt libxml2
#http://developers.sun.com/solaris/
apt-get install librt libsocket libkstat libdevinfo