#!/usr/bin/bash

    ## LOCAL (wls-ubuntu) (Thinkpad)
#   cd ~/
#   chmod 700 .ssh
#   chmod 644 .ssh/ssh-key-*.key.pub
#   chmod 600 .ssh/ssh-key-*.key
#   ssh -i .ssh/ssh-key-2020-07-11.key opc@129.213.99.223
#   cd /mnt/c/Users/MXANA/Desktop/oraclecloud
#   scp -i ~/.ssh/ssh-key-2020-07-11.key pkg.oracle.com.certificate.pem opc@129.213.99.223:/export/home/opc
#   scp -i ~/.ssh/ssh-key-2020-07-11.key pkg.oracle.com.key.pem opc@129.213.99.223:/export/home/opc
#   scp -i ~/.ssh/ssh-key-2020-07-11.key sol-11_4-repo_1of5.zip opc@129.213.99.223:/export/home/opc
#   scp -i ~/.ssh/ssh-key-2020-07-11.key sol-11_4-repo_2of5.zip opc@129.213.99.223:/export/home/opc
#   scp -i ~/.ssh/ssh-key-2020-07-11.key sol-11_4-repo_3of5.zip opc@129.213.99.223:/export/home/opc
#   scp -i ~/.ssh/ssh-key-2020-07-11.key sol-11_4-repo_4of5.zip opc@129.213.99.223:/export/home/opc
#   scp -i ~/.ssh/ssh-key-2020-07-11.key sol-11_4-repo_5of5.zip opc@129.213.99.223:/export/home/opc
#   scp -i ~/.ssh/ssh-key-2020-07-11.key install-repo.ksh opc@129.213.99.223:/export/home/opc
#   scp -i ~/.ssh/ssh-key-2020-07-11.key sol-11_4-repo_digest.txt opc@129.213.99.223:/export/home/opc

    #migrate downloaded files from local machine
    #setup support repo & install deps
cdd ~/
mv /export/home/opc/* .
pkg set-publisher -k pkg.oracle.com.key.pem -c pkg.oracle.com.certificate.pem -G "*" -g https://pkg.oracle.com/solaris/support/ solaris
pkg update --accept
pkg install git
pkg install gcc
pkg install unzip

    ## DEV-TST-SCENARIO=1:
    #write_splunk cross-compile
mkdir -p /root/git
cd /root/git
git clone https://github.com/splunk/collectd-plugins.git
git clone https://github.com/collectd/collectd.git
cd collectd && git checkout collectd-5.11
cp ../collectd-plugins/src/* src/
    # \/ July-11-Sat does not appear to work on Solaris? Try after installing gcc > Try on ol7 
    # \/ failure on the ./build.sh line below it, too...
    # \/ failure after installing gcc
git apply ../collectd-plugins/add-splunk-plugins.patch
./build.sh && ./configure --build=x86_64-sun-solaris2.10 --host=x86_64-sun-solaris2.10 --target=sparc-sun-solaris2.10 && make
#make check-TESTS
make install

    ## DEV-TST-SCENARIO=2:
    #local solaris support repo demo
chmod +x install-repo.ksh
zfs create -o atime=off rpool1/export/repoSolaris11
#zfs get atime rpool/export/repoSolaris11
mkdir -p /export/repoSolaris11/solaris
./install-repo.ksh -d /export/repoSolaris11/solaris -c -v -I
zfs snapshot rpool/export/repoSolaris11/solaris@sol-11_4