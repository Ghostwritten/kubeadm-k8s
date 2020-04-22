#!/bin/bash

FOLDER=$(cd "$(dirname "$0")";pwd)
tag=v1.10.0

certs() {
 mkdir -p /etc/kubernetes/certs
 cd /etc/kubernetes/certs 
 openssl genrsa -des3 -passout pass:x -out dashboard.pass.key 2048
 openssl rsa -passin pass:x -in dashboard.pass.key -out dashboard.key
 rm -rf dashboard.pass.key
 openssl req -new -key dashboard.key -out dashboard.csr
 openssl x509 -req -sha256 -days 365 -in dashboard.csr -signkey dashboard.key -out dashboard.crt
 kubectl create secret generic kubernetes-dashboard-certs --from-file=/etc/kubernetes/certs -n kube-system
 cd $FOLDER
}

images() {
docker pull registry.cn-hangzhou.aliyuncs.com/kubernete/kubernetes-dashboard-amd64:$tag
docker tag registry.cn-hangzhou.aliyuncs.com/kubernete/kubernetes-dashboard-amd64:$tag k8s.gcr.io/kubernetes-dashboard:$tag
docker rmi registry.cn-hangzhou.aliyuncs.com/kubernete/kubernetes-dashboard-amd64:$tag

}

dashboard() {
wget https://raw.githubusercontent.com/kubernetes/dashboard/$tag/src/deploy/recommended/kubernetes-dashboard.yaml
sed -i "s/kubernetes-dashboard-amd64:$tag/kubernetes-dashboard:$tag/g" kubernetes-dashboard.yaml
sed -i  -r '/Dashboard Secret/,+11s/(.*)/#&/' kubernetes-dashboard.yaml

}
# 修改Service类 添加 nodePort
#格式如下：
#kind: Service
#apiVersion: v1
#metadata:
#  labels:
#    k8s-app: kubernetes-dashboard
#  name: kubernetes-dashboard
#  namespace: kube-system
#spec:
#  ports:
#    - port: 443
#      targetPort: 8443 
#      nodePort: 30005  #手动添加
#  type: NodePort       #手动添加

#添加完成后,去掉注释的runing

running(){
  kubectl create -f  kubernetes-dashboard.yaml
  echo "********************"
  echo "get deployment kubernetes-dashboard: "
  kubectl get deployment kubernetes-dashboard -n kube-system
  echo "********************"
  echo "get pods kubernetes-dashboard:  "
  kubectl --namespace kube-system get pods -o wide
  echo "********************"
  echo "get services kubernetes-dashboard:  "
  kubectl get services kubernetes-dashboard -n kube-system
  echo "********************"
  netstat -ntlp|grep 30005

}

certs
images
dashboard
running
