#!/bin/bash

    ##ol7-splunk-indx
#   cd ~/
#   ssh -i .ssh/ssh-key-2020-07-11.key opc@132.145.189.27

    #housekeeping
    yum update

    # \/ TRIAL July-11-Sat
    #write_splunk cross-compile
yum -y install git gcc
mkdir -p /root/git && cd /root/git
git clone https://github.com/splunk/collectd-plugins.git
git clone https://github.com/collectd/collectd.git
cd collectd && git checkout collectd-5.9
cp -f ../collectd-plugins/src/* src/
git apply ../collectd-plugins/add-splunk-plugins.patch
./build.sh && ./configure --build=x86_64-sun-solaris2.10 --host=x86_64-sun-solaris2.10 --target=sparc-sun-solaris2.10 && make

    #splunk
SPLUNKTAR=splunk.tgz
SPLUNKURL='https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.5&product=splunk&filename=splunk-8.0.5-a1a6394cc5ae-Linux-x86_64.tgz&wget=true'
wget -O "$SPLUNKTAR" "$SPLUNKURL"
tar -zxvf "$SPLUNKTAR" -C /opt
chown --recursive splunk:splunk /opt/splunk/
    #Create splunk user
    #REMINDER - add via visudo %wheel NOPASSWD=ALL
useradd splunk -d /home/splunk
usermod -G splunk,wheel splunk
    #Open ports
#firewall-cmd --list-all-zones
firewall-cmd --permanent --zone=public --add-port=8088/tcp
firewall-cmd --permanent --zone=public --add-port=8089/tcp
firewall-cmd --permanent --zone=public --add-port=9997/tcp
    #Create cronjobs
mkdir -p /root/splunk-scripts
touch /root/splunk-scripts/assertSplunkPermits.sh
(
    echo "#!/bin/bash"
    echo "chown --recursive splunk:splunk /opt/splunk/"
)>/root/splunk-scripts/assertSplunkPermits.sh
chmod +x /root/splunk-scripts/assertSplunkPermits.sh
    #Add cronjobs to root
touch /var/spool/cron/root
echo "0 0/2 0 ? * * * /root/splunk-scripts/assertSplunkPermits.sh" > /var/spool/cron/root
    #Create splunk-launch.conf
touch /opt/splunk/etc/splunk-launch.conf
(
    echo "SPLUNK_SERVER_NAME=Splunkd"
    echo "SPLUNK_OS_USER=splunk"
)>/opt/splunk/etc/splunk-launch.conf
    #Create user-seed.conf
touch /opt/splunk/etc/system/local/user-seed.conf
(
    echo "[user_info]"
    echo "USERNAME = splunkadmin"
    echo "PASSWORD = hialplissplunk"
)>/opt/splunk/etc/local/user-seed.conf
/opt/splunk/bin/./splunk enable boot-start -user splunk