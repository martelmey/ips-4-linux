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
BUILDIR="/scratch/users/build"

housekeep() {
    apt update
    apt install build-essential
    apt install -y autoconf libtool pkg-config bison byacc flex binutils
    apt install -y libyajl-dev libcurl4-openssl-dev

    usermod -a -G root ubuntu
    mkdir "$BUILDIR"
    chown --recursive ubuntu:ubuntu /scratch/
}

gccsparcv9() {
    (
    echo "TARGET=sparcv9-solaris2.11"
    echo "PREFIX=/opt/cross"
    echo "SYSROOT=$PREFIX/sysroot/"
    echo "PATH=$PATH:$PREFIX/bin:/usr/local/bin"
    )>> $PROFILE && source $PROFILE

    mkdir $PREFIX && mkdir $SYSROOT
    cd ~/
    wget https://ips-4-lin-xgcc.s3.amazonaws.com/headers_knpdbdm01.tar.gz
    mv ~/headers_knpdbdm01.tar.gz $SYSROOT && cd $SYSROOT
    tar -zxvf headers_knpdbdm01.tar.gz
    mkdir -p /bru
    mv headers_knpdbdm01.tar.gz /bru/
    cd headers_knpdbdm01
    mv *.tar ../
    cd ../
    rm -rf headers_knpdbdm01/
    tar -xvf lib.tar
    tar -xvf usrdtinclude.tar
    tar -xvf usrdtlib.tar
    tar -xvf usrinclude.tar
    tar -xvf usrlib.tar
    tar -xvf usrlocalinclude.tar
    tar -xvf usrlocallib.tar
    tar -xvf usropenwininclude.tar
    tar -xvf usropenwinlib.tar
    tar -xvf usrx11include.tar
    tar -xvf usrx11lib.tar
    chown --recursive ubuntu:root $SYSROOT
    mkdir -p /scratch/users/build && cd /scratch/users/build
    chown --recursive ubuntu:root /scratch/users/build

    wget https://ips-4-lin-xgcc.s3.amazonaws.com/gcc-10.1.0-wreqs.tar.gz
    tar -zxvf gcc-10.1.0-wreqs.tar.gz
    mkdir build-gcc && cd build-gcc
# \/ Build on Ubuntu, run on x86_Solaris, generate SPARC_Solaris bins
# \/ Done: 20:19.July23Thur
    ../gcc-10.1.0/configure --build=x86_64-linux-gnu \
     --host=x86_64-pc-solaris2.11 \
     --target=sparc-sun-solaris2.10 \
     --prefix=$PREFIX -with-sysroot=$SYSROOT
# \/ Use gcc -dumpmachine from hial
# \/ Done: 
    ../gcc-10.1.0/configure --build=x86_64-linux-gnu \
     --host=x86_64-pc-solaris2.11 \
     --target=sparcv9-solaris2.11 \
     --prefix=$PREFIX -with-sysroot=$SYSROOT
# \/ Use gcc -dumpmachine from hial
# \/ Subtract --host
# \/ Done: 23:45.July23Thur
# checking host system type... sparcv9-unknown-solaris2.11
# checking for suffix of object files... configure: error: in `/scratch/users/build/build-gcc/sparcv9-solaris2.11/libgcc':
# configure: error: cannot compute suffix of object files: cannot compile
    ../gcc-10.1.0/configure --build=x86_64-linux-gnu \
     --target=sparcv9-solaris2.11 \
     --prefix=$PREFIX -with-sysroot=$SYSROOT
# \/ Use sparc-sun-solaris2.10 w/ --host
# \/ Done: 06:28.July24Fri
# *** Configuration sparc-sun-solaris2.10 not supported
    ../gcc-10.1.0/configure --build=x86_64-linux-gnu \
     --target=sparc-sun-solaris2.10 \
     --prefix=$PREFIX -with-sysroot=$SYSROOT

    sudo apt-get install pkg-config-sparc64-linux-gnu \
    llvm-10 \
    linux-libc-dev-sparc64-cross \
    libubsan1-dbg-sparc64-cross \
    libubsan1-sparc64-cross \
    libstdc++-8-dev-sparc64-cross \
    libstdc++-8-pic-sparc64-cross \
    libobjc-8-dev-sparc64-cross \
    libobjc4-dbg-sparc64-cross \
    libobjc4-sparc64-cross \
    libgcc-8-dev-sparc64-cross \
    libgcc1-dbg-sparc64-cross \
    libgcc1-sparc64-cross \
    libc6-sparc64-cross \
    libc6-dev-sparc64-cross \
    libc6-dbg-sparc64-cross \
    gcc-sparc64-linux-gnu \
    gcc-multilib-sparc64-linux-gnu \
    gcc-8-sparc64-linux-gnu-base \
    gcc-8-sparc64-linux-gnu \
    gcc-8-multilib-sparc64-linux-gnu \
    g++-sparc64-linux-gnu \
    g++-multilib-sparc64-linux-gnu \
    g++-8-sparc64-linux-gnu \
    g++-8-multilib-sparc64-linux-gnu \
    cpp-sparc64-linux-gnu \
    binutils-sparc64-linux-gnu-dbg \
    binutils-sparc64-linux-gnu \
    arch-test

    ../gcc-10.1.0/configure --build=x86_64-linux-gnu \
     --target=sparcv9-solaris2.11

    # checking for suffix of object files... configure: error: in `/scratch/users/build/build-gcc/sparcv9-solaris2.11/libgcc':
    # configure: error: cannot compute suffix of object files: cannot compile

    sudo apt install libgfortran5-sparc64-cross \
    libgfortran5-dbg-sparc64-cross \
    libgfortran-8-dev-sparc64-cross \
    libatomic1-sparc64-cross \
    libatomic1-dbg-sparc64-cross \
    libasan5-sparc64-cross \
    libasan5-dbg-sparc64-cross \
    libsys-mmap-perl \
    libitm1-dbg-sparc64-cross \
    libgomp1-dbg-sparc64-cross \
    libgo13-dbg-sparc64-cross \
    libgo13-sparc64-cross \
    gobjc-8-sparc64-linux-gnu \
    gobjc-8-multilib-sparc64-linux-gnu \
    gobjc++-8-sparc64-linux-gnu \
    gobjc++-8-multilib-sparc64-linux-gnu \
    gfortran-8-sparc64-linux-gnu \
    gfortran-8-multilib-sparc64-linux-gnu \
    gdc-8-sparc64-linux-gnu \
    gdc-8-multilib-sparc64-linux-gnu \
    gccgo-8-sparc64-linux-gnu \
    gccgo-8-multilib-sparc64-linux-gnu \
    gcc-8-plugin-dev-sparc64-linux-gnu

    ../gcc-10.1.0/configure --build=x86_64-linux-gnu \
     --target=sparcv9-solaris2.11

    # checking for suffix of object files... configure: error: in `/scratch/users/build/build-gcc/sparcv9-solaris2.11/libgcc':
    # configure: error: cannot compute suffix of object files: cannot compile
    # \/ re-run w/ $PREFIX & $SYSROOT

    ../gcc-10.1.0/configure --build=x86_64-linux-gnu \
     --target=sparcv9-solaris2.11 \
     --prefix=$PREFIX -with-sysroot=$SYSROOT

    # configure: error: cannot compute suffix of object files: cannot compile
    # See `config.log' for more details
    # Makefile:14569: recipe for target 'configure-target-libgcc' failed

    ../gcc-10.1.0/configure --build=x86_64-linux-gnu \
     --host=x86_64-linux-gnu \
     --target=sparcv9-solaris2.11 \
     --with-nan-emulation \
     --prefix=$PREFIX -with-sysroot=$SYSROOT 

    make all && make install
}

#Not done:
apt-get install libcurl libjvm libclntsh libnetsnmp libnetsnmpagent libperl libvirt libxml2
#http://developers.sun.com/solaris/
apt-get install librt libsocket libkstat libdevinfo