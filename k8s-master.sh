#!/bin/bash

. env.sh

kubeadm init --kubernetes-version=$version --pod-network-cidr=172.22.0.0/16 --apiserver-advertise-address=$master

mkdir -p /root/.kube

cp /etc/kubernetes/admin.conf /root/.kube/config

kubectl get pods --all-namespaces

kubectl get cs
