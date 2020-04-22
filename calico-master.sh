#!/bin/bash

images() {
docker pull calico/node:v3.1.4
docker pull calico/cni:v3.1.4
docker pull calico/typha:v3.1.4

docker tag calico/node:v3.1.4 quay.io/calico/node:v3.1.4
docker tag calico/cni:v3.1.4 quay.io/calico/cni:v3.1.4
docker tag calico/typha:v3.1.4 quay.io/calico/typha:v3.1.4

docker rmi calico/node:v3.1.4
docker rmi calico/cni:v3.1.4
docker rmi calico/typha:v3.1.4

}
rbac-kdd() {
curl https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml -O 

kubectl apply -f rbac-kdd.yaml
}
calico() {
curl https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/policy-only/1.7/calico.yaml -O

sed -r -i  's/typha_service_name:(.*)/typha_service_name: "calico-typha"/ ' calico.yaml
sed -r -i  's/replicas:(.*)/replicas: 1/ ' calico.yaml
sed -r -i  '/CALICO_IPV4POOL_CIDR/{n;s/value:(.*)/value: "172.22.0.0\/16"/;} ' calico.yaml
sed -r -i  '/ CALICO_NETWORKING_BACKEND/{n;s/value:(.*)/value: "bird"/;} ' calico.yaml

kubectl apply -f calico.yaml
kubectl get pods --all-namespaces

}
images
rbac-kdd
calico
