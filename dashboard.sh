#!/bin/bash
tag=v2.0.0-rc7
docker pull registry.cn-hangzhou.aliyuncs.com/kubernete/kubernetes-dashboard-amd64:$tag
docker tag registry.cn-hangzhou.aliyuncs.com/kubernete/kubernetes-dashboard-amd64:v$tag k8s.gcr.io/kubernetes-dashboard:$tag
docker rmi registry.cn-hangzhou.aliyuncs.com/kubernete/kubernetes-dashboard-amd64:$tag

#curl https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/k ubernetes-dashboard.yaml -O
sed -i "s/kubernetes-dashboard-amd64:v1.10.0/kubernetes-dashboard:$tag/g" kubernetes-dashboard.yaml
