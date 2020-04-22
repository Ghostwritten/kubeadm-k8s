#!/bin/bash

tag=v1.10.0

images() {
docker pull registry.cn-hangzhou.aliyuncs.com/kubernete/kubernetes-dashboard-amd64:$tag
docker tag registry.cn-hangzhou.aliyuncs.com/kubernete/kubernetes-dashboard-amd64:v$tag k8s.gcr.io/kubernetes-dashboard:$tag
docker rmi registry.cn-hangzhou.aliyuncs.com/kubernete/kubernetes-dashboard-amd64:$tag

}

images
