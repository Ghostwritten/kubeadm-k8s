


cat <<EOF > /etc/hosts 
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 
::1        localhost localhost.localdomain localhost6 localhost6.localdomain6 
192.168.1.11 master 
192.168.1.12 node 
EOF

setenforce  0
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/sysconfig/selinux
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/selinux/config

systmectl stop firewalld
systmectl disable firewalld

swapoff -a
sed -i 's/.*swap.*/#&/' /etc/fstab

modprobe br_netfilter

cat > /etc/sysctl.d/k8s.conf <<EOF 
net.bridge.bridge-nf-call-ip6tables = 1 
net.bridge.bridge-nf-call-iptables = 1 
EOF

sysctl -p /etc/sysctl.d/k8s.conf



echo "* soft nofile 655360" >> /etc/security/limits.conf
echo "* hard nofile 655360" >> /etc/security/limits.conf
echo "* soft nproc 655360"  >> /etc/security/limits.conf
echo "* hard nproc 655360"  >> /etc/security/limits.conf
echo "* soft  memlock  unlimited"  >> /etc/security/limits.conf
echo "* hard memlock  unlimited"  >> /etc/security/limits.conf
echo "DefaultLimitNOFILE=1024000"  >> /etc/systemd/system.conf
echo "DefaultLimitNPROC=1024000"  >> /etc/systemd/system.conf


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

yum -y install chrony
systemctl enable chronyd.service && systemctl start chronyd.service && systemctl status chronyd.service
chronyc sources

yum remove -y docker docker-ce docker-common docker-selinux docker-engine
yum-config-manager  --add-repo  https://download.docker.com/linux/centos/docker-ce.repo

yum list docker-ce --showduplicates | sort -r

yum install -y docker-ce-18.06.1.ce-3.el7

[ -d /etc/docker ] || mkdir /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{  
  "registry-mirrors": ["https://q2hy3fzi.mirror.aliyuncs.com"], 
  "graph": "/tol/docker-data" 
} 
EOF


systemctl daemon-reload && systemctl restart docker && systemctl enable docker && systemctl status docker 

#----------------k8s start-----------
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable kubelet && systemctl start kubelet

kubeadm config print init-defaults > kubeadm.conf 

sed -i "s/imageRepository: .*/imageRepository: registry.aliyuncs.com\/google_containers/g" kubeadm.conf

sed -i "s/kubernetesVersion: .*/kubernetesVersion: v1.18.0/g" kubeadm.conf

kubeadm config images pull --config kubeadm.conf

bash tag.sh

kubeadm init --kubernetes-version=v1.18.0 --pod-network-cidr=172.22.0.0/16 --apiserver-advertise-address=192.168.211.11



