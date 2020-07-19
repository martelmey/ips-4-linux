#!/usr/bin/bash

#Two solutions for getting collectd metrics onto agents:
#(1) build on agents
#   (*) requires pkg to be working. csw stream won't build properly.
#(2) build & pkg locally, send to & install on agents
#   (*)

##########  ##########  ##########\/
####  ####  build collectd (source)
####        requires pkg to work
##########  ##########  ##########\/
pkgfix() {
    svcadm refresh svc:/application/pkg/zones-proxy-client:default

    chmod 600 /root/pkg.oracle.com.key.pem

    pkgadm addcert -n solsr -e /root/pkg.oracle.com.key.pem \
    /root/pkg.oracle.com.certificate.pem

    pkg update --accept
    pkg install git gcc unzip SUNWpkgcmds libtool autoconf automake pkg-config
}

#cp'd to zone-root
buildcollectd() {
    cp /export/pkgs/splunk/sparc-collectd.tar .
    tar -xvf sparc-collectd.tar && cd collectd
    ./build.sh
    ./configure \
    --build=sparc-sun-solaris2.10 \
    --host=sparc-sun-solaris2.10 \
    --target=sparc-sun-solaris2.10
    make
    #Errors start here - Tues July14
    #Was using csw stream - might be the reason
    #Retry once repo is fixed
    #Try this on zone-root
}

##########  ##########  ##########\/
####  ####  install collectd (pkg)
####        may not require pkg to work (built & pkg'd offline - installed on agent)
##########  ##########  ##########\/

installcollectd() {
    #port to installAgent.sh once complete!
}