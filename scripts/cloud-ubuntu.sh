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

#Done:
apt-get update
apt-get install build-essential
apt-get install -y autoconf libtool pkg-config bison byacc flex
apt-get install -y libyajl-dev libcurl4-openssl-dev
mv /home/ubuntu/*.tar $SYSROOT && cd $SYSROOT
tar -xvf *.tar

(
    echo "TARGET=sparcv9-solaris2.11"
    echo "PREFIX=/opt/cross"
    echo "SYSROOT=$PREFIX/sysroot/"
    echo "PATH=$PATH:$PREFIX/bin"
)>> $PROFILE && source $PROFILE

mkdir $PREFIX && mkdir $SYSROOT

#Not done:
apt-get install libcurl libjvm libclntsh libnetsnmp libnetsnmpagent libperl libvirt libxml2
#http://developers.sun.com/solaris/
apt-get install librt libsocket libkstat libdevinfo