#!/usr/bin/bash

UDEV="x86_64-linux-gnu"
SOLDEV="x86_64-pc-solaris2.11"
HIAL="sparcv9-solaris2.11"

sudo yum update
sudo yum group install "Development Tools" \
    wget 
whereis gcc
# Expected:
#   gcc: /usr/bin/gcc /usr/lib/gcc /usr/libexec/gcc /usr/share/man/man1/gcc.1.gz
# Result:
#   gcc: /usr/bin/gcc /usr/lib/gcc /usr/libexec/gcc /usr/share/man/man1/gcc.1.gz /usr/share/info/gcc.info.gz
gcc --version
# Expected:
#   gcc (GCC) 4.8.2 20140120 (Red Hat 4.8.2-16)
# Result:
#   gcc (GCC) 8.3.1 20191121 (Red Hat 8.3.1-5)
cd ~/
wget https://ips-4-lin-xgcc.s3.amazonaws.com/gcc-10.1.0-wreqs.tar.gz
tar -zxvf gcc-10.1.0-wreqs.tar.gz
mkdir build-gcc && cd build-gcc
../gcc-10.1.0/configure --build="" \
--host="" --target="" \
-mcpu=v9 -m64

# --enable-ld[=yes,no]