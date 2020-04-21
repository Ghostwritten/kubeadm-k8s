docker pull calico/node:v3.1.4
docker pull calico/cni:v3.1.4
docker pull calico/typha:v3.1.4

docker tag calico/node:v3.1.4 quay.io/calico/node:v3.1.4
docker tag calico/cni:v3.1.4 quay.io/calico/cni:v3.1.4
docker tag calico/typha:v3.1.4 quay.io/calico/typha:v3.1.4

docker rmi calico/node:v3.1.4
docker rmi calico/cni:v3.1.4
docker rmi calico/typha:v3.1.4

curl https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml -O 

kubectl apply -f rbac-kdd.yaml

curl https://docs.projectcalico.org/v3.1/gettingstarted/kubernetes/installation/hosted/kubernetes-datastore/policy-only/1.7/calico.yaml -O

