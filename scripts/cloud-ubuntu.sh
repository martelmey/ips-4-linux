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
    chown --recursive ubuntu:root $SYSROOT
    mkdir -p /scratch/users/build && cd /scratch/users/build
    chown --recursive ubuntu:root /scratch/users/build

    
    wget https://ips-4-lin-xgcc.s3.amazonaws.com/gcc-10.1.0-wreqs.tar.gz
    tar -zxvf gcc-10.1.0.tar.gz
    mkdir build-gcc && cd build-gcc
    # Build on Ubuntu, run on x86_Solaris, generate SPARC_Solaris bins
    #wget https://ips-4-lin-xgcc.s3.amazonaws.com/gcc-10.1.0-wreqs-4soldev.tar.gz
    ../gcc-10.1.0/configure --build=x86_64-linux-gnu \
     --host=x86_64-pc-solaris2.11 \
     --target=sparc-sun-solaris2.10 \
     --prefix=$PREFIX -with-sysroot=$SYSROOT

    #wget https://ips-4-lin-xgcc.s3.amazonaws.com/gcc-10.1.0-wreqs-4soldev2.tar.gz
    ../gcc-10.1.0/configure --build=x86_64-linux-gnu \
     --host=x86_64-pc-solaris2.11 \
     --target=sparc-sun-solaris2.10

    #checking for x86_64-pc-solaris2.11-readelf... no
    #checking for sparcv9-solaris2.11-cc... no

    #x86_64-pc-solaris2.11-ar rc ./libiberty.a \
    #./regex.o ./cplus-dem.o ./cp-demangle.o ./md5.o ./sha1.o ./alloca.o ./argv.o ./choose-temp.o ./concat.o ./cp-demint.o ./crc32.o ./d-demangle.o ./dwarfnames.o ./dyn-string.o ./fdmatch.o ./fibheap.o ./filedescriptor.o ./filename_cmp.o ./floatformat.o ./fnmatch.o ./fopen_unlocked.o ./getopt.o ./getopt1.o ./getpwd.o ./getruntime.o ./hashtab.o ./hex.o ./lbasename.o ./lrealpath.o ./make-relative-prefix.o ./make-temp-file.o ./objalloc.o ./obstack.o ./partition.o ./pexecute.o ./physmem.o ./pex-common.o ./pex-one.o ./pex-unix.o ./vprintf-support.o ./rust-demangle.o ./safe-ctype.o ./simple-object.o ./simple-object-coff.o ./simple-object-elf.o ./simple-object-mach-o.o ./simple-object-xcoff.o ./sort.o ./spaces.o ./splay-tree.o ./stack-limit.o ./strerror.o ./strsignal.o ./timeval-utils.o ./unlink-if-ordinary.o ./xasprintf.o ./xatexit.o ./xexit.o ./xmalloc.o ./xmemdup.o ./xstrdup.o ./xstrerror.o ./xstrndup.o ./xvasprintf.o  ./setproctitle.o
    #/bin/bash: x86_64-pc-solaris2.11-ar: command not found
    #Makefile:251: recipe for target 'libiberty.a' failed

    #prefix = /opt/cross
    #exec_prefix = ${prefix}
    #tooldir = ${exec_prefix}/sparcv9-solaris2.11
    #build_tooldir = ${exec_prefix}/sparcv9-solaris2.11

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