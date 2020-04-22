#!/bin/bash

set -o nounset

. env.sh

yum remove -y  kubelet kubeadm kubectl --disableexcludes=kubernetes
yum install -y kubernetes-cni-0.6.0-0 kubelet-$version-0 kubeadm-$version-0 kubectl-$version-0 --disableexcludes=kubernetes

systemctl enable kubelet && systemctl start kubelet

kubeadm config print init-defaults > kubeadm.conf 

sed -i "s/imageRepository: .*/imageRepository: registry.aliyuncs.com\/google_containers/g" kubeadm.conf

sed -i "s/kubernetesVersion: .*/kubernetesVersion: $version/g" kubeadm.conf

kubeadm config images pull --config kubeadm.conf

bash tag.sh
