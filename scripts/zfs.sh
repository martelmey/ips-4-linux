#!/usr/bin/bash

IP="192.168.60.211"
HOST="kutlprdsplunk01.np.health.local"
FS="utilities-splunk/*indx"
MOUNTPOINT="/export/utilities-splunk/*indx"
LOCALMOUNT="/export/*indx"
SHARENFS=
QUOTA=100
COMPRESSION=
ROOT_USER=1002
ROOT_GROUP=1002

zfs create -o atime=off rpool/repos
zfs create rpool/repos/solsr
zfs share -o share.nfs=on rpool/repos/%solsr

#grep repo /etc/dfs/sharetab
#   /var/share/pkgrepos     ipsrepo nfs     sec=sys,rw
#dfshares
#   RESOURCE                           SERVER ACCESS  TRANSPORT
#   solaris:/var/share/pkgrepos    solaris  -       -

zfs snapshot rpool/repos/solsr@solsr-11_4_23_0_1_69_3

#===
zfs mount -a
zonecfg   add  dataset
zonecfg  add device
#===

#zfs_share(8)