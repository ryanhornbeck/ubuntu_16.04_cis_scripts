#!/bin/sh
# CIS Hardening Script for Ubuntu 16.04 LTS v0.1
# Technicolor Enterprise Architecture
# Ryan Hornbeck & Jim Tessier

# Set http and https proxies for TCH
# echo export http_proxy="http://ladczproxy.am.thmulti.com:80" >> /etc/profile
# echo export https_proxy="https://ladczproxy.am.thmulti.com:80" >> /etc/profile
#  /etc/profile

apt-get -y update &&
apt-get -y install chrony &&
apt-get -y install ntp &&
apt-get -y install syslog-ng &&
apt-get -y install aide &&
apt-get -y install prelink &&
apt-get -y install rsyslog &&
apt-get -y install libpam-pwquality &&
apt-get -y install ssh &&
# apt-get -y install chage (find deps)
apt-get -y remove telnet 

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
cat scripts/banner.file >> /etc/issue
echo "Authorized uses only. All activity may be monitored and reported." >> /etc/issue.net
cat scripts/issues_net.file >> /etc/issue.net 
chown root:root /etc/motd
chmod 644 /etc/motd
chown root:root /etc/issue
chmod 644 /etc/issue
chown root:root /etc/issue.net
chmod 644 /etc/issue.net

cat scripts/gdm.file >> /etc/dconf/profile/gdm
dconf update

cat scripts/ntp.file >> /etc/ntp.conf
systemctl disable avahi-daemon
systemctl disable isc-dhcp-server
systemctl disable iisc-dhcp-server 

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

# cat scripts/grub.file >> /etc/default/grub
update-grub
echo "ALL: ALL" >> /etc/hosts.deny
chown root:root /etc/hosts.allow
chmod 644 /etc/hosts.allow

cat scripts/CIS_conf.file >> /etc/modprobe.d/CIS.conf

sh scripts/iptables_sec.sh 

systemctl enable rsyslog

update-rc.d syslog-ng enable

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

cat scripts/sshd_config.file >> /etc/ssh/sshd_config

cat scripts/common-password.file >> /etc/pam.d/common-password

cat scripts/pwquality.file >> /etc/security/pwquality.conf

cat scripts/pam.d_common-password.file >> /etc/pam.d/common-password

cat login_defs.file >> /etc/login.defs
chage --maxdays 90 <user>
useradd -D -f 30

cat scripts/bash_bashrc.file >> /etc/bash.bashrc

cat pam.d_su.file >> /etc/pam.d/su

sh scripts/world_writable_files.sh

# Cleanup

apt-get remove prelink
