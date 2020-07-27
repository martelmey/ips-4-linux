#!/usr/bin/bash

IP=3.82.130.117
RDEV="x86_64-redhat-linux"
UDEV="x86_64-linux-gnu"
SOLIDEV="x86_64-pc-solaris2.11"
SOLSDEV="sparcv9-solaris2.11"
JDK_HOME="/usr/java/jdk-14.0.2/bin/java"

installdeps() {
    # as root
    # Tools
    sudo su - root
    yum update
    yum group install "Development Tools"
    yum install \
    wget which sed make binutils  \
    gcc  bash patch gzip bzip2 perl tar \
    cpio unzip rsync file bc python38 \
    glib2 gtk2  git asciidoc ncurses ncurses-libs \
    ncurses-c++-libs ncurses-compat-libs ncurses-devel \
    curl libcurl python3-pycurl libcurl-devel
    # Java
    wget https://ips-4-lin-xgcc.s3.amazonaws.com/jdk-14.0.2_linux-x64_bin.rpm
    rpm --install jdk-14.0.2_linux-x64_bin.rpm
    exit
}

sources () {
    # GCC
    wget https://ips-4-lin-xgcc.s3.amazonaws.com/gcc-10.1.0-wreqs.tar.gz
    #wget https://ips-4-lin-xgcc.s3.amazonaws.com/gcc-10.1.0-wreqs-bin.tar.gz
    tar -zxvf gcc-10.1.0-wreq-bin.tar.gz && mkdir build-gcc && cd build-gcc
    ../gcc-10.1.0/configure --build=x86_64-redhat-linux --host=x86_64-redhat-linux --target=sparcv9-solaris2.11

    # Collectd
    wget https://ips-4-lin-xgcc.s3.amazonaws.com/collectd-5.9-wpatch.tar.gz
    tar -zxvf collectd-5.9-wpatch.tar.gz && cd collectd
    ./build
    ./configure --build=x86_64-redhat-linux \
    --host=sparcv9-solaris2.1 \
    --with-nan-emulation \
    --with-sysroot=/opt/cross/sysroot
}

buildroot() {
    # not-as root
    wget https://buildroot.org/downloads/buildroot-2020.05.tar.gz
    tar -zxvf buildroot-2020.05.tar.gz && cd buildroot-2020.05
    make menuconfig
    make
}

jenkins () {
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    yum install jenkins
    sudo systemctl start jenkins
    firewall-cmd --permanent --new-service=jenkins
    firewall-cmd --service=jenkins --set-short="Jenkins ports"
    firewall-cmd --service=jenkins --set-description="Jenkins port exceptions"
    firewall-cmd --service=jenkins --add-port=8080/tcp
    firewall-cmd --permanent --add-service=jenkins
    firewall-cmd --zone=public --add-service=http --permanent
    firewall-cmd --reload
}