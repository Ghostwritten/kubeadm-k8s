#!/bin/bash

set -o nounset

. env.sh

#/etc/hosts
cat <<EOF > /etc/hosts 
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 
::1        localhost localhost.localdomain localhost6 localhost6.localdomain6 
$master master 
$node node 
EOF

#selinux disable
setenforce  0
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/sysconfig/selinux
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/selinux/config

# stop firwalled
systmectl stop firewalld
systmectl disable firewalld

# stop swap
swapoff -a
sed -i 's/.*swap.*/#&/' /etc/fstab

# add core module
modprobe br_netfilter

# core params
cat > /etc/sysctl.d/k8s.conf <<EOF 
net.bridge.bridge-nf-call-ip6tables = 1 
net.bridge.bridge-nf-call-iptables = 1 
EOF

sysctl -p /etc/sysctl.d/k8s.conf


# file max open numbers

echo "* soft nofile 655360" >> /etc/security/limits.conf
echo "* hard nofile 655360" >> /etc/security/limits.conf
echo "* soft nproc 655360"  >> /etc/security/limits.conf
echo "* hard nproc 655360"  >> /etc/security/limits.conf
echo "* soft  memlock  unlimited"  >> /etc/security/limits.conf
echo "* hard memlock  unlimited"  >> /etc/security/limits.conf
echo "DefaultLimitNOFILE=1024000"  >> /etc/systemd/system.conf
echo "DefaultLimitNPROC=1024000"  >> /etc/systemd/system.conf


# config yum about k8s 
yum install -y wget
rm -rf  /etc/yum.repos.d/*
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.cloud.tencent.com/repo/centos7_base.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.cloud.tencent.com/repo/epel-7.repo
yum clean all && yum makecache

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg  
EOF

yum install  -y conntrack ipvsadm ipset jq sysstat curl iptables libseccomp bash-completion yum-utils device-mapper-persistent-data lvm2 net-tools conntrack-tools vim libtool-ltdl

# time sync
yum -y install chrony
systemctl enable chronyd.service && systemctl start chronyd.service && systemctl status chronyd.service
chronyc sources

