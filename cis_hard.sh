#!/bin/sh
# CIS Hardening Script for Ubuntu 16.04 LTS v0.1

# Set http and https proxies for TCH
# echo export http_proxy="http://ladczproxy.am.thmulti.com:80" >> /etc/profile
# echo export https_proxy="https://ladczproxy.am.thmulti.com:80" >> /etc/profile
#  /etc/profile

# set -e

apt-get -y update &&
apt-get -y install chrony &&
apt-get -y install ntp &&
apt-get -y install syslog-ng &&
apt-get -y install aide &&
apt-get -y install prelink &&
apt-get -y install rsyslog &&
apt-get -y install libpam-pwquality &&
apt-get -y --purge remove openssh-server
apt-get -y install ssh &&
# apt-get -y install chage (find deps)
# apt-get -y remove telnet 
apt-get -y install figlet &&
apt-get -y install unzip curl git

# Reformat disks
# placeholder for /etc/fstab and filesystem changes

# mount -o remount,nodev /tmp
# mount -o remount,nodev /var/tmp

# idf --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | chmod a+t

chown root:root /boot/grub/grub.cfg
chmod og-rwx /boot/grub/grub.cfg

# grub-mkpasswd-pbkdf2 (requires input file)

# cat scripts/grub.d_00_header.file >> /etc/grub.d/00_header
# update-grub

echo "Welcome to Technicolor." >> /etc/motd

cp /etc/issue /etc/issue.orig
cat scripts/banner.file >> /etc/issue

echo "Authorized uses only. All activity may be monitored and reported." >> /etc/issue.net

cp /etc/issue.net /etc/issue.net.orig
cat scripts/issues_net.file >> /etc/issue.net 

chown root:root /etc/motd
chmod 644 /etc/motd
chown root:root /etc/issue
chmod 644 /etc/issue
chown root:root /etc/issue.net
chmod 644 /etc/issue.net

# gdm is part of Gnome Desktop Mgr.  Command is required if gdm login is used.
# cat /etc/dconf/profile/gdm /etc/dconf/profile/gdm.orig
# cat scripts/gdm.file >> /etc/dconf/profile/gdm
# dconf update

cp /etc/ntp.conf /etc/ntp.conf.orig
cat scripts/ntp.file >> /etc/ntp.conf
# systemctl disable avahi-daemon
# systemctl disable isc-dhcp-server
# systemctl disable iisc-dhcp-server 

cp /etc/sysctl.conf /etc/sysctl.conf.orig
cat scripts/sysctl.file >> /etc/sysctl.conf 

sysctl -w fs.suid_dumpable=0
sysctl -w kernel.randomize_va_space=2
sysctl -w net.ipv4.conf.all.send_redirects=0
sysctl -w net.ipv4.conf.default.send_redirects=0
sysctl -w net.ipv4.conf.all.accept_source_route=0
sysctl -w net.ipv4.conf.default.accept_source_route=0
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv4.conf.default.accept_redirects=0
sysctl -w net.ipv4.conf.all.secure_redirects=0
sysctl -w net.ipv4.conf.default.secure_redirects=0
sysctl -w net.ipv4.conf.all.log_martians=1
sysctl -w net.ipv4.conf.default.log_martians=1
sysctl -w net.ipv6.conf.all.accept_ra=0
sysctl -w net.ipv6.conf.default.accept_ra=0
sysctl -w net.ipv6.conf.all.accept_redirects=0
sysctl -w net.ipv6.conf.default.accept_redirects=0
sysctl -w net.ipv6.route.flush=1
prelink -ua

# cp /etc/default/grub /etc/default/grub.orig
# cat scripts/grub.file >> /etc/default/grub
update-grub
echo "ALL: ALL" >> /etc/hosts.deny
chown root:root /etc/hosts.allow
chmod 644 /etc/hosts.allow

cat scripts/CIS_conf.file >> /etc/modprobe.d/CIS.conf

# cp scripts/iptables /sbin/
# chmod a+x /sbin/iptables
# ./iptables
chmod a+x iptables_sec.sh 
bash iptables_sec.sh

systemctl enable rsyslog

update-rc.d syslog-ng enable

cp /etc/syslog-ng/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf.old
cat scripts/syslog-ng.file >> /etc/syslog-ng/syslog-ng.conf

chmod -R g-wx,o-rwx /var/log/*
chown root:root /etc/crontab
chmod og-rwx /etc/crontab
chown root:root /etc/cron.hourly
chmod og-rwx /etc/cron.hourly
chown root:root /etc/cron.daily
chmod og-rwx /etc/cron.daily
chown root:root /etc/cron.weekly
chmod og-rwx /etc/cron.weekly
chown root:root /etc/cron.monthly
chmod og-rwx /etc/cron.monthly
chown root:root /etc/cron.d
chmod og-rwx /etc/cron.d

rm /etc/cron.deny
rm /etc/at.deny

touch /etc/cron.allow
touch /etc/at.allow

chmod og-rwx /etc/cron.allow
chmod og-rwx /etc/at.allow
chown root:root /etc/cron.allow
chown root:root /etc/at.allow
chown root:root /etc/ssh/sshd_config
chmod og-rwx /etc/ssh/sshd_config
chown root:root /etc/ssh/sshd_config
chmod og-rwx /etc/ssh/sshd_config

cp /etc/ssh/ssh_config /etc/ssh/ssh_config.orig
cat scripts/ssh_config.file >> /etc/ssh/ssh_config

cp /etc/pam.d/common-password /etc/pam.d/common-password.orig
cat scripts/common-password.file >> /etc/pam.d/common-password

cp /etc/security/pwquality.conf /etc/security/pwquality.conf.orig
cat scripts/pwquality.file >> /etc/security/pwquality.conf

cp /etc/pam.d/common-password /etc/pam.d/common-password.orig
cat scripts/pam.d_common-password.file >> /etc/pam.d/common-password

cp /etc/login.defs /etc/login.defs.orig
cat scripts/login_defs.file >> /etc/login.defs
# chage --maxdays 90 <user>
# useradd -D -f 30

cp /etc/bash.bashrc /etc/bash.bashrc.orig
cat scripts/bash_bashrc.file >> /etc/bash.bashrc

cp /etc/pam.d/su /etc/pam.d/su.orig
cat pam.d_su.file >> /etc/pam.d/su

sh scripts/world_writable_files.sh
# sh scripts/world/world_writable_dirs_sticky.sh

apt-get -y install openssh-server

apt -y autoremove

# Cleanup
apt-get -y remove prelink
