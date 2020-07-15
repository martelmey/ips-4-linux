#!/usr/bin/bash

housekeep() {
    sudo su - root
    cd ~/
    cp /oraclecloud/pkg.oracle.com.certificate.pem .
    cp /oraclecloud/pkg.oracle.com.key.pem .

    #Create PKCS of cert&key to obtain offline pkgs:
    #(Using dom. pass:)
    openssl pkcs12 -export -in /root/pkg.oracle.com.certificate.pem \
    -inkey /root/pkg.oracle.com.key.pem -out /root/pkg.oracle.com.p12

    cp /root/pkg.oracle.com.p12 /oraclecloud
}

reposetup() {
    pkg set-publisher -k /root/pkg.oracle.com.key.pem \
    -c /root/pkg.oracle.com.certificate.pem \
    -G "*" -g https://pkg.oracle.com/solaris/support/ solaris

    pkgadd -d http://get.opencsw.org/now
    PATH=/opt/csw/bin:$PATH
    export PATH
    pkgutil --catalog --upgrade pkgutil
}

depinstall() {
    pkg install bison git gcc unzip SUNWpkgcmds libtool autoconf automake pkg-config
}

collectdcsw() {
    pkgutil \
    --stream \
    --target=sparc:5.11 \
    --output /root/collectd_511.pkg \
    --yes \
    --download \
    collectd collectd_plugins_all collectd_dev libcurl4_feature
}

streamcsw() {
    local PKGNAME="cc-devhial1-csw.pkg"

    pkgutil \
    --stream \
    --target=sparc:5.11 \
    --output /root/"$PKGNAME" \
    --yes \
    --download \
    git bison automake autoconf gcc5core libtool pkgconfig

    #scp to jump1, goes to /export/pkgs/splunk from there
    cp /root/collectd_511.pkg /vagrant
    cp /root/cc-knpdb11-sparc.pkg /vagrant
    scp -P 2022 /vagrant/cc-knpdb11-sparc.pkg martel.meyers@65.110.171.190:/home/martel.meyers
    scp -P 2022 /vagrant/collectd_511.pkg martel.meyers@65.110.171.190:/home/martel.meyers
}

streamips() {
    local PKGNAME="cc-devhial1-ips.p5p"

    pkgrecv --newest \
    -s https://pkg.oracle.com/solaris/support/ \
    --key /root/pkg.oracle.com.key.pem \
    --cert /root/pkg.oracle.com.certificate.pem \
    -d /root/"$PKGNAME" -a \
    -r \
    developer/versioning/git \
    developer/gcc \
    developer/build/libtool \
    developer/build/pkg-config \
    SUNWpkgcmds

    cp /root/pkg-knpdb11-sparc.p5p /vagrant
    scp -P 2022 /vagrant/pkg-knpdb11-sparc.p5p martel.meyers@65.110.171.190:/home/martel.meyers
}

cccollectd() {
    #local on vagrant
    depinstall
    mkdir -p /root/git
    cd /root/git
    git clone https://github.com/splunk/collectd-plugins.git
    git clone https://github.com/collectd/collectd.git
    cd collectd && git checkout collectd-5.9
    cp -f ../collectd-plugins/src/* src/
    git apply ../collectd-plugins/add-splunk-plugins.patch
    ./build.sh
    ./configure \
    --build=x86_64-sun-solaris2.10 \
    --host=x86_64-sun-solaris2.10 \
    --target=sparc-sun-solaris2.10
    make
    #make check-TESTS
    make install
}

ipsclone() {
    pkg install package/pkg/depot
    mkdir /oraclecloud/repo && /oraclecloud/depot
    
    pkgrepo create /oraclecloud/repo
    pkgrepo -s /oraclecloud/repo set publisher/prefix=solsr
    pkgrecv -s https://pkg.oracle.com/solaris/support -d /oraclecloud/repo \
    --clone -p '*' --key /root/pkg.oracle.com.key.pem --cert /root/pkg.oracle.com.certificate.pem
    
    #man pkgrepo
    #pkgrepo info
    #pkgrepo list
    #pkgrepo verify
    #pkgrepo fix

    /usr/lib/pkg.depot-config -F -d solsr=/oraclecloud/repo -r /oraclecloud/depot
}

ipssetup() {
    #on NP-Util
    zfs create -o atime=off rpool/repo
    zfs create rpool/repo/solsr
    #reposync
    zfs snapshot rpool/repo/solsr@solsr-11_4_23_0_1_69_3
}