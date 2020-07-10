#!/usr/bin/bash
#ssh -i ssh-key-2020-07-10.key opc@150.136.183.223
#scp -i ~/.ssh/ssh-key-2020-07-10.key pkg.oracle.com.certificate.pem opc@150.136.183.223:/export/home/opc
#scp -i ~/.ssh/ssh-key-2020-07-10.key pkg.oracle.com.key.pem opc@150.136.183.223:/export/home/opc
#mv /export/home/opc/* /root

pkg set-publisher -k pkg.oracle.com.key.pem -c pkg.oracle.com.certificate.pem -G "*" -g https://pkg.oracle.com/solaris/support/ solaris
pkg update --accept

zfs create rpool/export/repoSolaris11