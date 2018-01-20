#!/bin/bash

if [ `whoami` != "root" ];then  
    echo "please run as root!"
    exit 0  
fi

#a.iptables and selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
grep SELINUX=disabled /etc/selinux/config
setenforce 0

/etc/init.d/iptables stop
/etc/init.d/iptables stop
chkconfig iptables off
chkconfig --list|grep ipt

#b.service startup at linux startup
LANG=en
for oldboy in `chkconfig --list|grep "3:on"|awk '{print $1}'|grep -vE "crond|network|sshd|rsyslog"`;do chkconfig $oldboy off;done
chkconfig --list|grep "3:on"
unset LANG

#c.character set
cp /etc/sysconfig/i18n /etc/sysconfig/i18n.ori
echo 'LANG="zh_CN.UTF-8"'>/etc/sysconfig/i18n
source /etc/sysconfig/i18n
echo $LANG

#d.time sync 
yum install -y ntpdate
/usr/sbin/ntpdate time.nist.gov
echo '#time sync by oldboy at 2010-2-1' >>/var/spool/cron/root
echo '*/5 * * * * /usr/sbin/ntpdate time.nist.gov >/dev/null 2>&1' >>/var/spool/cron/root
crontab -l

#e.set timezone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
echo "Asia/Shanghai" > /etc/timezone
hwclock -w

#f.file desc
echo '*               -       nofile          65535 ' >>/etc/security/limits.conf

#wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo

