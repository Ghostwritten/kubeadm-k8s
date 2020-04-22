#!/bin/bash


set -o nounset

yum remove -y docker docker-ce docker-ce-cli docker-common docker-selinux docker-engine
yum-config-manager  --add-repo  https://download.docker.com/linux/centos/docker-ce.repo

yum list docker-ce --showduplicates | sort -r

yum install -y  docker-ce-18.06.1.ce-3.el7 

[ -d /etc/docker ] || mkdir /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{  
  "registry-mirrors": ["https://q2hy3fzi.mirror.aliyuncs.com"], 
  "graph": "/tol/docker-data" 
} 
EOF

systemctl daemon-reload && systemctl restart docker && systemctl enable docker && systemctl status docker 

